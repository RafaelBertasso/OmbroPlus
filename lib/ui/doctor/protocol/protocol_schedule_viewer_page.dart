import 'package:Ombro_Plus/viewmodels/shared/protocol_schedule_viewer_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ProtocolScheduleViewerPage extends StatefulWidget {
  final String protocolId;

  const ProtocolScheduleViewerPage({super.key, required this.protocolId});

  @override
  State<ProtocolScheduleViewerPage> createState() =>
      _ProtocolScheduleViewerPageState();
}

class _ProtocolScheduleViewerPageState
    extends State<ProtocolScheduleViewerPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProtocolScheduleViewerViewModel>().loadSchedule(
        widget.protocolId,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      appBar: AppBar(
        title: Text(
          'Sessões do Protocolo',
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
            return const Center(child: CircularProgressIndicator.adaptive());
          }

          if (viewModel.protocol == null) {
            return const Center(child: Text('Erro ao carregar cronograma'));
          }

          final weeks = viewModel.sortedWeeks;
          final groupedSessions = viewModel.sessionsByWeek;

          if (weeks.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.layers_clear,
                    size: 60,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhuma sessão definida',
                    style: GoogleFonts.openSans(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: weeks.length,
            itemBuilder: (context, weekIndex) {
              final week = weeks[weekIndex];
              final weekSessions = groupedSessions[week]!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título da Semana
                  Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 12, left: 4),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_month,
                          color: Color(0xFF0E382C),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Semana $week',
                          style: GoogleFonts.montserrat(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0E382C),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Lista de sessões desta semana
                  ...weekSessions.asMap().entries.map((entry) {
                    final sessionIndex = entry.key;
                    final session = entry.value;
                    final int exerciseCount = session.exercises.length;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: Colors.grey.shade300, width: 1),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Container(
                        decoration: const BoxDecoration(
                          border: Border(
                            left: BorderSide(
                              color: Color(0xFF0E382C),
                              width: 6,
                            ),
                          ),
                        ),
                        child: ExpansionTile(
                          // Abre automaticamente a primeira sessão da primeira semana
                          initiallyExpanded:
                              weekIndex == 0 && sessionIndex == 0,
                          tilePadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          shape: const RoundedRectangleBorder(
                            side: BorderSide.none,
                          ),
                          collapsedShape: const RoundedRectangleBorder(
                            side: BorderSide.none,
                          ),
                          backgroundColor: Colors.white,
                          collapsedBackgroundColor: Colors.white,
                          leading: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0E382C).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${sessionIndex + 1}', // Número da sessão na semana
                              style: GoogleFonts.montserrat(
                                color: const Color(0xFF0E382C),
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          title: Text(
                            session.name,
                            style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                              color: const Color(0xFF0E382C),
                            ),
                          ),
                          subtitle: Text(
                            '$exerciseCount exercício${exerciseCount > 1 ? 's' : ''}',
                            style: GoogleFonts.openSans(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          children: session.exercises.map((exercise) {
                            final series = exercise['series'] ?? '-';
                            final reps = exercise['repeticoes'] ?? '-';

                            return Container(
                              decoration: BoxDecoration(
                                border: Border(
                                  top: BorderSide(color: Colors.grey.shade100),
                                ),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 8,
                                ),
                                leading: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.fitness_center,
                                    size: 20,
                                    color: Color(0xFF0E382C),
                                  ),
                                ),
                                title: Text(
                                  exercise['nome'] ?? 'Exercício',
                                  style: GoogleFonts.montserrat(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                    color: Colors.black87,
                                  ),
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 6.0),
                                  child: Row(
                                    children: [
                                      _buildPrescriptionTag(
                                        Icons.repeat,
                                        '$series Séries',
                                      ),
                                      const SizedBox(width: 12),
                                      _buildPrescriptionTag(
                                        Icons.sync,
                                        '$reps Reps',
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    );
                  }).toList(),
                  const SizedBox(height: 12), // Espaço entre as semanas
                ],
              );
            },
          );
        },
      ),
    );
  }

  // Widget auxiliar para desenhar as "Tags" de Séries e Repetições
  Widget _buildPrescriptionTag(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF0E382C).withOpacity(0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF0E382C)),
          const SizedBox(width: 4),
          Text(
            text,
            style: GoogleFonts.openSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF0E382C),
            ),
          ),
        ],
      ),
    );
  }
}
