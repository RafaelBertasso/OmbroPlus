import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 8),
      child: Image.asset(
        'assets/images/logo-app.png',
        width: 100,
        height: 100,
        fit: BoxFit.contain,
      ),
    );
  }
}
