import 'package:Ombro_Plus/components/app.logo.dart';
import 'package:Ombro_Plus/components/exercise.card.dart';
import 'package:Ombro_Plus/components/unread.messages.summary.dart';
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
  Future<List<Map<String, dynamic>>>? _exercisesOfTheDay;

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

  Future<List<Map<String, dynamic>>> _fetchDailyExercises() async {
    final uid = _currentUserId;

    if (uid == null) return [];

    final todayKey = _getTodayKey();

    final protocolSnapshot = await FirebaseFirestore.instance
        .collection('protocolos')
        .where('pacienteId', isEqualTo: uid)
        .where('status', isEqualTo: 'active')
        .limit(1)
        .get();

    if (protocolSnapshot.docs.isEmpty) {
      return [];
    }

    final protocolData = protocolSnapshot.docs.first.data();
    final rawSchedule = protocolData['schedule'];

    if (rawSchedule == null || rawSchedule is! Map) {
      return [];
    }

    final schedule = (rawSchedule).map((k, v) => MapEntry(k.toString(), v));

    if (!schedule.containsKey(todayKey)) {
      return [];
    }

    final dailyExercises = schedule[todayKey];

    if (dailyExercises is! List) {
      return [];
    }

    return dailyExercises.map((e) => e as Map<String, dynamic>).toList();
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
                      child: FutureBuilder<List<Map<String, dynamic>>>(
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
                          if (snapshot.hasError ||
                              snapshot.data == null ||
                              snapshot.data!.isEmpty) {
                            return Center(
                              child: Text(
                                'Nenhum exercício agendado para hoje.',
                                style: GoogleFonts.openSans(
                                  color: Colors.black54,
                                ),
                              ),
                            );
                          }

                          final exercises = snapshot.data!;

                          return ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: exercises.length,
                            itemBuilder: (context, index) {
                              final exercise = exercises[index];
                              return Padding(
                                padding: EdgeInsetsGeometry.only(right: 10),
                                child: ExerciseCard(
                                  title: exercise['title'].toString(),
                                  subtitle:
                                      '${exercise['series']} séries x ${exercise['repeticoes']} repetições',
                                  onTap: () {},
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
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Mensagens',
                        style: GoogleFonts.montserrat(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
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
