import 'package:Ombro_Plus/viewmodels/doctor/protocol_schedule_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

class ProtocolScheduleEditorPage extends StatelessWidget {
  const ProtocolScheduleEditorPage({super.key});

  void _showRenameDialog(
    BuildContext context,
    ProtocolScheduleViewModel viewModel,
    String sessionId,
    String currentName,
  ) {
    final controller = TextEditingController(text: currentName);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nome da Sessão'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Ex: Treino A, Semana 1'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              viewModel.renameSession(sessionId, controller.text.trim());
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0E382C),
            ),
            child: const Text('Salvar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Agora escutamos a ViewModel do Rascunho
    return Consumer<ProtocolScheduleViewModel>(
      builder: (context, viewModel, child) {
        final weeks = viewModel.sessionsByWeek.keys.toList()..sort();

        return Scaffold(
          backgroundColor: const Color(0xFFF4F7F6),
          appBar: AppBar(
            backgroundColor: const Color(0xFF0E382C),
            title: Text(
              'Editor do Cronograma',
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            centerTitle: true,
            iconTheme: const IconThemeData(color: Colors.white),
            actions: [
              // --- BOTÃO DE SALVAR AQUI ---
              IconButton(
                onPressed: () {
                  // Retorna a lista modificada para a tela anterior
                  Navigator.pop(context, viewModel.sessions);
                },
                icon: Icon(Icons.save_outlined, color: Colors.white),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: weeks.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.event_note,
                        size: 60,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Nenhuma semana criada.',
                        style: GoogleFonts.openSans(
                          color: Colors.grey.shade600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Toque em "Nova Semana" para começar.',
                        style: GoogleFonts.openSans(
                          color: Colors.grey.shade500,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 80, top: 10),
                  itemCount: weeks.length,
                  itemBuilder: (context, weekIndex) {
                    final week = weeks[weekIndex];
                    final sessionsInWeek = viewModel.sessionsByWeek[week] ?? [];

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Semana $week',
                                style: GoogleFonts.montserrat(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF0E382C),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.redAccent,
                                ),
                                onPressed: () => viewModel.removeWeek(week),
                              ),
                            ],
                          ),
                          const Divider(),

                          ...sessionsInWeek.map((session) {
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              elevation: 1,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ExpansionTile(
                                initiallyExpanded: true,
                                tilePadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 4,
                                ),
                                backgroundColor: Colors.white,
                                collapsedBackgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),

                                // --- BOTÕES ALINHADOS AQUI ---
                                title: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        session.name,
                                        style: GoogleFonts.montserrat(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.edit_outlined,
                                        size: 20,
                                        color: Colors.grey,
                                      ),
                                      onPressed: () => _showRenameDialog(
                                        context,
                                        viewModel,
                                        session.id,
                                        session.name,
                                      ),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                    const SizedBox(width: 12),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        size: 20,
                                        color: Colors.redAccent,
                                      ),
                                      onPressed: () =>
                                          viewModel.removeSession(session.id),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                  ],
                                ),

                                // Retiramos o "trailing" para a seta do ExpansionTile voltar ao normal
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Text(
                                    '${session.exercises.length} exercícios',
                                    style: GoogleFonts.openSans(
                                      color: Colors.grey.shade600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                children: [
                                  if (session.exercises.isEmpty)
                                    Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Text(
                                        "Sessão vazia. Adicione exercícios.",
                                        style: GoogleFonts.openSans(
                                          fontStyle: FontStyle.italic,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                  ...session.exercises.asMap().entries.map((
                                    entry,
                                  ) {
                                    final exerciseIndex = entry.key;
                                    final exercise = entry.value;
                                    return ListTile(
                                      leading: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF4F7F6),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.fitness_center,
                                          size: 18,
                                          color: Color(0xFF0E382C),
                                        ),
                                      ),
                                      title: Text(
                                        exercise['title'] ?? 'Exercício',
                                        style: GoogleFonts.montserrat(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                      subtitle: Text(
                                        exercise['subtitle'] ?? '',
                                        style: GoogleFonts.openSans(
                                          fontSize: 12,
                                        ),
                                      ),
                                      trailing: IconButton(
                                        icon: const Icon(
                                          Icons.close,
                                          size: 18,
                                          color: Colors.grey,
                                        ),
                                        onPressed: () =>
                                            viewModel.removeExerciseFromSession(
                                              session.id,
                                              exerciseIndex,
                                            ),
                                      ),
                                    );
                                  }),
                                  Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: SizedBox(
                                      width: double.infinity,
                                      child: OutlinedButton.icon(
                                        onPressed: () async {
                                          final result =
                                              await Navigator.pushNamed(
                                                context,
                                                '/add-exercise-to-protocol',
                                                arguments: {'patientId': ''},
                                              );
                                          if (result != null &&
                                              result is Map<String, dynamic>) {
                                            viewModel.addExerciseToSession(
                                              session.id,
                                              result,
                                            );
                                          }
                                        },
                                        icon: const Icon(Icons.add, size: 18),
                                        label: const Text(
                                          "Adicionar Exercício",
                                        ),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: const Color(
                                            0xFF0E382C,
                                          ),
                                          side: const BorderSide(
                                            color: Color(0xFF0E382C),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),

                          Padding(
                            padding: const EdgeInsets.only(
                              top: 8.0,
                              bottom: 24.0,
                            ),
                            child: Center(
                              child: TextButton.icon(
                                onPressed: () =>
                                    viewModel.addSessionToWeek(week),
                                icon: const Icon(
                                  Icons.add_circle_outline,
                                  color: Color(0xFF0E382C),
                                ),
                                label: Text(
                                  "Adicionar Sessão à Semana $week",
                                  style: GoogleFonts.openSans(
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF0E382C),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              bool added = viewModel.addWeek();
              if (!added && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Limite atingido! O protocolo só comporta ${viewModel.maxWeeks} semana(s).',
                    ),
                    backgroundColor: Colors.orange.shade800,
                  ),
                );
              }
            },
            backgroundColor: const Color(0xFF0E382C),
            icon: const Icon(Icons.add, color: Colors.white),
            label: Text(
              "Nova Semana",
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        );
      },
    );
  }
}
