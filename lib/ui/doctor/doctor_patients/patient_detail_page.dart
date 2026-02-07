import 'dart:convert';
import 'package:Ombro_Plus/viewmodels/doctor/patient_details_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class PatientDetailPage extends StatefulWidget {
  const PatientDetailPage({super.key});

  @override
  State<PatientDetailPage> createState() => _PatientDetailPageState();
}

class _PatientDetailPageState extends State<PatientDetailPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      final patientId = args?['patientId'] as String?;

      if (patientId != null) {
        context.read<PatientDetailsViewModel>().loadPatientData(patientId);
      }
    });
  }

  Widget _buildAvatar(PatientDetailsViewModel viewModel) {
    final patient = viewModel.patient;
    if (patient?.profileImage != null) {
      try {
        final bytes = base64Decode(patient!.profileImage!);
        return ClipOval(
          child: Image.memory(bytes, width: 76, height: 76, fit: BoxFit.cover),
        );
      } catch (_) {}
    }

    return Text(
      viewModel.patientInitials,
      style: GoogleFonts.montserrat(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  Widget _buildAccessLogSection(List<DateTime> sessionDays) {
    return Card(
      color: Color(0xFFF4F7F6),
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sessões Concluídas',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            sessionDays.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: const Text(
                      'Nenhuma sessão registrada ainda.',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.grey,
                      ),
                    ),
                  )
                : SizedBox(
                    height: 200,
                    child: ListView.builder(
                      itemCount: sessionDays.length,
                      itemBuilder: (context, index) {
                        final date = sessionDays[index];
                        final formatter = DateFormat(
                          'dd \'de\' MMMM \'de\' yyyy',
                          'pt_BR',
                        );

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.check_circle,
                                color: Color(0xFF0E382C),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                formatter.format(date),
                                style: GoogleFonts.openSans(fontSize: 16),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0E382C),
        elevation: 0.4,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white, size: 26),
        title: Text(
          'Acompanhamento',
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: Consumer<PatientDetailsViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF0E382C)),
            );
          }

          if (viewModel.error != null) {
            return Center(child: Text(viewModel.error!));
          }

          final patient = viewModel.patient;
          if (patient == null) {
            return const Center(child: Text("Dados não disponíveis."));
          }

          final activeProtocol = viewModel.activeProtocol;
          // Placeholder para diagnóstico se não existir no model ainda
          // Você pode adicionar 'diagnostico' no PatientModel se quiser
          const String mainDiagnosis = 'Ficha não preenchida';

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
            children: [
              // Cabeçalho com Avatar
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 15, bottom: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 38,
                            backgroundColor: const Color(0xFF0E382C),
                            child: _buildAvatar(viewModel),
                          ),
                          const SizedBox(width: 18),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  patient.nome,
                                  style: GoogleFonts.montserrat(
                                    fontSize: 21,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  mainDiagnosis,
                                  style: GoogleFonts.openSans(
                                    fontSize: 16,
                                    color: Colors.black54,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Botão Editar
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(
                              163,
                              183,
                              183,
                              183,
                            ),
                            side: const BorderSide(color: Colors.white),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: () {
                            // Navegar para edição (pode precisar de refatoração futura)
                            Navigator.pushNamed(
                              context,
                              '/patient-edit-profile',
                              arguments: {
                                'name': patient.nome,
                                'id': patient.id,
                              },
                            ).then(
                              (_) => viewModel.loadPatientData(patient.id),
                            );
                          },
                          child: Text(
                            'Editar Dados Pessoais',
                            style: GoogleFonts.montserrat(
                              fontSize: 16,
                              color: Colors.black87,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Botão Ficha Clínica
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0E382C),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          icon: const Icon(
                            Icons.description_outlined,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              '/patient-clinical-form',
                              arguments: {'id': patient.id},
                            );
                          },
                          label: Text(
                            'Ficha Clínica',
                            style: GoogleFonts.montserrat(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // Seção de Protocolo Ativo
              Text(
                'Estágio Atual',
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),
              const SizedBox(height: 10),

              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F7F6),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 17,
                  vertical: 16,
                ),
                child: activeProtocol == null
                    ? Text(
                        'Nenhum protocolo ativo encontrado',
                        style: GoogleFonts.openSans(
                          fontSize: 15,
                          color: Colors.black54,
                        ),
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFF4F7F6),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.all(8),
                            child: const Icon(
                              Icons.list,
                              color: Colors.black,
                              size: 25,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  activeProtocol.nome,
                                  style: GoogleFonts.montserrat(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.black87,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Início: ${DateFormat('dd/MM/yyyy').format(activeProtocol.dataInicio)}',
                                  style: GoogleFonts.openSans(
                                    fontSize: 15,
                                    color: Colors.black54,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pushNamed(
                                      context,
                                      '/protocol-details', // Rota de detalhes do médico
                                      arguments: {
                                        'protocoloId': activeProtocol.id,
                                      },
                                    );
                                  },
                                  child: Text(
                                    'Ver Cronograma',
                                    style: GoogleFonts.openSans(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF0E382C),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
              ),

              const SizedBox(height: 24),

              // Seção de Logs
              Text(
                'Acessos',
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),
              const SizedBox(height: 9),
              _buildAccessLogSection(viewModel.completedSessionDays),
            ],
          );
        },
      ),
    );
  }
}
