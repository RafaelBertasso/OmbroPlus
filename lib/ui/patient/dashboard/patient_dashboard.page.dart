import 'package:Ombro_Plus/components/app.logo.dart';
import 'package:Ombro_Plus/components/graphic.card.dart';
import 'package:Ombro_Plus/components/navbar.dart';
import 'package:Ombro_Plus/viewmodels/patient/dashboard_patient.viewmodel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class PatientDashboardPage extends StatefulWidget {
  const PatientDashboardPage({super.key});

  @override
  State<PatientDashboardPage> createState() => _PatientDashboardPageState();
}

class _PatientDashboardPageState extends State<PatientDashboardPage> {
  final int _selectedIndex = 1;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        context.read<DashboardPatientViewModel>().loadData(userId);
      }
    });
  }

  void _onTabTapped(int index) {
    if (index == _selectedIndex) return;
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/patient-home');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/patient-protocols');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/patient-main-chat');
        break;
      case 4:
        Navigator.pushReplacementNamed(context, '/patient-profile');
        break;
    }
  }

  Widget _buildProgressChart(int completed, int total) {
    if (total == 0) {
      return Center(
        child: Text(
          'Nenhum protocolo ativo.',
          style: GoogleFonts.openSans(color: Colors.grey[700]),
        ),
      );
    }
    final progress = (completed / total).clamp(0.0, 1.0);
    final percent = (progress * 100).round();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Progresso Total: $percent%',
            style: GoogleFonts.montserrat(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
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
          SizedBox(height: 8),
          Text(
            '$completed de $total sessões concluídas.',
            style: GoogleFonts.openSans(fontSize: 14, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart(Map<int, double> adherenceData) {
    final List<BarChartGroupData> barGroups = List.generate(7, (index) {
      final yValue = adherenceData[index] ?? 0.0;
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: yValue,
            width: 12,
            color: yValue > 0 ? Color(0xFF0E382C) : Colors.grey.shade400,
            borderRadius: BorderRadius.circular(4),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: 1.0,
              color: Colors.grey.shade200,
            ),
          ),
        ],
        showingTooltipIndicators: [],
      );
    });

    String getDayLabelForChart(double value) {
      const days = ['SEG', 'TER', 'QUA', 'QUI', 'SEX', 'SÁB', 'DOM'];
      final intIndex = value.toInt();
      if (intIndex >= 0 && intIndex < days.length) {
        return days[intIndex];
      }
      return '';
    }

    return SizedBox(
      height: 120,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 1.0,
          minY: 0.0,
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      body: Column(
        children: [
          const AppLogo(),
          Expanded(
            child: Consumer<DashboardPatientViewModel>(
              builder: (context, viewModel, child) {
                if (viewModel.isLoading) {
                  return Center(
                    child: CircularProgressIndicator(color: Color(0xFF0E382C)),
                  );
                }

                final data = viewModel.data;
                final totalSessions = data?.totalSessions ?? 0;
                final completedSessions = data?.sessoesConcluidas ?? 0;
                final adherence = data?.weeklyAdherence ?? {};

                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 10,
                    ).copyWith(left: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Minha evolução',
                            style: GoogleFonts.montserrat(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(height: 25),

                        GraphicCard(
                          title: 'Status do Protocolo',
                          values: const [],
                          content: _buildProgressChart(
                            completedSessions,
                            totalSessions,
                          ),
                        ),
                        SizedBox(height: 25),

                        GraphicCard(
                          title: 'Adesão Semanal',
                          values: const [],
                          content: _buildBarChart(adherence),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: Navbar(
        currentIndex: _selectedIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}
