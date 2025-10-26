import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/formatters/phone_input_formatter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class PatientInvitePage extends StatefulWidget {
  const PatientInvitePage({super.key});

  @override
  State<PatientInvitePage> createState() => _PatientInvitePageState();
}

class _PatientInvitePageState extends State<PatientInvitePage> {
  static const String appDistributionLink =
      'https://appdistribution.firebase.dev/i/6ec8547c38c84f04';

  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _patientNameController = TextEditingController();

  String? _inviteCode;
  String _loadMessage = 'Carregando código de convite...';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInviteCode();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _patientNameController.dispose();
    super.dispose();
  }

  String _generateInviteCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890';
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(
        6,
        (_) => chars.codeUnitAt(random.nextInt(chars.length)),
      ),
    );
  }

  Future<void> _loadInviteCode() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      if (mounted) {
        setState(() {
          _loadMessage = 'Erro: Especialista não logado';
          _isLoading = false;
          _inviteCode = 'ERRO';
        });
      }
      return;
    }

    final specialistRef = FirebaseFirestore.instance
        .collection('especialistas')
        .doc(currentUser.uid);
    final publicCodeRef = FirebaseFirestore.instance.collection(
      'invite_codes_public',
    );

    try {
      String? currentCode;

      final specialistDoc = await specialistRef.get();
      if (specialistDoc.exists) {
        currentCode = specialistDoc.data()?['invite_code'] as String?;
      }

      String finalCode = currentCode ?? _generateInviteCode();

      try {
        final publicDoc = await publicCodeRef.doc(finalCode).get();

        if (!publicDoc.exists) {
          await specialistRef.set({
            'invite_code': finalCode,
          }, SetOptions(merge: true));

          await publicCodeRef.doc(finalCode).set({
            'specialistId': currentUser.uid,
            'criadoEm': FieldValue.serverTimestamp(),
          });
          print('Código $finalCode sincronizado com sucesso.');
        }
      } catch (syncError) {
        print('Aviso: Falha na sincronização do código público: $syncError');
      }

      if (mounted) {
        setState(() {
          _inviteCode = finalCode;
          _isLoading = false;
          _loadMessage = 'Código pronto.';
        });
      }
    } catch (e) {
      print('Erro Crítico ao carregar/sincronizar o código: $e');
      if (mounted) {
        setState(() {
          _loadMessage = 'Erro ao carregar o código. Verifique a conexão.';
          _inviteCode = 'ERRO';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _launchWhatsApp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final String phoneNumber = _phoneController.text.replaceAll(
      RegExp(r'[^\d]'),
      '',
    );
    final String patientName = _patientNameController.text.trim();

    if (_inviteCode == null && _inviteCode!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Código de convite não disponível. Tente novamente.'),
        ),
      );
      return;
    }
    final String welcomeMessage = patientName.isNotEmpty
        ? 'Olá ${patientName.split(' ')[0]}, '
        : 'Olá!';
    final String message =
        '$welcomeMessage seu fisioterapeuta enviou um convite para o acompanhamento do seu caso. \n'
        '1. Clique no link para ir ao portal do aplicativo: $appDistributionLink \n'
        '2. No portal, insira seu e-mail para receber o link de downaload. \n'
        '3. Verifique seu e-mail e instale o app. \n'
        'Seu código de convite para o cadastro no app é: *$_inviteCode* ';

    final String encodedMessage = Uri.encodeComponent(message);
    final Uri whatsappUrl = Uri.parse(
      'whatsapp://send?phone=$phoneNumber&text=$encodedMessage',
    );
    try {
      if (await canLaunchUrl(whatsappUrl)) {
        await launchUrl(whatsappUrl);
      } else {
        final Uri fallbackUrl = Uri.parse(
          'https://wa.me/$phoneNumber?text=$encodedMessage',
        );
        if (await canLaunchUrl(fallbackUrl)) {
          await launchUrl(fallbackUrl, mode: LaunchMode.externalApplication);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Não foi possível abrir o WhatsApp. Verifique se o aplicativo está instalado.',
              ),
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao abrir o WhatsApp: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF4F7F6),
      appBar: AppBar(
        title: Text(
          'Convidar Paciente',
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color(0xFF0E382C),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0xFF0E382C)),
                  SizedBox(height: 16),
                  Text(_loadMessage),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Métodos de Convite',
                    style: GoogleFonts.montserrat(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0E382C),
                    ),
                  ),
                  SizedBox(height: 16),
                  Center(
                    child: Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color.fromARGB(140, 158, 158, 158),
                            spreadRadius: 2,
                            blurRadius: 5,
                          ),
                        ],
                      ),
                      child: QrImageView(
                        data: appDistributionLink,
                        version: QrVersions.auto,
                        size: 200,
                        backgroundColor: Colors.white,
                        eyeStyle: QrEyeStyle(
                          eyeShape: QrEyeShape.square,
                          color: Color(0xFF0E382C),
                        ),
                        dataModuleStyle: QrDataModuleStyle(
                          dataModuleShape: QrDataModuleShape.square,
                          color: Color(0xFF0E382C),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Color(0xFF0E382C), width: 1),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Código de Convite:',
                          style: GoogleFonts.montserrat(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0E382C),
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          _inviteCode ?? 'ERRO',
                          style: GoogleFonts.montserrat(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '(O paciente usará este código no cadastro)',
                          style: GoogleFonts.montserrat(
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 32),
                  Text(
                    'Enviar Convite pelo WhatsApp',
                    style: GoogleFonts.montserrat(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0E382C),
                    ),
                  ),
                  SizedBox(height: 16),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _patientNameController,
                          decoration: InputDecoration(
                            labelText: 'Nome do Paciente',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            prefixIcon: Icon(Icons.person),
                          ),
                        ),
                        SizedBox(height: 16),
                        TextFormField(
                          controller: _phoneController,
                          decoration: InputDecoration(
                            labelText: 'WhatsApp do Paciente',
                            prefixIcon: Icon(Icons.phone),
                            hint: Text(
                              '(99) 99999-9999',
                              style: TextStyle(
                                color: Color.fromARGB(130, 14, 56, 44),
                              ),
                            ),
                          ),
                          keyboardType: TextInputType.phone,
                          inputFormatters: [
                            PhoneInputFormatter(
                              defaultCountryCode: 'BR',
                              allowEndlessPhone: false,
                            ),
                          ],
                        ),
                        SizedBox(height: 32),
                        ElevatedButton.icon(
                          onPressed: _launchWhatsApp,
                          icon: FaIcon(
                            FontAwesomeIcons.whatsapp,
                            color: Colors.white,
                          ),
                          label: Text(
                            'Enviar Convite via WhatsApp',
                            style: GoogleFonts.montserrat(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF25D366),
                            minimumSize: Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 12),
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
