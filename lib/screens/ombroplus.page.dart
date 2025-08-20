import 'package:Ombro_Plus/screens/doctor/doctor.chat.page.dart';
import 'package:Ombro_Plus/screens/doctor/doctor.main.chat.page.dart';
import 'package:Ombro_Plus/screens/doctor/doctor.profile.page.dart';
import 'package:Ombro_Plus/screens/doctor/doctor.protocols.page.dart';
import 'package:Ombro_Plus/screens/doctor/new.exercise.page.dart';
import 'package:Ombro_Plus/screens/doctor/new.protocol.page.dart';
import 'package:Ombro_Plus/screens/doctor/patient.detail.page.dart';
import 'package:Ombro_Plus/screens/doctor/patient.list.page.dart';
import 'package:Ombro_Plus/screens/doctor/patient.log.page.dart';
import 'package:Ombro_Plus/screens/patient/patient.home.page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:Ombro_Plus/screens/login.page.dart';
import 'package:Ombro_Plus/screens/doctor/doctor.dashboard.page.dart';
import 'package:Ombro_Plus/screens/doctor/doctor.home.page.dart';
import 'package:Ombro_Plus/screens/forgot.password.page.dart';
import 'package:Ombro_Plus/screens/register.page.dart';

class OmbroPlus extends StatelessWidget {
  OmbroPlus({super.key});
  final _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginPage(),
      routes: {
        '/login': (context) => LoginPage(),
        '/register': (context) => RegisterPage(),
        '/forgot-password': (context) => ForgotPasswordPage(),
        '/doctor-home': (context) => DoctorHomePage(),
        '/doctor-dashboard': (context) => DoctorDashboardPage(),
        '/doctor-protocols': (context) => DoctorProtocolsPage(),
        '/doctor-main-chat': (context) => DoctorMainChatPage(),
        '/doctor-profile': (context) => DoctorProfilePage(),
        '/chat-detail': (context) => DoctorChatPage(),
        '/patient-list': (context) => PatientListPage(),
        '/patient-detail': (context) => PatientDetailPage(),
        '/patient-home': (context) => PatientHomePage(),
        '/patient-log': (context) => PatientLogPage(),
        '/new-protocol': (context) => NewProtocolPage(),
        '/new-exercise': (context) => NewExercisePage(),
      },
      initialRoute: _auth.currentUser == null ? '/login' : '/doctor-home',
      debugShowCheckedModeBanner: false,
    );
  }
}
