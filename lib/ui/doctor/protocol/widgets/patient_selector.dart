import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PatientSelector extends StatelessWidget {
  final String? selectedName;
  final VoidCallback onTap;

  const PatientSelector({
    super.key,
    required this.selectedName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasSelection = selectedName != null;

    return OutlinedButton.icon(
      onPressed: onTap,
      icon: const Icon(Icons.person_search, color: Color(0xFF0E382C)),
      label: Text(
        hasSelection ? 'Paciente: $selectedName' : 'Selecionar Paciente',
        style: GoogleFonts.montserrat(
          fontWeight: FontWeight.w600,
          color: hasSelection ? Colors.black : Colors.black54,
          fontSize: 16,
        ),
      ),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        padding: const EdgeInsets.symmetric(vertical: 14),
        side: BorderSide(
          color: hasSelection ? const Color(0xFF0E382C) : Colors.redAccent,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
