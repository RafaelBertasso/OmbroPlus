import 'package:Ombro_Plus/viewmodels/doctor/doctor_patients_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/formatters/phone_input_formatter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DoctorPatientsViewModel>().loadInviteCode();
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _patientNameController.dispose();
    super.dispose();
  }

  Future<void> _launchWhatsApp(String inviteCode) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final String phoneNumber = _phoneController.text.replaceAll(
      RegExp(r'[^\d]'),
      '',
    );
    final String patientName = _patientNameController.text.trim();

    if (inviteCode == 'ERRO' && inviteCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Código de convite inválido. Tente recarregar a página.',
          ),
        ),
      );
      return;
    }
    final String welcomeMessage = patientName.isNotEmpty
        ? 'Olá ${patientName.split(' ')[0]}, '
        : 'Olá!';
    final String message =
        '$welcomeMessage seu fisioterapeuta enviou um convite para o acompanhamento do seu caso. \n'
        '1. Clique no link para baixar o aplicativo: $appDistributionLink \n'
        '2. Instale e faça seu cadastro. \n'
        '3. Use este CÓDIGO DE CONVITE: *$_inviteCode* ';

    final String encodedMessage = Uri.encodeComponent(message);

    final Uri whatsappUrl = Uri.parse(
      'whatsapp://send?phone=$phoneNumber&text=$encodedMessage',
    );
    final Uri fallbackUrl = Uri.parse(
      'https://wa.me/$phoneNumber?text=$encodedMessage',
    );

    try {
      if (await canLaunchUrl(whatsappUrl)) {
        await launchUrl(whatsappUrl);
      } else if (await canLaunchUrl(fallbackUrl)) {
        await launchUrl(fallbackUrl, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Não foi possível abrir o WhatsApp.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao abrir o WhatsApp: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      appBar: AppBar(
        title: Text(
          'Convidar Paciente',
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF0E382C),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Consumer<DoctorPatientsViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF0E382C)),
            );
          }

          final inviteCode = viewModel.inviteCode ?? '...';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Métodos de Convite',
                  style: GoogleFonts.montserrat(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0E382C),
                  ),
                ),
                const SizedBox(height: 16),

                // --- QR Code ---
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(
                          color: Color.fromARGB(140, 158, 158, 158),
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
                      eyeStyle: const QrEyeStyle(
                        eyeShape: QrEyeShape.square,
                        color: Color(0xFF0E382C),
                      ),
                      dataModuleStyle: const QrDataModuleStyle(
                        dataModuleShape: QrDataModuleShape.square,
                        color: Color(0xFF0E382C),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // --- Código de Texto ---
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFF0E382C),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Código de Convite:',
                        style: GoogleFonts.montserrat(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0E382C),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        inviteCode,
                        style: GoogleFonts.montserrat(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
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
                const SizedBox(height: 32),

                // --- Formulário WhatsApp ---
                Text(
                  'Enviar Convite pelo WhatsApp',
                  style: GoogleFonts.montserrat(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0E382C),
                  ),
                ),
                const SizedBox(height: 16),
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
                          prefixIcon: const Icon(Icons.person),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Informe o nome';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _phoneController,
                        decoration: const InputDecoration(
                          labelText: 'WhatsApp do Paciente',
                          prefixIcon: Icon(Icons.phone),
                          hintText: '(99) 99999-9999',
                        ),
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          PhoneInputFormatter(
                            defaultCountryCode: 'BR',
                            allowEndlessPhone: false,
                          ),
                        ],
                        validator: (value) {
                          if (value == null || value.length < 14) {
                            return 'Informe um telefone válido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 32),

                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton.icon(
                          onPressed: () => _launchWhatsApp(inviteCode),
                          icon: const FaIcon(
                            FontAwesomeIcons.whatsapp,
                            color: Colors.white,
                          ),
                          label: Text(
                            'Enviar Convite via WhatsApp',
                            style: GoogleFonts.montserrat(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF25D366),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }
}
