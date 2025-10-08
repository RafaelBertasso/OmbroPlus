import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class ProtocolScheduleEditorPage extends StatefulWidget {
  final String patientId;
  final DateTime startDate;
  final DateTime endDate;
  const ProtocolScheduleEditorPage({
    super.key,
    required this.patientId,
    required this.startDate,
    required this.endDate,
  });

  @override
  State<ProtocolScheduleEditorPage> createState() =>
      _ProtocolScheduleEditorPageState();
}

class _ProtocolScheduleEditorPageState
    extends State<ProtocolScheduleEditorPage> {
  DateTime _selectedDate = DateTime.now();
  List<DateTime> _protocolDays = [];

  Map<String, List<Map<String, String>>> _schedule = {};

  @override
  void initState() {
    super.initState();
    _protocolDays = _generateDays(widget.startDate, widget.endDate);

    if (widget.startDate.isBefore(DateTime.now())) {
      _selectedDate = widget.startDate;
    } else {
      _selectedDate = DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
      ); // Apenas data, sem hora
    }

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

  void _loadScheduleData() {
    final startDateString = DateFormat('dd/MM/yyyy').format(widget.startDate);

    setState(() {
      _schedule[startDateString] = [
        {'title': 'Rotação Externa', 'subtitle': '3 séries x 12 reps'},
        {'title': 'Elevação Frontal', 'subtitle': '3 séries x 10 reps'},
      ];
    });
    // TODO: buscar o 'schedule' do Firestore aqui.
  }

  Future<void> _saveScheduleData() async {
    // TODO: salvar o 'schedule' no Firestore aqui.
  }

  Widget _buildDateSelectorItem(DateTime date) {
    final isSelected = DateUtils.isSameDay(date, _selectedDate);

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDate = date;
        });
      },
      child: Container(
        width: 75,
        margin: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF0E382C) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? Colors.transparent : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
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
            SizedBox(height: 4),
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
    final selectedDateKey = DateFormat('dd/MM/yyyy').format(_selectedDate);
    final exercisesForDay = _schedule[selectedDateKey] ?? [];

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

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/new-exercise'),
              icon: const Icon(
                Icons.add_circle_outline,
                color: Color(0xFF0E382C),
              ),
              label: Text(
                'Adicionar Exercício',
                style: GoogleFonts.openSans(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: const Color(0xFF0E382C),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE0E0E0),
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
            ),
          ),
        ),
        SizedBox(height: 10),

        Expanded(
          child: exercisesForDay.isEmpty
              ? Center(child: Text('Nenhum exercício agendado para este dia.'))
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
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            // TODO Lógica para remover exercício do _schedule
                          },
                        ),
                        onTap: () {
                          // TODO Lógica para editar exercício
                        },
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
      backgroundColor: Color(0xFFF4F7F6),
      appBar: AppBar(
        backgroundColor: Color(0xFF0E382C),
        title: Text(
          'Cronograma Diário',
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        iconTheme: IconThemeData(color: Colors.white, size: 26),
        elevation: 0.4,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.save_as_outlined, color: Colors.white),
            onPressed: () async {
              await _saveScheduleData();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Cronograma salvo com sucesso!')),
              );
            },
            tooltip: 'Salvar Cronograma',
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(height: 10),
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
