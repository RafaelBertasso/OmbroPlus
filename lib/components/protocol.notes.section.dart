import 'package:Ombro_Plus/components/section.title.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProtocolNotesSection extends StatelessWidget {
  final String notes;
  const ProtocolNotesSection({super.key, required this.notes});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(title: 'Notas e Instruções'),
        SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            notes,
            style: GoogleFonts.openSans(fontSize: 14, color: Colors.black87),
          ),
        ),
      ],
    );
  }
}
