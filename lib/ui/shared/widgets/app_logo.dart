import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double? size; // ✅ Tamanho configurável
  final EdgeInsets? padding; // ✅ Padding configurável

  const AppLogo({super.key, this.size, this.padding});

  @override
  Widget build(BuildContext context) {
    final logoSize = size ?? 100; // ✅ Default 100

    return Padding(
      padding:
          padding ??
          const EdgeInsets.only(top: 18, bottom: 8), // ✅ Default padding
      child: Image.asset(
        'assets/images/logo-app.png',
        width: logoSize,
        height: logoSize,
        fit: BoxFit.contain, // ✅ Garante que a imagem não distorça
      ),
    );
  }
}
