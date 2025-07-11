import 'package:flutter/material.dart';
import 'package:flutter_app_tg/screens/login.page.dart';
import 'package:flutter_app_tg/screens/register.page.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginPage(),
      routes: {
        '/login': (context) => LoginPage(),
        '/register' : (context) => RegisterPage(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}