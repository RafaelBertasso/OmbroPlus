import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MetricLargeCard extends StatelessWidget {
  final String title;
  final String value;
  const MetricLargeCard({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 6),
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          Text(
            title,
            style: GoogleFonts.openSans(fontSize: 13, color: Colors.black54),
          ),
          SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.montserrat(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
