import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ExerciseCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isCompleted;
  final VoidCallback? onTap;
  const ExerciseCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.isCompleted = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = isCompleted ? Color(0xFFE0F2E8) : Colors.white;
    final textColor = isCompleted ? Colors.white : Colors.black;
    final iconColor = isCompleted ? Colors.white : Color(0xFF0E382C);
    final primaryColor = Color(0xFF0E382C);
    final shadowColor = isCompleted ? Colors.green.shade100 : Colors.black12;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 150,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: isCompleted
              ? Border.all(color: primaryColor.withOpacity(0.5), width: 1)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  child: Image.asset(
                    'assets/images/exercicio.jpg',
                    height: 80,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                if (isCompleted)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.3),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                      ),
                      child: Center(
                        child: Icon(Icons.check, color: Colors.white, size: 36),
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 5, 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.montserrat(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: primaryColor,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          subtitle,
                          style: GoogleFonts.openSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Colors.black54,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Icon(
                      isCompleted
                          ? Icons.lock_outline
                          : Icons.arrow_forward_ios_rounded,
                      color: isCompleted
                          ? primaryColor.withOpacity(0.8)
                          : Colors.grey,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
