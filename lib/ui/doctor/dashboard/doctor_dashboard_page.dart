import 'package:Ombro_Plus/ui/shared/widgets/app_logo.dart';
import 'package:Ombro_Plus/ui/shared/widgets/graphic_card.dart';
import 'package:Ombro_Plus/ui/shared/widgets/metric_card.dart';
import 'package:Ombro_Plus/ui/shared/widgets/navbar.dart';
import 'package:Ombro_Plus/ui/shared/widgets/section_title.dart';
import 'package:Ombro_Plus/models/dashboard_data.dart';
import 'package:Ombro_Plus/viewmodels/doctor/dashboard_doctor_viewmodel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class DoctorDashboardPage extends StatefulWidget {
  const DoctorDashboardPage({super.key});

  @override
  State<DoctorDashboardPage> createState() => _DoctorDashboardPageState();
}

class _DoctorDashboardPageState extends State<DoctorDashboardPage> {
  final int _selectedIndex = 1;
  String? _selectedPatientId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final specialistId = FirebaseAuth.instance.currentUser?.uid;
      if (specialistId != null) {
        context.read<DashboardDoctorViewModel>().loadMyPatients(specialistId);
      }
    });
  }

  void _onTabTapped(int index) {
    if (index == _selectedIndex) return;
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/doctor-home');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/doctor-protocols');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/doctor-main-chat');
        break;
      case 4:
        Navigator.pushReplacementNamed(context, '/doctor-profile');
        break;
      default:
        break;
    }
  }

  void _onPatientSelected(String? patientId) {
    if (patientId == null) return;

    setState(() {
      _selectedPatientId = patientId;
    });

    final specialistId = FirebaseAuth.instance.currentUser?.uid;
    if (specialistId != null) {
      context.read<DashboardDoctorViewModel>().loadPatientData(
        patientId,
        specialistId,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardDoctorViewModel>(
      builder: (context, viewModel, child) {
        final bool isValidSelection =
            _selectedPatientId != null &&
            viewModel.patients.any((p) => p['id'] == _selectedPatientId);
        final String? dropdownValue = isValidSelection
            ? _selectedPatientId
            : null;

        return Scaffold(
          backgroundColor: const Color(0xFFF4F7F6),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: AppLogo(padding: const EdgeInsets.all(0))),
                SectionTitle(title: 'Visão Geral do Paciente'),
                SizedBox(height: 15),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      hint: Text(
                        viewModel.isLoadingPatients
                            ? "Carregando pacientes..."
                            : "Selecione um paciente",
                        style: GoogleFonts.openSans(color: Colors.black54),
                      ),
                      value: dropdownValue,
                      items: viewModel.patients.map((p) {
                        return DropdownMenuItem<String>(
                          value: p['id'],
                          child: Text(
                            p['nome'] ?? 'Sem nome',
                            style: GoogleFonts.openSans(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: viewModel.isLoadingData
                          ? null
                          : _onPatientSelected,
                    ),
                  ),
                ),
                SizedBox(height: 25),

                if (viewModel.isLoadingData)
                  Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF0E382C),
                      ),
                    ),
                  )
                else if (viewModel.dashboardData == null)
                  _buildEmptyState()
                else
                  _buildDashboardContent(viewModel.dashboardData!),
              ],
            ),
          ),
          bottomNavigationBar: Navbar(
            currentIndex: _selectedIndex,
            onTap: _onTabTapped,
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 40),
        child: Column(
          children: [
            Icon(
              Icons.analytics_outlined,
              size: 60,
              color: Colors.grey.shade400,
            ),
            SizedBox(height: 16),
            Text(
              _selectedPatientId == null
                  ? "Selecione um paciente para ver o progresso."
                  : "Nenhum protocolo ativo encontrado para este paciente.",
              textAlign: TextAlign.center,
              style: GoogleFonts.openSans(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardContent(DashboardData data) {
    double progress = 0;
    if (data.totalSessions > 0) {
      progress = (data.sessoesConcluidas / data.totalSessions);
    }
    final percentageDisplay = (progress * 100).toStringAsFixed(0);
    final List<double> chartValues = List.generate(7, (index) {
      return data.weeklyAdherence?[index] ?? 0;
    });

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: MetricCard(
                title: 'Sessões Feitas',
                value: '${data.sessoesConcluidas}/${data.totalSessions}',
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: MetricCard(
                title: 'Progresso Total',
                value: '$percentageDisplay%',
              ),
            ),
          ],
        ),
        SizedBox(height: 20),

        GraphicCard(values: chartValues, title: 'Adesão Semanal'),

        SizedBox(height: 20),

        if (data.protocol != null)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(0xFFE0F2E8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Color(0xFF0E382C)),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "Protocolo Ativo: ${data.protocol!.nome}",
                    style: GoogleFonts.openSans(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0E382C),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
