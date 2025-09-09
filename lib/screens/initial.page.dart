import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:Ombro_Plus/screens/doctor/doctor.home.page.dart';
import 'package:Ombro_Plus/screens/patient/patient.home.page.dart';
import 'package:Ombro_Plus/screens/login.page.dart';

class InitialPage extends StatelessWidget {
  final String apiKey;
  InitialPage({super.key, required this.apiKey});
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> getUserRole() async {
    final user = _auth.currentUser;
    if (user == null) {
      return 'deslogado';
    }

    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data();
        return data?['role'];
      }
    } catch (e) {
      print('Erro ao buscar a role do usuário: $e');
    }
    return 'cliente';
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
        if (!snapshot.hasData) {
          return LoginPage();
        }
        final role = snapshot.data;
        if (role == 'especialista') {
          return DoctorHomePage(apiKey: apiKey);
        } else if (role == 'paciente') {
          return PatientHomePage();
        } else {
          return LoginPage();
        }
      },
    );
  }
}
