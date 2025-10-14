import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ConfigTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  const ConfigTile({
    super.key,
    required this.icon,
    required this.onTap,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        color: Color(0xFFF4F7F6),
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: ListTile(
          leading: Icon(icon, color: Color(0xFF0E382C), size: 30),
          title: Text(
            title,
            style: GoogleFonts.openSans(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          trailing: Icon(
            Icons.arrow_forward_ios,
            size: 18,
            color: Colors.grey[400],
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}
