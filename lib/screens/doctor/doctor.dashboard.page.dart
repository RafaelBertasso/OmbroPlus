import 'package:Ombro_Plus/components/app.logo.dart';
import 'package:Ombro_Plus/components/doctor.navbar.dart';
import 'package:Ombro_Plus/components/metric.card.dart';
import 'package:Ombro_Plus/components/patient.dropdown.dart';
import 'package:Ombro_Plus/models/dashboard.data.dart';
import 'package:Ombro_Plus/services/dashboard.service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DoctorDashboardPage extends StatefulWidget {
  const DoctorDashboardPage({super.key});

  @override
  State<DoctorDashboardPage> createState() => _DoctorDashboardPageState();
}

class _DoctorDashboardPageState extends State<DoctorDashboardPage> {
  final int _selectedIndex = 1;

  final String? _specialistUid = FirebaseAuth.instance.currentUser?.uid;
  final DashboardService _dashboardService = DashboardService();

  Future<List<Map<String, String>>>? _patientListFuture;
  Future<DashboardData?>? _selectedPatientDataFuture;

  String? selectedPatientId;
  String? selectedPatientName;

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

  @override
  void initState() {
    super.initState();
    if (_specialistUid != null) {
      _patientListFuture = _dashboardService.fetchSpecialistPatients(
        _specialistUid,
      );
    }
  }

  void _fetchSelectedPatientData(String patientId) {
    setState(() {
      selectedPatientId = patientId;
      _selectedPatientDataFuture = _dashboardService.fetchPatientDataForDoctor(
        patientId,
      );
    });
  }

  Widget _buildPatientProgressChart(int completed, int total) {
    final progress = total == 0 ? 0.0 : (completed / total).clamp(0.0, 1.0);
    final percent = (progress * 100).round();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Progresso do Protocolo: $percent %',
            style: GoogleFonts.montserrat(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress.toDouble(),
              minHeight: 12,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                percent == 100
                    ? Colors.green.shade500
                    : const Color(0xFF0E382C),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$completed de $total sessões concluídas.',
            style: GoogleFonts.openSans(fontSize: 14, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientAdherenceChart(Map<int, double> adherenceData) {
    final List<BarChartGroupData> barGroups = List.generate(7, (index) {
      final yValue = adherenceData[index] ?? 0.0;
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: yValue,
            width: 12,
            color: yValue > 0 ? const Color(0xFF0E382C) : Colors.grey.shade400,
            borderRadius: BorderRadius.circular(4),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: 1.0,
              color: Colors.grey.shade200,
            ),
          ),
        ],
      );
    });

    String getDayLabelForChart(double value) {
      final days = ['SEG', 'TER', 'QUA', 'QUI', 'SEX', 'SÁB', 'DOM'];
      return days[value.toInt()];
    }

    return SizedBox(
      height: 180,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: 1.0,
            barTouchData: BarTouchData(enabled: false),
            titlesData: FlTitlesData(
              show: true,
              rightTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    return SideTitleWidget(
                      meta: meta,
                      space: 4,
                      child: Text(
                        getDayLabelForChart(value),
                        style: GoogleFonts.openSans(
                          fontSize: 10,
                          color: Colors.black87,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            gridData: FlGridData(show: false),
            borderData: FlBorderData(show: false),
            barGroups: barGroups,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activePatientsCountFuture = _patientListFuture?.then(
      (list) => list.length,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      body: Column(
        children: [
          AppLogo(),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Visão Geral',
                    style: GoogleFonts.montserrat(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      FutureBuilder<int>(
                        future: activePatientsCountFuture,
                        builder: (context, snapshot) {
                          final count = snapshot.data ?? 0;
                          return MetricCard(
                            title: 'Pacientes Ativos',
                            value: count.toString(),
                          );
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  Text(
                    'Análise Individual',
                    style: GoogleFonts.montserrat(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 16),
                  FutureBuilder<List<Map<String, String>>>(
                    future: _patientListFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF0E382C),
                          ),
                        );
                      }
                      if (snapshot.hasError ||
                          snapshot.data == null ||
                          snapshot.data!.isEmpty) {
                        final errorMessage = snapshot.hasError
                            ? 'Erro ao carregar pacientes'
                            : 'Nenhum paciente ativo';
                        return PatientDropdown(
                          selectedPatient: null,
                          onPatientSelected: (id) {},
                          items: [
                            DropdownMenuItem<String>(
                              value: '',
                              enabled: false,
                              child: Text(
                                errorMessage,
                                style: GoogleFonts.montserrat(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                          ],
                        );
                      }

                      final patientList = snapshot.data!;
                      final dropdownItems = patientList.map((patient) {
                        return DropdownMenuItem<String>(
                          value: patient['id'],
                          child: Text(
                            patient['nome']!,
                            style: GoogleFonts.openSans(),
                          ),
                        );
                      }).toList();

                      return PatientDropdown(
                        selectedPatient: selectedPatientId,
                        onPatientSelected: (String? id) {
                          if (id != null && id.isNotEmpty) {
                            final name = patientList.firstWhere(
                              (p) => p['id'] == id,
                            )['nome'];
                            setState(() {
                              selectedPatientName = name;
                            });
                            _fetchSelectedPatientData(id);
                          }
                        },
                        items: dropdownItems,
                      );
                    },
                  ),
                  SizedBox(height: 28),

                  selectedPatientId == null
                      ? Center(
                          child: Text(
                            'Selecione um paciente acima para visualizar as métricas detalhadas.',
                            style: GoogleFonts.openSans(color: Colors.black54),
                            textAlign: TextAlign.center,
                          ),
                        )
                      : FutureBuilder<DashboardData?>(
                          future: _selectedPatientDataFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            final data = snapshot.data;
                            if (data == null || data.totalSessions == 0) {
                              return Text(
                                'Protocolo não encontrado ou não iniciado para ${selectedPatientName ?? 'este paciente'}.',
                              );
                            }

                            final completed = data.sessoesConcluidas;
                            final total = data.totalSessions;
                            final adherence =
                                data.weeklyAdherence ??
                                {for (var i = 0; i <= 6; i++) i: 0.0};

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Status do Protocolo',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 12),
                                _buildPatientProgressChart(completed, total),
                                SizedBox(height: 18),
                                Text(
                                  'Adesão Semanal',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 12),
                                _buildPatientAdherenceChart(adherence),
                              ],
                            );
                          },
                        ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: DoctorNavbar(
        currentIndex: _selectedIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}
