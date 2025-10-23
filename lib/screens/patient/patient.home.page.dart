import 'package:Ombro_Plus/components/app.logo.dart';
import 'package:Ombro_Plus/components/exercise.card.dart';
import 'package:Ombro_Plus/components/unread.messages.summary.dart';
import 'package:Ombro_Plus/models/daily.exercise.data.dart';
import 'package:Ombro_Plus/models/protocol.services.dart';
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
  String? _currentUserId;
  Future<DailyExerciseData?>? _exercisesOfTheDay;

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
    _currentUserId = FirebaseAuth.instance.currentUser?.uid;
    _exercisesOfTheDay = _fetchDailyExercises();
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
          .map((doc) => doc.data()['exercicioId'] as String)
          .toSet();
    } catch (e) {
      print('Erro ao buscar logs do exercício: $e');
      return {};
    }
  }

  Future<void> _toggleExerciseCompletion(
    String protocolId,
    String exerciseId,
    List<Map<String, dynamic>> allDailyExercises,
  ) async {
    final userId = _currentUserId;
    if (userId == null) return;

    final todayKey = _getTodayKey();
    final logCollection = FirebaseFirestore.instance.collection(
      'logs_exercicios',
    );

    final docRef = logCollection.doc();
    await docRef.set({
      'protocoloId': protocolId,
      'pacienteId': userId,
      'exercicioId': exerciseId,
      'data': todayKey,
      'concluido': true,
      'timestamp': FieldValue.serverTimestamp(),
    });

    final currentLogs = await _fetchCompletedExercisesToday(protocolId, userId);

    if (currentLogs.length == allDailyExercises.length) {
      final success = await ProtocolServices().markSessionCompleted(
        protocolId,
        userId,
      );
      if (success) {
        SnackBar(
          content: Text('Sessão diária COMPLETA! Progresso atualizado'),
          backgroundColor: Colors.green,
        );
      }
    }
    setState(() {
      _exercisesOfTheDay = _fetchDailyExercises();
    });
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
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.grey,
                          ),
                          width: 150,
                          height: 100,
                          child: Center(child: Text('Card 1')),
                        ),
                        SizedBox(width: 10),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.grey,
                          ),
                          width: 150,
                          height: 100,
                          child: Center(child: Text('Card 2')),
                        ),
                      ],
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
