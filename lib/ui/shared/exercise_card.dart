import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ExerciseCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isCompleted;
  final VoidCallback? onTap;
  final String? imageAsset; // ✅ Imagem configurável

  const ExerciseCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.isCompleted = false,
    this.onTap,
    this.imageAsset, // ✅ Opcional
  });

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF0E382C);
    final cardColor = isCompleted ? const Color(0xFFE0F2E8) : Colors.white;

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
          boxShadow: const [
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
            // ✅ Imagem do exercício
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  child: Image.asset(
                    imageAsset ??
                        'assets/images/exercicio.jpg', // ✅ Default ou customizado
                    height: 80,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      // ✅ Fallback se imagem não existir
                      return Container(
                        height: 80,
                        color: Colors.grey[300],
                        child: const Icon(
                          Icons.fitness_center,
                          size: 40,
                          color: Colors.grey,
                        ),
                      );
                    },
                  ),
                ),

                // ✅ Overlay de exercício completo
                if (isCompleted)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(
                          0.7,
                        ), // ✅ Mais opaco para destaque
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.check_circle, // ✅ Check circle é mais claro
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            // ✅ Informações do exercício
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

                  // ✅ Ícone indicador
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Icon(
                      Icons
                          .arrow_forward_ios_rounded, // ✅ Sempre seta (indicador de "toque aqui")
                      color: isCompleted
                          ? primaryColor.withOpacity(
                              0.6,
                            ) // ✅ Mais suave quando completo
                          : Colors.grey[600],
                      size: 16,
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
