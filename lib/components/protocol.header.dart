import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProtocolHeader extends StatelessWidget {
  final String name;
  final String status;
  const ProtocolHeader({super.key, required this.name, required this.status});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            name,
            style: GoogleFonts.montserrat(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0E382C),
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: status == 'Ativo'
                ? Colors.green.shade100
                : Colors.red.shade100,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            status,
            style: GoogleFonts.openSans(
              color: status == 'Ativo'
                  ? Colors.green.shade800
                  : Colors.red.shade800,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}
