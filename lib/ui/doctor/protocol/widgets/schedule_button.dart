import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ScheduleButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool hasItems;

  const ScheduleButton({
    super.key,
    required this.onPressed,
    required this.hasItems,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(
          hasItems ? Icons.check_circle : Icons.calendar_month,
          color: hasItems ? Colors.green[800] : Colors.black,
        ),
        label: Text(
          hasItems
              ? 'Editar Cronograma (Itens adicionados)'
              : 'Criar Cronogama',
          style: GoogleFonts.openSans(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.black,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: hasItems
              ? const Color(0xFFE0F2E8)
              : const Color(0xFFE0E0E0),
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}
