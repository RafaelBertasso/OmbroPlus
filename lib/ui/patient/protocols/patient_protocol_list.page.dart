import 'package:Ombro_Plus/components/app.logo.dart';
import 'package:Ombro_Plus/components/navbar.dart';
import 'package:Ombro_Plus/viewmodels/patient/patient_protocols.viewmodel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class PatientProtocolPage extends StatefulWidget {
  const PatientProtocolPage({super.key});

  @override
  State<PatientProtocolPage> createState() => _PatientProtocolPageState();
}

class _PatientProtocolPageState extends State<PatientProtocolPage> {
  final int _selectedIndex = 2;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        context.read<PatientProtocolsViewModel>().loadActiveProtocol(userId);
      }
    });
  }

  void _onTabTapped(int index) {
    if (index == _selectedIndex) return;
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/patient-home');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/patient-dashboard');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/patient-main-chat');
        break;
      case 4:
        Navigator.pushReplacementNamed(context, '/patient-profile');
        break;
      default:
        break;
    }
  }

  Widget _buildScheduleDisplay(Set<int> scheduledDays) {
    if (scheduledDays.isEmpty) {
      return const Text(
        'Agenda não definida.',
        style: TextStyle(color: Colors.grey),
      );
    }

    const Map<int, String> dayLabels = {
      7: 'DOM',
      1: 'SEG',
      2: 'TER',
      3: 'QUA',
      4: 'QUI',
      5: 'SEX',
      6: 'SÁB',
    };

    final List<int> displayOrder = [7, 1, 2, 3, 4, 5, 6];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: displayOrder.map((weekday) {
        final label = dayLabels[weekday] ?? '?';
        final isActive = scheduledDays.contains(weekday);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFF0E382C) : Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                label,
                style: GoogleFonts.montserrat(
                  color: isActive ? Colors.white : Colors.black87,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      body: Consumer<PatientProtocolsViewModel>(
        builder: (context, viewModel, child) {
          return Column(
            children: [
              const AppLogo(),
              Expanded(child: _buildBody(viewModel)),
            ],
          );
        },
      ),
      bottomNavigationBar: Navbar(
        currentIndex: _selectedIndex,
        onTap: _onTabTapped,
      ),
    );
  }

  Widget _buildBody(PatientProtocolsViewModel viewModel) {
    if (viewModel.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF0E382C)),
      );
    }

    if (viewModel.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            viewModel.error!,
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(color: Colors.red),
          ),
        ),
      );
    }

    final protocol = viewModel.activeProtocol;

    if (protocol == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            'Nenhum protocolo ativo no momento. Aguarde as orientações do seu especialista.',
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(fontSize: 18, color: Colors.black54),
          ),
        ),
      );
    }

    // Preparar dados para exibição
    final notesDisplay = protocol.notas.length > 70
        ? '${protocol.notas.substring(0, 70)}...'
        : protocol.notas;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(8, 10, 18, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Meu Protocolo Atual',
              style: GoogleFonts.montserrat(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF333333),
              ),
            ),
          ),
          const SizedBox(height: 30),

          // --- Card Principal do Protocolo ---
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 16, left: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        protocol.nome,
                        style: GoogleFonts.montserrat(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notesDisplay.isEmpty ? 'Sem descrição.' : notesDisplay,
                        style: GoogleFonts.montserrat(
                          color: Colors.grey[700],
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: 120,
                        height: 32,
                        child: ElevatedButton(
                          onPressed: () {
                            // Navegar para detalhes (ajuste a rota se necessário)
                            Navigator.pushNamed(
                              context,
                              '/patient-protocol-details',
                              arguments: {'protocoloId': protocol.id},
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0E382C),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            padding: EdgeInsets.zero,
                          ),
                          child: Text(
                            'Ver Detalhes',
                            style: GoogleFonts.montserrat(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'assets/images/shoulder.png',
                    height: 90,
                    width: 90,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(left: 8.0, top: 16, bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Duração do Tratamento',
                  style: GoogleFonts.montserrat(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _buildDateRow(
                  Icons.calendar_month,
                  'Início',
                  protocol.dataInicio,
                ),
                const SizedBox(height: 8),
                _buildDateRow(Icons.event_available, 'Fim', protocol.dataFim),

                const SizedBox(height: 20),
                Text(
                  'Agenda Semanal:',
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                // Usa o getter computado do ViewModel!
                _buildScheduleDisplay(viewModel.scheduledWeekdays),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Progresso',
                  style: GoogleFonts.montserrat(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Progressão baseada nas sessões concluídas.',
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    color: Colors.black87,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: viewModel.progressValue,
                    minHeight: 8,
                    backgroundColor: Colors.grey[300],
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF0E382C),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '${viewModel.progressPercentage} (${protocol.sessoesConcluidas} de ${protocol.totalSessoesEstimadas} sessões).',
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildDateRow(IconData icon, String label, DateTime date) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF0E382C)),
        const SizedBox(width: 8),
        Text(
          '$label: ${DateFormat('dd/MM/yyyy').format(date)}',
          style: GoogleFonts.openSans(fontSize: 14),
        ),
      ],
    );
  }
}
