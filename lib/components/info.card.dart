import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InfoCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const InfoCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Color(0xFFF4F7F6),
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Color(0xFF2A5C7D)),
        title: Text(
          label,
          style: GoogleFonts.openSans(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(value, style: GoogleFonts.openSans(fontSize: 15)),
      ),
    );
  }
}
