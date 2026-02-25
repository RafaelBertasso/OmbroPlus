import 'package:Ombro_Plus/models/protocol_model.dart';
import 'package:Ombro_Plus/viewmodels/patient/session_execution_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class SessionExecutionPage extends StatelessWidget {
  final String protocolId;
  final ProtocolSession session;

  const SessionExecutionPage({
    super.key,
    required this.protocolId,
    required this.session,
  });

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<SessionExecutionViewmodel>();

    final bool allDone = viewModel.canFinishSession(session.exercises);
    final bool isLocked = viewModel.isSessionCompletedLocally;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0E382C),
        title: Text(
          session.name,
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: session.exercises.isEmpty
          ? Center(
              child: Text(
                'Nenhum exercício cadastrado nesta sessão.',
                style: GoogleFonts.openSans(color: Colors.grey.shade600),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.only(
                top: 16,
                bottom: 100,
                left: 16,
                right: 16,
              ),
              itemCount: session.exercises.length,
              itemBuilder: (context, index) {
                final exercise = session.exercises[index];
                final exerciseId = exercise['exercicioId'] as String;

                final isCompleted =
                    exerciseId != null &&
                    viewModel.completedExerciseIds.contains(exerciseId);

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: isCompleted
                        ? const BorderSide(color: Colors.green, width: 1.5)
                        : BorderSide.none,
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? Colors.green.withOpacity(0.1)
                            : const Color(0xFF0E382C).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isCompleted ? Icons.check : Icons.fitness_center,
                        color: isCompleted ? Colors.green : Color(0xFF0E382C),
                      ),
                    ),
                    title: Text(
                      exercise['title'] ?? 'Exercício',
                      style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                      '${exercise['series']} séries x ${exercise['repeticoes']} repetições',
                      style: GoogleFonts.openSans(color: Colors.grey.shade600),
                    ),
                    trailing: const Icon(
                      Icons.chevron_right,
                      color: Colors.grey,
                    ),
                    onTap: () async {
                      if (exerciseId != null) {
                        await Navigator.pushNamed(
                          context,
                          '/exercise-details',
                          arguments: {
                            'protocoloId': protocolId,
                            'exercicioId': exerciseId,
                            'allDailyExercises': session.exercises,
                          },
                        );
                        if (context.mounted) {
                          viewModel.loadCompletedExercises(protocolId);
                        }
                      }
                    },
                  ),
                );
              },
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: (viewModel.isLoading || isLocked || !allDone)
                ? null
                : () async {
                    final success = await viewModel.finishSession(
                      protocolId: protocolId,
                      sessionId: session.id,
                      sessionName: session.name,
                    );

                    if (success && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Sessão concluída com sucesso!'),
                        ),
                      );
                      Future.delayed(const Duration(milliseconds: 1500), () {
                        if (context.mounted) {
                          Navigator.pop(context, true);
                        }
                      });
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: isLocked
                  ? Colors.green
                  : (allDone ? const Color(0xFF0E382C) : Colors.grey.shade400),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: viewModel.isLoading
                ? const CircularProgressIndicator.adaptive()
                : Text(
                    isLocked
                        ? 'Sessão Concluída'
                        : (allDone
                              ? 'Concluir Sessão'
                              : 'Conclua os exercícios primeiro'),
                    style: GoogleFonts.openSans(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
