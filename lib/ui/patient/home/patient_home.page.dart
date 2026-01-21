import 'package:Ombro_Plus/components/app.logo.dart';
import 'package:Ombro_Plus/components/exercise.card.dart';
import 'package:Ombro_Plus/components/mini.metric.card.dart';
import 'package:Ombro_Plus/components/patient.navbar.dart';
import 'package:Ombro_Plus/components/unread.messages.summary.dart';
import 'package:Ombro_Plus/viewmodels/patient_home.viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

class PatientHomePage extends StatefulWidget {
  const PatientHomePage({super.key});

  @override
  State<PatientHomePage> createState() => _PatientHomePageState();
}

class _PatientHomePageState extends State<PatientHomePage> {
  final int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PatientHomeViewModel>().loadHomeData();
    });
  }

  void _onTabTapped(BuildContext context, int index) {
    if (index == _selectedIndex) return;
    switch (index) {
      case 1:
        Navigator.pushReplacementNamed(context, '/patient-dashboard');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      body: Column(
        children: [
          const AppLogo(),

          Expanded(
            child: Consumer<PatientHomeViewModel>(
              builder: (context, viewModel, child) {
                if (viewModel.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF0E382C)),
                  );
                }

                final dailyData = viewModel.dailyExerciseData;
                final dashboardData = viewModel.dashboardData;

                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Exercícios do dia',
                        style: GoogleFonts.montserrat(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),

                      SizedBox(
                        height: 180,
                        child:
                            (dailyData == null || dailyData.exercises.isEmpty)
                            ? Center(
                                child: Text(
                                  'Nenhum exercício agendado para hoje.',
                                  style: GoogleFonts.openSans(
                                    color: Colors.black54,
                                  ),
                                ),
                              )
                            : ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: dailyData.exercises.length,
                                itemBuilder: (context, index) {
                                  final exercise = dailyData.exercises[index];
                                  final exerciseId =
                                      exercise['exercicioId'] as String;
                                  final isCompleted = dailyData
                                      .completedExerciseIds
                                      .contains(exerciseId);

                                  return Padding(
                                    padding: const EdgeInsets.only(right: 10),
                                    child: ExerciseCard(
                                      title: exercise['title'].toString(),
                                      subtitle:
                                          '${exercise['series']} séries x ${exercise['repeticoes']} repetições',
                                      isCompleted: isCompleted,
                                      onTap: () {
                                        Navigator.pushNamed(
                                          context,
                                          '/exercise-details',
                                          arguments: {
                                            'protocoloId': dailyData.protocolId,
                                            'exercicioId': exerciseId,
                                            'allDailyExercises':
                                                dailyData.exercises,
                                          },
                                        ).then((_) {
                                          viewModel.loadHomeData();
                                        });
                                      },
                                    ),
                                  );
                                },
                              ),
                      ),

                      const SizedBox(height: 30),

                      Text(
                        'Dashboard',
                        style: GoogleFonts.montserrat(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 15),

                      _buildDashboardSummary(dashboardData),

                      const SizedBox(height: 30),

                      UnreadMessagesSummary(),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: PatientNavbar(
        currentIndex: _selectedIndex,
        onTap: (index) => _onTabTapped(context, index),
      ),
    );
  }

  Widget _buildDashboardSummary(dynamic dashboardData) {
    if (dashboardData == null) return const SizedBox.shrink();

    final completed = dashboardData.sessoesConcluidas ?? 0;
    final total = dashboardData.totalSessions ?? 0;
    final progressPercent = total == 0
        ? 0
        : ((completed / total) * 100).round();

    final Map<int, double> adherence = dashboardData.weeklyAdherence ?? {};
    final daysAdhered = adherence.values.where((v) => v > 0.0).length;

    return Row(
      children: [
        MiniMetricCard(
          title: 'Progresso Total',
          value: '$progressPercent',
          subValue: '%',
          color: Colors.black,
        ),
        const SizedBox(width: 10),
        MiniMetricCard(
          title: 'Adesão Semanal',
          value: '$daysAdhered/7',
          subValue: 'dias',
          color: Colors.black,
        ),
      ],
    );
  }
}
