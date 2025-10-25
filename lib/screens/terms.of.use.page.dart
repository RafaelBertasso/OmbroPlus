import 'package:Ombro_Plus/models/terms.and.privacy.content.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TermsOfUsePage extends StatelessWidget {
  const TermsOfUsePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Termos de Uso e Privacidade',
          style: GoogleFonts.montserrat(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
        ),
        backgroundColor: Color(0xFF0E382C),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('1. Termos de Uso'),
            _buildParagraph(TermsAndPrivacyContent.termsOfUse),

            SizedBox(height: 20),

            _buildSectionTitle('2. Política de Privacidade'),
            _buildParagraph(TermsAndPrivacyContent.privacyPolicy),

            SizedBox(height: 20),

            _buildSectionTitle('3. Aviso Legal'),
            _buildParagraph(
              TermsAndPrivacyContent.medicalDisclaimer,
              isDisclaimer: true,
            ),
            SizedBox(height: 40),
            Center(
              child: Text(
                'Última atualização: ${TermsAndPrivacyContent.lastUpdated}',
                style: GoogleFonts.openSans(fontSize: 12, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 10),
      child: Text(
        title,
        style: GoogleFonts.montserrat(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF0E382C),
        ),
      ),
    );
  }

  Widget _buildParagraph(String text, {bool isDisclaimer = false}) {
    return Text(
      text,
      textAlign: isDisclaimer ? TextAlign.center : TextAlign.justify,
      style: GoogleFonts.openSans(
        fontSize: 14,
        height: 1.5,
        color: isDisclaimer ? Colors.red[800] : Colors.black87,
        fontWeight: isDisclaimer ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}
