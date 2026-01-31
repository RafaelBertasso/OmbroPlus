import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:Ombro_Plus/viewmodels/doctor/protocol_schedule.viewmodel.dart';

class ProtocolScheduleEditorPage extends StatefulWidget {
  const ProtocolScheduleEditorPage({super.key});

  @override
  State<ProtocolScheduleEditorPage> createState() =>
      _ProtocolScheduleEditorPageState();
}

class _ProtocolScheduleEditorPageState
    extends State<ProtocolScheduleEditorPage> {
  bool _isInitialized = false;
  late String _patientId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

      if (args == null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pop(context);
        });
        return;
      }

      _patientId = args['patientId'] ?? '';
      final start = DateTime.parse(args['startDate']);
      final end = DateTime.parse(args['endDate']);
      final currentSchedule = args['currentSchedule'] as Map<String, dynamic>?;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.read<ProtocolScheduleViewModel>().initialize(
            start,
            end,
            currentSchedule,
          );
        }
      });
      _isInitialized = true;
    }
  }

  Widget _buildDateSelectorItem(
    DateTime date,
    DateTime selectedDate,
    bool hasExercises,
  ) {
    final isSelected = DateUtils.isSameDay(date, selectedDate);

    return GestureDetector(
      onTap: () => context.read<ProtocolScheduleViewModel>().selectDate(date),
      child: Container(
        width: 70,
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0E382C) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? Colors.transparent : Colors.grey.shade300,
            width: 1,
          ),
          boxShadow: hasExercises
              ? [
                  BoxShadow(
                    color: isSelected
                        ? Colors.green.shade900
                        : Colors.green.shade200,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              DateFormat('EEE', 'pt_BR').format(date).toUpperCase(),
              style: GoogleFonts.montserrat(
                color: isSelected ? Colors.white : Colors.black54,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('dd').format(date),
              style: GoogleFonts.montserrat(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseList(ProtocolScheduleViewModel viewModel) {
    final dateKey = DateFormat('yyyy-MM-dd').format(viewModel.selectedDate);
    final exercises = viewModel.schedule[dateKey] ?? [];

    if (exercises.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_note, size: 60, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'Nenhum exercício neste dia.',
              style: GoogleFonts.openSans(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: exercises.length,
      itemBuilder: (context, index) {
        final ex = exercises[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F7F6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.fitness_center, color: Color(0xFF0E382C)),
            ),
            title: Text(
              ex['title'] ?? 'Exercício',
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
            subtitle: Text(
              ex['subtitle'] ?? '',
              style: GoogleFonts.openSans(fontSize: 13),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              onPressed: () {
                viewModel.removeExercise(dateKey, index);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Exercício removido'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProtocolScheduleViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF4F7F6),
          appBar: AppBar(
            backgroundColor: const Color(0xFF0E382C),
            title: Text(
              'Cronograma Diário',
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            centerTitle: true,
            iconTheme: const IconThemeData(color: Colors.white),
            actions: [
              IconButton(
                icon: const Icon(Icons.check),
                tooltip: 'Salvar Cronograma',
                onPressed: () {
                  if (viewModel.schedule.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Adicione exercícios antes de salvar.'),
                      ),
                    );
                    return;
                  }
                  Navigator.pop(context, viewModel.schedule);
                },
              ),
            ],
          ),
          body: Column(
            children: [
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: viewModel.protocolDays.length,
                  itemBuilder: (context, index) {
                    final date = viewModel.protocolDays[index];
                    final dateKey = DateFormat('yyyy-MM-dd').format(date);
                    final hasEx = viewModel.schedule.containsKey(dateKey);

                    return _buildDateSelectorItem(
                      date,
                      viewModel.selectedDate,
                      hasEx,
                    );
                  },
                ),
              ),

              const Divider(height: 1),

              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat(
                        "dd 'de' MMMM",
                        'pt_BR',
                      ).format(viewModel.selectedDate),
                      style: GoogleFonts.montserrat(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0E382C),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () async {
                        final result = await Navigator.pushNamed(
                          context,
                          '/add-exercise-to-protocol',
                          arguments: {
                            'patientId': _patientId,
                            'protocolDays': viewModel.protocolDays
                                .map((d) => d.toIso8601String())
                                .toList(),
                          },
                        );

                        if (result != null && result is Map<String, dynamic>) {
                          viewModel.addExercises(result);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0E382C),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      icon: const Icon(
                        Icons.add,
                        size: 18,
                        color: Colors.white,
                      ),
                      label: Text(
                        "Adicionar",
                        style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(child: _buildExerciseList(viewModel)),
            ],
          ),
        );
      },
    );
  }
}
