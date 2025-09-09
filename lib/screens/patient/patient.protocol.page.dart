import 'package:Ombro_Plus/components/app.logo.dart';
import 'package:Ombro_Plus/components/patient.navbar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PatientProtocolPage extends StatefulWidget {
  const PatientProtocolPage({super.key});

  @override
  State<PatientProtocolPage> createState() => _PatientProtocolPageState();
}

class _PatientProtocolPageState extends State<PatientProtocolPage> {
  final int _selectedIndex = 2;
  final List<Map<String, dynamic>> dailyExercises = [
    {'nome': 'Exercício 1', 'series': 3, 'repeticoes': 10},
    {'nome': 'Exercício 2', 'series': 4, 'repeticoes': 15},
    {'nome': 'Exercício 3', 'series': 2, 'repeticoes': 20},
    {'nome': 'Exercício 4', 'series': 3, 'repeticoes': 12},
    {'nome': 'Exercício 5', 'series': 5, 'repeticoes': 8},
  ];
  final double progress = 0.6;
  void _onTabTapped(BuildContext context, int index) {
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
                        'Meu Protocolo Atual',
                        style: GoogleFonts.montserrat(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      ),
                    ),
                    SizedBox(height: 30),
                    Container(
                      padding: EdgeInsets.all(16),
                      margin: EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
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
                                  'Tipo protocolo',
                                  style: GoogleFonts.montserrat(
                                    color: Colors.grey[700],
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text.rich(
                                  TextSpan(
                                    text: 'Nome do Protocolo\n',
                                    style: GoogleFonts.montserrat(
                                      color: Colors.black,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: 'Descrição breve do protocolo',
                                        style: GoogleFonts.montserrat(
                                          color: Colors.grey[700],
                                          fontSize: 14,
                                          fontWeight: FontWeight.normal,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 12),
                                SizedBox(
                                  height: 32,
                                  width: 80,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      //TODO: Implementar ação
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xFF0E382C),
                                      foregroundColor: Colors.black,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(24),
                                      ),
                                      elevation: 0,
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 18,
                                        vertical: 0,
                                      ),
                                    ),
                                    child: Text(
                                      'Ver',
                                      style: GoogleFonts.montserrat(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              'assets/images/shoulder.png',
                              height: 70,
                              width: 70,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 30),
                    Text(
                      'Exercícios de hoje',
                      style: GoogleFonts.montserrat(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    dailyExercises.isEmpty
                        ? Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Text(
                              'Sem exercícios no dia de hoje',
                              style: GoogleFonts.montserrat(
                                color: Colors.grey,
                                fontSize: 16,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          )
                        : ListView.separated(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: dailyExercises.length,
                            separatorBuilder: (_, __) => SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final ex = dailyExercises[index];
                              return Material(
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.white,
                                child: ListTile(
                                  leading: Container(
                                    padding: EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: Color(0xFF0E382C),
                                    ),
                                    child: Icon(
                                      Icons.fitness_center,
                                      size: 26,
                                      color: Color.fromARGB(255, 255, 255, 255),
                                    ),
                                  ),
                                  title: Text(
                                    ex['nome'] ?? '',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  subtitle: Text(
                                    '${ex['series'] ?? ''} séries de ${ex['repeticoes'] ?? ''} repetições',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 14,
                                      fontWeight: FontWeight.normal,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  trailing: Icon(
                                    Icons.chevron_right_rounded,
                                    color: Colors.grey,
                                  ),
                                  onTap: () {
                                    //TODO: Implementar ação ao tocar no exercício
                                  },
                                ),
                              );
                            },
                          ),
                    SizedBox(height: 30),
                    Text(
                      'Progresso',
                      style: GoogleFonts.montserrat(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Progressão do protocolo atual',
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        color: Colors.black87,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 8,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF0E382C),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      '${(progress * 100).round()}%',
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
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
