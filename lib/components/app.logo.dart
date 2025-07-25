import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 18, bottom: 8),
          child: SizedBox(
            height: 100,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Center(
                  child: Image.asset(
                    'assets/images/logo-app.png',
                    width: 100,
                    height: 100,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
