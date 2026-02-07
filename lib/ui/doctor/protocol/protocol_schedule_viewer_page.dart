import 'package:Ombro_Plus/ui/shared/widgets/exercise_card.dart';
import 'package:Ombro_Plus/viewmodels/shared/protocol_schedule_viewer_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

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
  late ScrollController _calendarScrollController;
  @override
  void initState() {
    super.initState();
    _calendarScrollController = ScrollController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProtocolScheduleViewerViewModel>().loadSchedule(
        widget.protocolId,
        DateTime.now(),
      );
      _scrollToToday();
    });
  }

  void _scrollToToday() {
    final now = DateTime.now();

    if (now.isBefore(widget.startDate) || now.isAfter(widget.endDate)) {
      return;
    }

    final daysPassed = now.difference(widget.startDate).inDays;

    const double itemWidth = 62.0;
    final screenWidth = MediaQuery.of(context).size.width;

    double offset =
        (daysPassed * itemWidth) - (screenWidth / 2) + (itemWidth / 2);

    if (offset < 0) offset = 0;

    if (_calendarScrollController.hasClients) {
      _calendarScrollController.animateTo(
        offset,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _calendarScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      appBar: AppBar(
        title: Text(
          'Cronograma',
          style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF0E382C),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: Consumer<ProtocolScheduleViewerViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF0E382C)),
            );
          }

          if (viewModel.protocol == null) {
            return const Center(child: Text('Erro ao carregar cronograma'));
          }

          final exercises = viewModel.exercisesForSelectedDate;

          return Column(
            children: [
              _buildHorizontalCalendar(viewModel),

              const SizedBox(height: 10),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.event_note, color: Color(0xFF0E382C)),
                    const SizedBox(width: 8),
                    Text(
                      _formatFullDate(viewModel.selectedDate),
                      style: GoogleFonts.montserrat(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: exercises.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        itemCount: exercises.length,
                        itemBuilder: (context, index) {
                          final exercise = exercises[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: ExerciseCard(
                              title: exercise['title'] ?? 'Exercício',
                              subtitle:
                                  '${exercise['series']} séries x ${exercise['repeticoes']} repetições',
                              isCompleted: false,
                              onTap: () {},
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHorizontalCalendar(ProtocolScheduleViewerViewModel viewModel) {
    final days = _getDaysInBetween(widget.startDate, widget.endDate);

    return Container(
      height: 85,
      decoration: BoxDecoration(
        color: Color(0xFF0E382C),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: ListView.builder(
        controller: _calendarScrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        itemCount: days.length,
        itemBuilder: (context, index) {
          final date = days[index];
          final isSelected = _isSameDay(date, viewModel.selectedDate);
          final hasExercises = _hasExercisesOnDate(viewModel, date);

          return GestureDetector(
            onTap: () => viewModel.selectDate(date),
            child: Container(
              width: 50,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white
                    : Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: isSelected
                    ? Border.all(color: Colors.amber, width: 2)
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _getWeekDay(date),
                    style: GoogleFonts.openSans(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Color(0xFF0E382C) : Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date.day.toString(),
                    style: GoogleFonts.montserrat(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Color(0xFF0E382C) : Colors.white,
                    ),
                  ),
                  if (hasExercises)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy, size: 60, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'Dia de descanso.',
            style: GoogleFonts.openSans(
              fontSize: 16,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            'Nenhum exercício agendado.',
            style: GoogleFonts.openSans(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  List<DateTime> _getDaysInBetween(DateTime start, DateTime end) {
    List<DateTime> days = [];
    for (int i = 0; i <= end.difference(start).inDays; i++) {
      days.add(start.add(Duration(days: i)));
    }
    return days;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _hasExercisesOnDate(ProtocolScheduleViewerViewModel vm, DateTime date) {
    if (vm.protocol == null) return false;
    final key = DateFormat('yyyy-MM-dd').format(date);
    return vm.protocol!.schedule.containsKey(key) &&
        vm.protocol!.schedule[key]!.isNotEmpty;
  }

  String _getWeekDay(DateTime date) {
    const weekDay = ['SEG', 'TER', 'QUA', 'QUI', 'SEX', 'SAB', 'DOM'];
    return weekDay[date.weekday - 1];
  }

  String _formatFullDate(DateTime date) {
    return DateFormat("EEEE, d 'de' MMMM", 'pt_BR').format(date);
  }
}
