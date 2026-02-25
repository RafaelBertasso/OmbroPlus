import 'package:Ombro_Plus/models/protocol_model.dart';
import 'package:Ombro_Plus/repositories/protocol_repository.dart';
import 'package:Ombro_Plus/ui/patient/home/session_execution_page.dart';
import 'package:Ombro_Plus/ui/patient/protocol/widgets/protocol_dates_section.dart';
import 'package:Ombro_Plus/ui/patient/protocol/widgets/protocol_header.dart';
import 'package:Ombro_Plus/ui/patient/protocol/widgets/protocol_notes_section.dart';
import 'package:Ombro_Plus/ui/shared/widgets/section_title.dart';
import 'package:Ombro_Plus/viewmodels/shared/protocol_details_viewmodel.dart';
import 'package:Ombro_Plus/viewmodels/patient/session_execution_viewmodel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class PatientProtocolDetailsPage extends StatefulWidget {
  final String protocolId;
  const PatientProtocolDetailsPage({super.key, required this.protocolId});

  @override
  State<PatientProtocolDetailsPage> createState() =>
      _PatientProtocolDetailsPageState();
}

class _PatientProtocolDetailsPageState
    extends State<PatientProtocolDetailsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        context.read<ProtocolDetailsViewModel>().loadProtocolData(
          widget.protocolId,
          userId,
        );
      }
    });
  }

  Widget _buildExercisesList(List<Map<String, dynamic>> exercises) {
    if (exercises.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(child: Text('Nenhum exercício nesta sessão.')),
      );
    }

    return Column(
      children: exercises
          .map(
            (ex) => ListTile(
              dense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 0,
              ),
              leading: const Icon(
                Icons.circle,
                color: Color(0xFF0E382C),
                size: 8,
              ),
              title: Text(
                ex['title'] ?? 'Exercício',
                style: GoogleFonts.openSans(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              subtitle: Text(
                '${ex['series']} séries x ${ex['repeticoes']} repetições',
                style: GoogleFonts.openSans(fontSize: 12),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildSessionsTree(
    List<ProtocolSession> sessions,
    Set<String> completedSessionIds,
    String protocolId,
  ) {
    if (sessions.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text("Nenhuma sessão definida."),
      );
    }

    // 1. Agrupa as sessões por semana
    final sessionsByWeek = <int, List<ProtocolSession>>{};
    for (var session in sessions) {
      if (!sessionsByWeek.containsKey(session.semana)) {
        sessionsByWeek[session.semana] = [];
      }
      sessionsByWeek[session.semana]!.add(session);
    }

    // 2. Ordena as semanas (Semana 1, Semana 2...)
    final weeks = sessionsByWeek.keys.toList()..sort();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(title: 'Cronograma do Tratamento'),
        const SizedBox(height: 16),

        // 3. Renderiza o bloco de cada semana
        ...weeks.map((week) {
          final weekSessions = sessionsByWeek[week]!;

          return Padding(
            padding: const EdgeInsets.only(bottom: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cabeçalho da Semana
                Text(
                  'Semana $week',
                  style: GoogleFonts.montserrat(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0E382C),
                  ),
                ),
                const Divider(),
                const SizedBox(height: 8),

                // Sessões daquela semana
                ...weekSessions.map((session) {
                  final isCompleted = completedSessionIds.contains(session.id);

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: isCompleted
                          ? const BorderSide(color: Colors.green, width: 1.5)
                          : BorderSide.none,
                    ),
                    child: ExpansionTile(
                      // Abre automaticamente a primeira sessão pendente
                      initiallyExpanded:
                          !isCompleted &&
                          session ==
                              weekSessions.firstWhere(
                                (s) => !completedSessionIds.contains(s.id),
                                orElse: () => weekSessions.first,
                              ),
                      tilePadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      backgroundColor: Colors.white,
                      collapsedBackgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      leading: CircleAvatar(
                        backgroundColor: isCompleted
                            ? Colors.green.withOpacity(0.1)
                            : const Color(0xFF0E382C).withOpacity(0.1),
                        child: Icon(
                          isCompleted ? Icons.check : Icons.fitness_center,
                          color: isCompleted
                              ? Colors.green
                              : const Color(0xFF0E382C),
                          size: 20,
                        ),
                      ),
                      title: Text(
                        session.name,
                        style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      subtitle: Text(
                        '${session.exercises.length} exercícios',
                        style: GoogleFonts.openSans(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      children: [
                        const Divider(height: 1),
                        _buildExercisesList(session.exercises),
                        const SizedBox(height: 12),

                        // Botão de Ação
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: SizedBox(
                            width: double.infinity,
                            child: isCompleted
                                ? Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.check_circle,
                                          color: Colors.green,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          "Sessão Concluída",
                                          style: GoogleFonts.openSans(
                                            color: Colors.green,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : ElevatedButton.icon(
                                    onPressed: () async {
                                      // Navega para a tela de Execução da Sessão!
                                      final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              ChangeNotifierProvider(
                                                create: (_) =>
                                                    SessionExecutionViewmodel(
                                                      repository: context
                                                          .read<
                                                            ProtocolRepository
                                                          >(),
                                                    )..loadCompletedExercises(
                                                      protocolId,
                                                    ),
                                                child: SessionExecutionPage(
                                                  protocolId: protocolId,
                                                  session: session,
                                                ),
                                              ),
                                        ),
                                      );

                                      // Se voltou com "true" (concluiu), recarrega a tela de detalhes
                                      if (result == true && context.mounted) {
                                        final userId = FirebaseAuth
                                            .instance
                                            .currentUser
                                            ?.uid;
                                        if (userId != null) {
                                          context
                                              .read<ProtocolDetailsViewModel>()
                                              .loadProtocolData(
                                                protocolId,
                                                userId,
                                              );
                                        }
                                      }
                                    },
                                    icon: const Icon(
                                      Icons.play_arrow,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    label: const Text(
                                      "Começar Sessão",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF0E382C),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          );
        }),
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
          'Detalhes do Protocolo',
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white, size: 24),
        elevation: 0,
        centerTitle: true,
      ),
      body: Consumer<ProtocolDetailsViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }

          if (viewModel.error != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  viewModel.error!,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(color: Colors.red),
                ),
              ),
            );
          }
          final protocol = viewModel.protocol;

          if (protocol == null) {
            return const Center(child: Text('Protocolo não encontrado.'));
          }

          final String status = protocol.status == 'active'
              ? 'Ativo'
              : 'Finalizado';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProtocolHeader(name: protocol.nome, status: status),
                const SizedBox(height: 16),

                ProtocolDatesSection(
                  endDate: protocol.dataFim,
                  startDate: protocol.dataInicio,
                ),
                const SizedBox(height: 24),

                ProtocolNotesSection(notes: protocol.notas),

                if (protocol.materialUrl != null &&
                    protocol.materialUrl!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: InkWell(
                      onTap: () async {
                        final String urlString = protocol.materialUrl!;
                        final Uri? url = Uri.tryParse(urlString);

                        if (url != null) {
                          try {
                            if (await canLaunchUrl(url)) {
                              await launchUrl(
                                url,
                                mode: LaunchMode.externalApplication,
                              );
                            } else {
                              throw Exception('Não é possível abrir o link');
                            }
                          } catch (e) {
                            Clipboard.setData(
                              ClipboardData(text: protocol.materialUrl!),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Link copiado para a área de transferência! Cole no navegador.',
                                ),
                              ),
                            );
                          }
                        }
                      },
                      child: Row(
                        children: [
                          Icon(Icons.link, color: Colors.blue[800]),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Text(
                              "Acessar Material de Apoio (PDF/Drive)",
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                // Lista de Sessões atualizada usando a nova árvore de semanas!
                _buildSessionsTree(
                  protocol.sessoes,
                  viewModel.completedSessionIds,
                  protocol.id!,
                ),

                const SizedBox(height: 50),
              ],
            ),
          );
        },
      ),
    );
  }
}
