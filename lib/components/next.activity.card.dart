import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NextActivityCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String buttonText;
  final VoidCallback onTapped;
  const NextActivityCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.buttonText = 'Começar Agora',
    required this.onTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.circular(16),
      ),
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      child: Padding(
        padding: EdgeInsetsGeometry.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.montserrat(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0E382C),
              ),
            ),
            SizedBox(height: 4),
            Text(
              subtitle,
              style: GoogleFonts.openSans(fontSize: 14, color: Colors.black54),
            ),
            SizedBox(height: 16),
            Align(
              alignment: AlignmentGeometry.centerRight,
              child: ElevatedButton.icon(
                onPressed: onTapped,
                icon: Icon(Icons.play_arrow_rounded, size: 20),
                label: Text(
                  buttonText,
                  style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Color(0xFF1B6A4C),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusGeometry.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
