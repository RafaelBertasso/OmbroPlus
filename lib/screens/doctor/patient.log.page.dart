import 'package:Ombro_Plus/components/log.card.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PatientLogPage extends StatelessWidget {
  PatientLogPage({super.key});
  final logs = [
    LogCard(activity: 'Atividade 1', date: DateTime(2025, 8, 10, 19, 30)),
    LogCard(activity: 'Atividade 2', date: DateTime(2025, 7, 29, 20, 54)),
    LogCard(activity: 'Atividade 3', date: DateTime(2025, 7, 28, 18, 45)),
    LogCard(activity: 'Atividade 4', date: DateTime(2025, 5, 27, 17, 30)),
    LogCard(activity: 'Atividade 5', date: DateTime(2025, 2, 26, 16, 15)),
    LogCard(activity: 'Atividade 6', date: DateTime(2025, 8, 25, 15, 0)),
    LogCard(activity: 'Atividade 7', date: DateTime(2025, 1, 24, 13, 45)),
    LogCard(activity: 'Atividade 8', date: DateTime(2025, 3, 23, 12, 30)),
    LogCard(activity: 'Atividade 9', date: DateTime(2025, 7, 22, 11, 15)),
    LogCard(activity: 'Atividade 10', date: DateTime(2025, 2, 21, 10, 0)),
    LogCard(activity: 'Atividade 11', date: DateTime(2025, 5, 20, 8, 45)),
    LogCard(activity: 'Atividade 12', date: DateTime(2025, 3, 19, 7, 30)),
    LogCard(activity: 'Atividade 13', date: DateTime(2025, 2, 18, 6, 15)),
    LogCard(activity: 'Atividade 14', date: DateTime(2025, 2, 17, 5, 0)),
  ];

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final patientName = args != null && args['name'] != null
        ? args['name'] as String
        : 'Paciente';
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0E382C),
        title: Text(
          'Registro de Atividades',
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white, size: 26),
        elevation: 0.4,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Paciente: $patientName',
                  style: GoogleFonts.openSans(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: logs.length,
              itemBuilder: (context, index) {
                return logs[index];
              },
            ),
          ],
        ),
      ),
    );
  }
}
