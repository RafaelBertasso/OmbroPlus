import 'package:Ombro_Plus/components/exercise.card.dart';
import 'package:flutter/material.dart';
import 'package:Ombro_Plus/components/patient.navbar.dart';
import 'package:google_fonts/google_fonts.dart';

class PatientHomePage extends StatelessWidget {
  const PatientHomePage({super.key});
  final int _selectedIndex = 0;

  void _onTabTapped(BuildContext context, int index) {
    if (index == _selectedIndex) return;
    switch (index) {
      case 1:
        Navigator.pushReplacementNamed(context, '/patient-dashboard');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/patient-protocol');
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF4F7F6),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 18, bottom: 8),
            child: SizedBox(
              height: 100,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Center(
                    child: Image.asset(
                      'assets/images/logo-app.png',
                      width: 100,
                      height: 100,
                    ),
                  ),
                ],
              ),
            ),
          ),
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
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          ExerciseCard(
                            title: 'Exercício 1',
                            subtitle: 'Descrição do exercício 1',
                            onTap: () {},
                          ),
                          ExerciseCard(
                            title: 'Exercício 2',
                            subtitle: 'Descrição do exercício 2',
                          ),
                          ExerciseCard(
                            title: 'Exercício 3',
                            subtitle: 'Descrição do exercício 3',
                          ),
                          ExerciseCard(
                            title: 'Exercício 4',
                            subtitle: 'Descrição do exercício 4',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/login'),
        child: Icon(Icons.arrow_back),
      ),
      bottomNavigationBar: PatientNavbar(
        currentIndex: _selectedIndex,
        onTap: (index) => _onTabTapped(context, index),
      ),
    );
  }
}
