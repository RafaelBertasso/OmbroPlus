import 'package:flutter/material.dart';
import 'package:flutter_app_tg/components/doctor.navbar.dart';

class DoctorDashboardPage extends StatefulWidget {
  const DoctorDashboardPage({super.key});

  @override
  State<DoctorDashboardPage> createState() => _DoctorDashboardPageState();
}

class _DoctorDashboardPageState extends State<DoctorDashboardPage> {
  int _selectedIndex = 1;
  String? selectedPatient;
  final List<String> patients = ['Patient 1', 'Patient 2', 'Patient 3'];

  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Aqui você pode adicionar lógica para navegar para diferentes páginas
    // dependendo do índice selecionado, se necessário.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      body: Text('oi'),
      bottomNavigationBar: DoctorNavbar(
        currentIndex: _selectedIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}
