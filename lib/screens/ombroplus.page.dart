import 'package:Ombro_Plus/screens/doctor/doctor.chat.page.dart';
import 'package:Ombro_Plus/screens/doctor/doctor.main.chat.page.dart';
import 'package:Ombro_Plus/screens/doctor/doctor.profile.page.dart';
import 'package:Ombro_Plus/screens/doctor/doctor.protocols.page.dart';
import 'package:flutter/material.dart';
import 'package:Ombro_Plus/screens/login.page.dart';
import 'package:Ombro_Plus/screens/doctor/doctor.dashboard.page.dart';
import 'package:Ombro_Plus/screens/doctor/doctor.home.page.dart';
import 'package:Ombro_Plus/screens/forgot.password.page.dart';
import 'package:Ombro_Plus/screens/register.page.dart';

class OmbroPlus extends StatelessWidget {
  const OmbroPlus({super.key});

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
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
