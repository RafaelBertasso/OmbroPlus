import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:Ombro_Plus/screens/doctor/doctor.home.page.dart';
import 'package:Ombro_Plus/screens/patient/patient.home.page.dart';
import 'package:Ombro_Plus/screens/login.page.dart';

class InitialPage extends StatelessWidget {
  InitialPage({super.key});
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> getUserRole() async {
    final user = _auth.currentUser;
    if (user == null) {
      return 'deslogado';
    }

    try {
      final specialistDoc = await FirebaseFirestore.instance
          .collection('especialistas')
          .doc(user.uid)
          .get();
      if (specialistDoc.exists) {
        return 'especialista';
      }

      final patientDoc = await FirebaseFirestore.instance
          .collection('pacientes')
          .doc(user.uid)
          .get();
      if (patientDoc.exists) {
        return 'paciente';
      }
    } catch (e) {
      print('Erro ao buscar a role do usuário: $e');
    }
    return 'deslogado';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: getUserRole(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFF0E382C)),
            ),
          );
        }
        final role = snapshot.data;
        if (role == 'especialista') {
          return DoctorHomePage();
        } else if (role == 'paciente') {
          return PatientHomePage();
        } else {
          return LoginPage();
        }
      },
    );
  }
}
