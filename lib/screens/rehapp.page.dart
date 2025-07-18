import 'package:flutter/material.dart';
import 'package:flutter_app_tg/screens/doctor/doctor.dashboard.page.dart';
import 'package:flutter_app_tg/screens/doctor/doctor.home.page.dart';
import 'package:flutter_app_tg/screens/forgot.password.page.dart';
import 'package:flutter_app_tg/screens/login.page.dart';
import 'package:flutter_app_tg/screens/register.page.dart';

class Rehapp extends StatelessWidget {
  const Rehapp({super.key});

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
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
