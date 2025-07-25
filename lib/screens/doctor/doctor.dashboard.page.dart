import 'package:Ombro_Plus/components/app.logo.dart';
import 'package:Ombro_Plus/components/doctor.navbar.dart';
import 'package:Ombro_Plus/components/metric.card.dart';
import 'package:Ombro_Plus/components/metric.large.card.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DoctorDashboardPage extends StatefulWidget {
  const DoctorDashboardPage({super.key});

  @override
  State<DoctorDashboardPage> createState() => _DoctorDashboardPageState();
}

class _DoctorDashboardPageState extends State<DoctorDashboardPage> {
  final int _selectedIndex = 1;
  String? selectedPatient;
  final List<String> patients = ['Patient 1', 'Patient 2', 'Patient 3'];

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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      body: Column(
        children: [
          AppLogo(),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Métricas Principais',
                    style: GoogleFonts.montserrat(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      MetricCard(title: 'Pacientes Ativos', value: '25'),
                      SizedBox(width: 16),
                      MetricCard(title: 'Duração Média', value: '15 min'),
                    ],
                  ),
                  SizedBox(height: 12),
                  MetricLargeCard(title: 'Redução de Dor', value: '30%'),
                  SizedBox(height: 18),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 13, vertical: 6),
                    decoration: BoxDecoration(
                      border: Border.all(color: Color(0xFFD9E3E8)),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.white,
                    ),
                    child: DropdownButton<String>(
                      isExpanded: true,
                      hint: const Text('Selecione o Paciente'),
                      value: selectedPatient,
                      underline: SizedBox(),
                      items: patients.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value, style: GoogleFonts.openSans()),
                        );
                      }).toList(),
                      onChanged: (value) => setState(() {
                        selectedPatient = value;
                      }),
                    ),
                  ),
                  SizedBox(height: 28),
                  // Placeholder: Gráfico de evolução
                  Container(
                    height: 140,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Color(0xFFE3E8EE),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Gráfico de Evolução\n(placeholder)',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.openSans(color: Colors.black54),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Placeholder: Score de Dor
                  Container(
                    height: 100,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Color(0xFFE3E8EE),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Escala de Dor\n(placeholder)',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.openSans(color: Colors.black54),
                    ),
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
