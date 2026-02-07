import 'package:Ombro_Plus/ui/shared/widgets/section_title.dart';
import 'package:Ombro_Plus/viewmodels/shared/protocol_details_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ProtocolDetailsPage extends StatefulWidget {
  final String protocolId;

  const ProtocolDetailsPage({super.key, required this.protocolId});

  @override
  State<ProtocolDetailsPage> createState() => _ProtocolDetailsPageState();
}

class _ProtocolDetailsPageState extends State<ProtocolDetailsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProtocolDetailsViewModel>().loadProtocolDetails(
        widget.protocolId,
      );
    });
  }

  void _openScheduleViewer() {
    final viewModel = context.read<ProtocolDetailsViewModel>();
    if (viewModel.protocol == null) return;

    Navigator.pushNamed(
      context,
      '/protocol-schedule-viewer',
      arguments: {
        'protocolId': viewModel.protocol!.id,
        'startDate': viewModel.protocol!.dataInicio.toIso8601String(),
        'endDate': viewModel.protocol!.dataFim.toIso8601String(),
        'schedule': viewModel.protocol!.schedule,
      },
    );
  }

  Future<void> _confirmFinalize() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Finalizar Tratamento'),
        content: const Text(
          'Deseja realmente encerrar este protocolo?\n\n'
          'Essa ação não poderá ser desfeita e o paciente não terá mais acesso a estes exercícios.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Finalizar',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await context.read<ProtocolDetailsViewModel>().finalizeProtocol();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      appBar: AppBar(
        title: Text(
          'Detalhes do Protocolo',
          style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Consumer<ProtocolDetailsViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF0E382C)),
            );
          }

          final protocol = viewModel.protocol;
          final patient = viewModel.patientData;

          if (protocol == null) {
            return const Center(child: Text('Protocolo não encontrado'));
          }

          final isActive = protocol.status == 'active';
          final statusColor = isActive ? Colors.green : Colors.grey;
          final statusText = isActive ? 'Ativo' : 'Finalizado';

          final actionButtonText = isActive
              ? 'Finalizar Tratamento'
              : 'Reativar Tratamento';
          final actionButtonColor = isActive ? Colors.redAccent : Colors.green;
          final actionButtonIcon = isActive
              ? Icons.stop_circle_outlined
              : Icons.play_circle_outline;

          final startFormat = DateFormat(
            'dd/MM/yyyy',
          ).format(protocol.dataInicio);
          final endFormat = DateFormat('dd/MM/yyyy').format(protocol.dataFim);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black45,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 25,
                        backgroundColor: const Color(
                          0xFF0E382C,
                        ).withOpacity(0.1),
                        child: Icon(
                          Icons.person,
                          color: Color(0xFF0E382C),
                          size: 30,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              protocol.pacienteName,
                              style: GoogleFonts.montserrat(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            if (patient != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                patient['telefone'] ?? '',
                                style: GoogleFonts.openSans(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                SectionTitle(title: 'Informações do Tratamento'),
                const SizedBox(height: 10),

                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _buildInfoRow(Icons.title, 'Nome', protocol.nome),
                      const Divider(),
                      _buildInfoRow(
                        Icons.calendar_today,
                        'Início',
                        startFormat,
                      ),
                      const Divider(),
                      _buildInfoRow(
                        Icons.event_available,
                        'Fim Previsto',
                        endFormat,
                      ),
                      const Divider(),
                      _buildInfoRow(
                        Icons.fitness_center,
                        'Sessões',
                        '${protocol.sessoesConcluidas}/${protocol.totalSessoesEstimadas}',
                      ),
                      const Divider(),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.info_outline,
                              color: Color(0xFF0E381C),
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Status',
                              style: GoogleFonts.openSans(
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                statusText,
                                style: TextStyle(
                                  color: statusColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                if (protocol.notas.isNotEmpty) ...[
                  SectionTitle(title: 'Anotações'),
                  SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Color(0xFFFFF8E1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFFE082)),
                    ),
                    child: Text(
                      protocol.notas,
                      style: GoogleFonts.openSans(color: Colors.brown[800]),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton.icon(
                    onPressed: _openScheduleViewer,
                    icon: const Icon(Icons.calendar_month, color: Colors.white),
                    label: Text(
                      'Visualizar Cronograma',
                      style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0E382C),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadiusGeometry.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                if (isActive)
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: OutlinedButton.icon(
                      onPressed: _confirmFinalize,
                      icon: const Icon(
                        Icons.stop_circle_outlined,
                        color: Colors.redAccent,
                      ),
                      label: Text(
                        'Finalizar Tratamento',
                        style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.bold,
                          color: Colors.redAccent,
                          fontSize: 16,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: Colors.redAccent,
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  )
                else
                  // Se já estiver finalizado, mostramos um container informativo (opcional)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_circle, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text(
                          'Tratamento Encerrado',
                          style: GoogleFonts.openSans(
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Color(0xFF0E382C), size: 20),
          SizedBox(width: 12),
          Text(
            label,
            style: GoogleFonts.openSans(
              color: Colors.grey[600],
              fontWeight: FontWeight.w600,
            ),
          ),
          Spacer(),
          Text(
            value,
            style: GoogleFonts.openSans(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
