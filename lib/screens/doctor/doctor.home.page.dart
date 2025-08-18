import 'package:Ombro_Plus/components/doctor.navbar.dart';
import 'package:Ombro_Plus/components/feature.card.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DoctorHomePage extends StatefulWidget {
  const DoctorHomePage({super.key});

  @override
  State<DoctorHomePage> createState() => _DoctorHomePageState();
}

class _DoctorHomePageState extends State<DoctorHomePage> {
  final int _selectedIndex = 0;

  void _onTabTapped(int index) {
    if (index == _selectedIndex) return;
    switch (index) {
      case 1:
        Navigator.pushReplacementNamed(context, '/doctor-dashboard');
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
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
                  Positioned(
                    right: 0,
                    top: 30,
                    child: IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.settings, color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsetsGeometry.symmetric(
                  horizontal: 18.0,
                  vertical: 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bem vindo, [Nome do Médico]',
                      style: GoogleFonts.montserrat(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF0E382C),
                              minimumSize: Size(0, 48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadiusGeometry.circular(8),
                              ),
                            ),
                            onPressed: () {},
                            child: Text(
                              'Nova sessão',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color.fromARGB(
                                112,
                                145,
                                228,
                                205,
                              ),
                              minimumSize: Size(0, 48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadiusGeometry.circular(8),
                              ),
                            ),
                            onPressed: () =>
                                Navigator.pushNamed(context, '/patient-list'),
                            child: Text(
                              'Pacientes',
                              style: TextStyle(color: Color(0xFF0E382C)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 60),
                    Text(
                      'Funcionalidades Principais',
                      style: GoogleFonts.montserrat(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 18),
                    FeatureCard(
                      title: 'Avaliar progresso',
                      description:
                          'Monitore a recuperação dos pacientes com métricas detalhadas e relatórios visuais.',
                      icon: Icons.bar_chart,
                      color: Color.fromARGB(255, 255, 255, 255),
                      onTap: () {},
                    ),
                    SizedBox(height: 10),
                    FeatureCard(
                      title: 'Planos customizados',
                      description:
                          'Acesse protocolos baseados em evidências para reabilitação.',
                      icon: Icons.assignment_turned_in,
                      color: Color.fromARGB(255, 255, 255, 255),
                      onTap: () {},
                    ),
                    SizedBox(height: 10),
                    FeatureCard(
                      title: 'Gerenciar pacientes',
                      description:
                          'Gerencie perfis, evoluções e protocolos dos pacientes.',
                      icon: Icons.people_alt,
                      color: Color.fromARGB(255, 255, 255, 255),
                      onTap: () {},
                    ),
                  ],
                ),
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
