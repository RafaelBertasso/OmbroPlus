import 'package:Ombro_Plus/components/app.logo.dart';
import 'package:Ombro_Plus/components/exercise.card.dart';
import 'package:Ombro_Plus/components/mini.metric.card.dart';
import 'package:Ombro_Plus/components/unread.messages.summary.dart';
import 'package:Ombro_Plus/models/daily.exercise.data.dart';
import 'package:Ombro_Plus/models/dashboard.data.dart';
import 'package:Ombro_Plus/services/dashboard.service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:Ombro_Plus/components/patient.navbar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class PatientHomePage extends StatefulWidget {
  const PatientHomePage({super.key});

  @override
  State<PatientHomePage> createState() => _PatientHomePageState();
}

class _PatientHomePageState extends State<PatientHomePage> {
  final int _selectedIndex = 0;
  String? _currentUserId = FirebaseAuth.instance.currentUser?.uid;
  Future<DailyExerciseData?>? _exercisesOfTheDay;
  Future<DashboardData?>? _dashboardFuture;

  final DashboardService _dashboardService = DashboardService();

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
      default:
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    _exercisesOfTheDay = _fetchDailyExercises();

    if (_currentUserId != null) {
      _dashboardFuture = _dashboardService.fetchDashboardData(_currentUserId!);
    } else {
      _dashboardFuture = Future.value(null);
    }
  }

  String _getTodayKey() {
    return DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  Future<Set<String>> _fetchCompletedExercisesToday(
    String protocolId,
    String userId,
  ) async {
    final todayKey = _getTodayKey();

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('logs_exercicios')
          .where('protocoloId', isEqualTo: protocolId)
          .where('pacienteId', isEqualTo: userId)
          .where('data', isEqualTo: todayKey)
          .get();

      return snapshot.docs
          .map((doc) {
            return doc.data()['exercicioId'] as String?;
          })
          .where((id) => id != null && id.isNotEmpty)
          .map((id) => id!)
          .toSet();
    } catch (e) {
      print('Erro ao buscar logs do exercício: $e');
      return {};
    }
  }

  Future<DailyExerciseData?> _fetchDailyExercises() async {
    final uid = _currentUserId;

    if (uid == null) return null;

    final todayKey = _getTodayKey();

    try {
      final protocolSnapshot = await FirebaseFirestore.instance
          .collection('protocolos')
          .where('pacienteId', isEqualTo: uid)
          .where('status', isEqualTo: 'active')
          .limit(1)
          .get();

      if (protocolSnapshot.docs.isEmpty) return null;

      final protocolDoc = protocolSnapshot.docs.first;
      final protocolId = protocolDoc.id;
      final protocolData = protocolSnapshot.docs.first.data();
      final rawSchedule = protocolData['schedule'];

      if (rawSchedule == null ||
          rawSchedule is! Map ||
          !rawSchedule.containsKey(todayKey)) {
        return null;
      }

      final dailyExercises = (rawSchedule[todayKey] as List<dynamic>)
          .map((e) => e as Map<String, dynamic>)
          .toList();

      final completedIds = await _fetchCompletedExercisesToday(protocolId, uid);

      return DailyExerciseData(
        protocolId: protocolId,
        exercises: dailyExercises,
        completedExerciseIds: completedIds,
      );
    } catch (e) {
      print('Erro ao buscar dados diários: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF4F7F6),
      body: Column(
        children: [
          AppLogo(),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 8,
                  top: 10,
                  right: 18,
                  bottom: 10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Exercícios do dia',
                        style: GoogleFonts.montserrat(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    SizedBox(
                      height: 180,
                      child: FutureBuilder<DailyExerciseData?>(
                        future: _exercisesOfTheDay,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFF0E382C),
                              ),
                            );
                          }
                          final dailyData = snapshot.data;
                          if (snapshot.hasError ||
                              dailyData == null ||
                              dailyData.exercises.isEmpty) {
                            return Center(
                              child: Text(
                                'Nenhum exercício agendado para hoje.',
                                style: GoogleFonts.openSans(
                                  color: Colors.black54,
                                ),
                              ),
                            );
                          }

                          final exercises = snapshot.data!.exercises;

                          return ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: exercises.length,
                            itemBuilder: (context, index) {
                              final exercise = exercises[index];
                              final exerciseId =
                                  exercise['exercicioId'] as String;

                              final isCompleted = dailyData.completedExerciseIds
                                  .contains(exerciseId);
                              return Padding(
                                padding: EdgeInsets.only(right: 10),
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
                                      setState(() {
                                        _exercisesOfTheDay =
                                            _fetchDailyExercises();
                                        _dashboardFuture = _dashboardService
                                            .fetchDashboardData(
                                              _currentUserId!,
                                            );
                                      });
                                    });
                                  },
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 30),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Dashboard',
                        style: GoogleFonts.montserrat(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 15),
                    FutureBuilder<DashboardData?>(
                      future: _dashboardFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const SizedBox(
                            height: 100,
                            child: Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFF0E382C),
                              ),
                            ),
                          );
                        }

                        final dashboardData = snapshot.data;
                        final completed = dashboardData?.sessoesConcluidas ?? 0;
                        final total = dashboardData?.totalSessions ?? 0;
                        final adherence =
                            dashboardData?.weeklyAdherence ??
                            {for (var i = 0; i <= 6; i++) i: 0.0};

                        final progressPercent = total == 0
                            ? 0
                            : (completed / total * 100).round();
                        final daysAdhered = adherence.values
                            .where((v) => v > 0.0)
                            .length;
                        const totalDays = 7;

                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            MiniMetricCard(
                              title: 'Progresso Total',
                              value: '$progressPercent',
                              subValue: '%',
                              color: Colors.black,
                            ),
                            SizedBox(width: 10),
                            MiniMetricCard(
                              title: 'Adesão Semanal',
                              value: '$daysAdhered/$totalDays',
                              subValue: 'dias',
                              color: Colors.black,
                            ),
                          ],
                        );
                      },
                    ),
                    SizedBox(height: 30),
                    UnreadMessagesSummary(),
                  ],
                ),
              ),
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
}
