import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SpecialistSelector extends StatelessWidget {
  final List<String> selectedNames;
  final VoidCallback onTap;

  const SpecialistSelector({
    super.key,
    required this.selectedNames,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF4F7F6),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade400),
        ),
        child: Row(
          children: [
            const Icon(Icons.group_add, color: Color(0xFF0E382C)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                selectedNames.isEmpty
                    ? 'Adicionar Especialistas Colaboradores'
                    : '${selectedNames.length} colaborador(es) selecionado(s)',
                style: GoogleFonts.openSans(
                  color: selectedNames.isEmpty
                      ? Colors.grey[700]
                      : Colors.black87,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
