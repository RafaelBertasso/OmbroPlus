import 'package:Ombro_Plus/screens/doctor.register.page.dart';
import 'package:Ombro_Plus/screens/doctor/doctor.chat.page.dart';
import 'package:Ombro_Plus/screens/doctor/doctor.edit.profile.page.dart';
import 'package:Ombro_Plus/screens/doctor/doctor.main.chat.page.dart';
import 'package:Ombro_Plus/screens/doctor/doctor.profile.page.dart';
import 'package:Ombro_Plus/screens/doctor/doctor.protocols.page.dart';
import 'package:Ombro_Plus/screens/doctor/new.exercise.page.dart';
import 'package:Ombro_Plus/screens/doctor/new.protocol.page.dart';
import 'package:Ombro_Plus/screens/doctor/patient.detail.page.dart';
import 'package:Ombro_Plus/screens/doctor/patient.list.page.dart';
import 'package:Ombro_Plus/screens/doctor/patient.log.page.dart';
import 'package:Ombro_Plus/screens/initial.page.dart';
import 'package:Ombro_Plus/screens/patient.register.page.dart';
import 'package:Ombro_Plus/screens/patient/patient.chat.page.dart';
import 'package:Ombro_Plus/screens/patient/patient.dashboard.page.dart';
import 'package:Ombro_Plus/screens/patient/patient.home.page.dart';
import 'package:Ombro_Plus/screens/patient/patient.main.chat.page.dart';
import 'package:Ombro_Plus/screens/patient/patient.profile.page.dart';
import 'package:Ombro_Plus/screens/patient/patient.protocol.page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:Ombro_Plus/screens/login.page.dart';
import 'package:Ombro_Plus/screens/doctor/doctor.dashboard.page.dart';
import 'package:Ombro_Plus/screens/doctor/doctor.home.page.dart';
import 'package:Ombro_Plus/screens/forgot.password.page.dart';

class OmbroPlus extends StatelessWidget {
  OmbroPlus({super.key});
  final _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/': (context) => InitialPage(),
        '/login': (context) => LoginPage(),
        '/patient-register': (context) => PatientRegisterPage(),
        '/specialist-register': (context) => DoctorRegisterPage(),
        '/doctor-edit-profile': (context) => DoctorEditProfilePage(),
        '/forgot-password': (context) => ForgotPasswordPage(),
        '/doctor-home': (context) => DoctorHomePage(),
        '/doctor-dashboard': (context) => DoctorDashboardPage(),
        '/doctor-protocols': (context) => DoctorProtocolsPage(),
        '/doctor-main-chat': (context) => DoctorMainChatPage(),
        '/doctor-profile': (context) => DoctorProfilePage(),
        '/chat-detail': (context) => DoctorChatPage(),
        '/patient-list': (context) => PatientListPage(),
        '/patient-detail': (context) => PatientDetailPage(),
        '/patient-log': (context) => PatientLogPage(),
        '/new-protocol': (context) => NewProtocolPage(),
        '/new-exercise': (context) => NewExercisePage(),
        '/patient-home': (context) => PatientHomePage(),
        '/patient-dashboard': (context) => PatientDashboardPage(),
        '/patient-protocols': (context) => PatientProtocolPage(),
        '/patient-main-chat': (context) => PatientMainChatPage(),
        '/patient-profile': (context) => PatientProfilePage(),
        '/patient-chat': (context) => PatientChatPage(),
      },
      initialRoute: _auth.currentUser == null ? '/login' : '/',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        inputDecorationTheme: InputDecorationTheme(
          labelStyle: TextStyle(color: Color(0xFF0E382C)),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF0E382C), width: 2),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
        ),
      ),
    );
  }
}
