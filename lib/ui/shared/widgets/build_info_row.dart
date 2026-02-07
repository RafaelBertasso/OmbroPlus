import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BuildInfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const BuildInfoRow({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Color(0xFF0E382C), size: 24),
          SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.openSans(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
              SizedBox(height: 4),
              Text(
                value,
                style: GoogleFonts.openSans(
                  fontSize: 16,
                  color: Colors.black54,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
