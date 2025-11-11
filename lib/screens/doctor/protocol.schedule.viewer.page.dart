import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

const String FIRESTORE_DATE_KEY = 'yyyy-MM-dd';

class ProtocolScheduleViewerPage extends StatefulWidget {
  final String protocolId;
  final DateTime startDate;
  final DateTime endDate;

  const ProtocolScheduleViewerPage({
    super.key,
    required this.protocolId,
    required this.startDate,
    required this.endDate,
  });

  @override
  State<ProtocolScheduleViewerPage> createState() =>
      _ProtocolScheduleViewerPageState();
}

class _ProtocolScheduleViewerPageState
    extends State<ProtocolScheduleViewerPage> {
  DateTime _selectedDate = DateTime.now();
  List<DateTime> _protocolDays = [];
  Map<String, List<Map<String, dynamic>>> _schedule = {};
  bool _isLoadingSchedule = true;

  @override
  void initState() {
    super.initState();
    _protocolDays = _generateDays(widget.startDate, widget.endDate);

    final now = DateTime.now();
    _selectedDate = _protocolDays.firstWhere(
      (day) => day.isAfter(now.subtract(const Duration(days: 1))),
      orElse: () => _protocolDays.first,
    );

    _loadScheduleData();
  }

  List<DateTime> _generateDays(DateTime start, DateTime end) {
    final days = <DateTime>[];
    for (int i = 0; i <= end.difference(start).inDays; i++) {
      final date = start.add(Duration(days: i));
      days.add(DateTime(date.year, date.month, date.day));
    }
    return days;
  }

  Map<String, List<Map<String, dynamic>>> _castSchedule(
    Map<String, dynamic> scheduleData,
  ) {
    final Map<String, List<Map<String, dynamic>>> loadedSchedule = {};

    scheduleData.forEach((key, value) {
      if (key is String && value is List) {
        try {
          final List<Map<String, dynamic>> exercises = value
              .cast<Map>()
              .map((e) => e.cast<String, dynamic>())
              .toList();

          if (exercises.isNotEmpty) {
            loadedSchedule[key] = exercises;
          }
        } catch (e) {
          debugPrint('Erro de cast interno no dia $key: $e');
        }
      }
    });
    return loadedSchedule;
  }

  Future<void> _loadScheduleData() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('protocolos')
          .doc(widget.protocolId)
          .get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data() as Map<String, dynamic>;
        final scheduleData = data['schedule'] as Map<String, dynamic>? ?? {};

        final loadedSchedule = _castSchedule(scheduleData);

        if (mounted) {
          setState(() {
            _schedule = loadedSchedule;
            _isLoadingSchedule = false;
          });
        }
      } else {
        debugPrint('Protocolo ${widget.protocolId} não encontrado.');
        if (mounted) {
          setState(() {
            _isLoadingSchedule = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Erro ao carregar cronograma: $e');
      if (mounted) {
        setState(() {
          _isLoadingSchedule = false;
        });
      }
    }
  }

  Widget _buildDateSelectorItem(DateTime date) {
    final isSelected = DateUtils.isSameDay(date, _selectedDate);
    final dateKey = DateFormat(FIRESTORE_DATE_KEY).format(date);
    final hasExercises =
        _schedule.containsKey(dateKey) && _schedule[dateKey]!.isNotEmpty;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDate = date;
        });
      },
      child: Container(
        width: 75,
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0E382C) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? Colors.transparent : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            if (hasExercises)
              BoxShadow(
                color: isSelected
                    ? Colors.green.shade900
                    : Colors.green.shade300,
                blurRadius: 4,
                offset: const Offset(0, 0),
                spreadRadius: 1,
              ),
            const BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              DateFormat('EEE', 'pt_BR').format(date).toUpperCase(),
              style: GoogleFonts.montserrat(
                color: isSelected ? Colors.white : Colors.black54,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('dd').format(date),
              style: GoogleFonts.montserrat(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyScheduleList() {
    final selectedDateKey = DateFormat(
      FIRESTORE_DATE_KEY,
    ).format(_selectedDate);
    final exercisesForDay = _schedule[selectedDateKey] ?? [];

    if (_isLoadingSchedule) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF0E382C)),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
          child: Text(
            'Sessão de ${DateFormat('dd/MM/yyyy').format(_selectedDate)}',
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: const Color(0xFF0E382C),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: exercisesForDay.isEmpty
              ? const Center(
                  child: Text('Nenhum exercício agendado para este dia.'),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  itemCount: exercisesForDay.length,
                  itemBuilder: (context, index) {
                    final ex = exercisesForDay[index];
                    return Card(
                      color: Colors.white,
                      margin: const EdgeInsets.only(bottom: 10),
                      elevation: 1,
                      child: ListTile(
                        leading: const Icon(
                          Icons.fitness_center,
                          color: Color(0xFF0E382C),
                        ),
                        title: Text(
                          ex['title']!,
                          style: GoogleFonts.openSans(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          ex['subtitle']!,
                          style: GoogleFonts.openSans(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0E382C),
        title: Text(
          'Visualizar Cronograma',
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white, size: 26),
        elevation: 0.4,
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _protocolDays.length,
              itemBuilder: (context, index) {
                final date = _protocolDays[index];
                return _buildDateSelectorItem(date);
              },
            ),
          ),
          Expanded(child: _buildDailyScheduleList()),
        ],
      ),
    );
  }
}
