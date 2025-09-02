import 'package:Ombro_Plus/components/patient.navbar.dart';
import 'package:flutter/material.dart';

class PatientProtocolPage extends StatefulWidget {
  const PatientProtocolPage({super.key});

  @override
  State<PatientProtocolPage> createState() => _PatientProtocolPageState();
}

class _PatientProtocolPageState extends State<PatientProtocolPage> {
  final int _selectedIndex = 2;
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
      body: const Center(
        child: Text('Patient Protocol Page - Under Construction'),
      ),
      bottomNavigationBar: PatientNavbar(
        currentIndex: _selectedIndex,
        onTap: (index) => _onTabTapped(context, index),
      ),
    );
  }
}
