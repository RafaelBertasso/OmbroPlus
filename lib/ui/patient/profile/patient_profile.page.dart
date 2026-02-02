import 'dart:convert';
import 'package:Ombro_Plus/components/app.logo.dart';
import 'package:Ombro_Plus/components/build.info.row.dart';
import 'package:Ombro_Plus/components/navbar.dart';
import 'package:Ombro_Plus/viewmodels/patient/patient_profile.viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class PatientProfilePage extends StatefulWidget {
  const PatientProfilePage({super.key});

  @override
  State<PatientProfilePage> createState() {
    return _PatientProfilePageState();
  }
}

class _PatientProfilePageState extends State<PatientProfilePage> {
  final int _selectedIndex = 4;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PatientProfileViewModel>().loadProfile();
    });
  }

  void _onTabTapped(BuildContext context, int index) {
    if (index == _selectedIndex) return;
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/patient-home');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/patient-dashboard');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/patient-protocols');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/patient-main-chat');
        break;
      default:
        break;
    }
  }

  void _showImageOptions(BuildContext context) {
    final viewModel = context.read<PatientProfileViewModel>();
    showModalBottomSheet(
      backgroundColor: Color(0xFF0E382C),
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.photo_library, color: Color(0xFFF4F7F6)),
              title: Text(
                'Galeria',
                style: GoogleFonts.openSans(
                  color: Color(0xFFF4F7F6),
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                viewModel.pickAndUploadImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: Icon(Icons.camera_alt, color: Color(0xFFF4F7F6)),
              title: Text(
                'Câmera',
                style: GoogleFonts.openSans(
                  color: Color(0xFFF4F7F6),
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                viewModel.pickAndUploadImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      body: Consumer<PatientProfileViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading && viewModel.userData == null) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF0E382C)),
            );
          }

          final userData = viewModel.userData ?? {};
          final nome = userData['nome'] ?? 'Paciente';
          final profileImage = viewModel.profileImage;

          // Dados processados via ViewModel
          final ladoAfetado = viewModel.getDisplayValue(
            userData['ladoAfetado'],
            PatientProfileViewModel.ladoMap,
          );
          final nivelDor = viewModel.getDisplayValue(
            userData['nivelDor'],
            PatientProfileViewModel.dorMap,
          );
          final nivelMobilidade = viewModel.getDisplayValue(
            userData['mobilidadeOmbro'],
            PatientProfileViewModel.mobilidadeMap,
          );
          final dificuldades = viewModel.formatDificuldades(
            userData['dificuldadesPrincipais'],
          );

          return Column(
            children: [
              SizedBox(
                height: 300,
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    const AppLogo(),
                    Positioned(
                      top: 170,
                      child: GestureDetector(
                        onTap: () => _showImageOptions(context),
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            CircleAvatar(
                              radius: 60,
                              backgroundColor: const Color(0xFF0E382C),
                              child: profileImage != null
                                  ? ClipOval(
                                      child: Image.memory(
                                        base64Decode(profileImage),
                                        width: 120,
                                        height: 120,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : Text(
                                      (nome.isNotEmpty && nome.length >= 2)
                                          ? nome.substring(0, 2).toUpperCase()
                                          : 'P',
                                      style: GoogleFonts.montserrat(
                                        fontSize: 48,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF4F7F6),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFF0E382C),
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.photo_camera,
                                color: Color(0xFF0E382C),
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 100,
                      child: Column(
                        children: [
                          Text(
                            nome,
                            style: GoogleFonts.montserrat(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            userData['diagnosticoPrincipal'] ??
                                'Diagnóstico não informado',
                            style: GoogleFonts.openSans(
                              fontSize: 15,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 20,
                  ),
                  children: [
                    // Dados Pessoais
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Dados Pessoais',
                          style: GoogleFonts.openSans(
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                            color: const Color(0xFF0E382C),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pushNamed(
                            context,
                            '/patient-edit-profile',
                          ).then((_) => viewModel.loadProfile()),
                          icon: const Icon(
                            Icons.edit,
                            color: Color(0XFF0E382C),
                          ),
                        ),
                      ],
                    ),
                    const Divider(color: Color(0xFF0E382C)),
                    BuildInfoRow(
                      label: 'E-mail',
                      value: userData['email'] ?? '',
                      icon: Icons.email_outlined,
                    ),
                    BuildInfoRow(
                      label: 'Telefone',
                      value: userData['telefone'] ?? 'Não informado',
                      icon: Icons.phone_android_outlined,
                    ),
                    BuildInfoRow(
                      label: 'Nascimento',
                      value: userData['data_nascimento'] ?? 'Não informado',
                      icon: Icons.date_range_outlined,
                    ),
                    BuildInfoRow(
                      label: 'Sexo',
                      value: userData['sexo'] ?? 'Não informado',
                      icon: FontAwesomeIcons.venusMars,
                    ),

                    const SizedBox(height: 20),

                    // Tratamento
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Meu Tratamento',
                          style: GoogleFonts.openSans(
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                            color: const Color(0xFF0E382C),
                          ),
                        ),
                      ],
                    ),
                    const Divider(color: Color(0xFF0E382C)),
                    BuildInfoRow(
                      label: 'Diagnóstico',
                      value:
                          userData['diagnosticoPrincipal'] ?? 'Não informado',
                      icon: Icons.medical_information_outlined,
                    ),
                    BuildInfoRow(
                      label: 'Lado Afetado',
                      value: ladoAfetado,
                      icon: Icons.accessibility_new_outlined,
                    ),
                    BuildInfoRow(
                      label: 'Especialista',
                      value: userData['medicoResponsavel'] ?? 'Não informado',
                      icon: Icons.local_hospital_outlined,
                    ),

                    const SizedBox(height: 20),

                    // Situação Funcional
                    Text(
                      'Situação Funcional',
                      style: GoogleFonts.openSans(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        color: const Color(0xFF0E382C),
                      ),
                    ),
                    const Divider(color: Color(0xFF0E382C)),
                    BuildInfoRow(
                      label: 'Nível de Dor',
                      value: nivelDor,
                      icon: Icons.sentiment_dissatisfied_outlined,
                    ),
                    BuildInfoRow(
                      label: 'Mobilidade',
                      value: nivelMobilidade,
                      icon: Icons.rotate_right_outlined,
                    ),
                    BuildInfoRow(
                      label: 'Dificuldades',
                      value: dificuldades,
                      icon: Icons.warning_amber_outlined,
                    ),
                    BuildInfoRow(
                      label: 'Meta Principal',
                      value: userData['objetivoTratamento'] ?? 'Não informado',
                      icon: Icons.flag_outlined,
                    ),

                    const SizedBox(height: 30),

                    _buildProfileOption(
                      icon: Icons.settings_outlined,
                      text: 'Configurações e Segurança',
                      onTap: () =>
                          Navigator.pushNamed(context, '/patient-settings'),
                    ),

                    const SizedBox(height: 16),

                    ElevatedButton.icon(
                      onPressed: () async {
                        await viewModel.logout();
                        if (context.mounted) {
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/login',
                            (route) => false,
                          );
                        }
                      },
                      icon: const Icon(
                        Icons.logout_outlined,
                        color: Colors.white,
                      ),
                      label: Text(
                        'Sair',
                        style: GoogleFonts.openSans(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 17,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0E382C),
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: Navbar(
        currentIndex: _selectedIndex,
        onTap: (index) => _onTabTapped(context, index),
      ),
    );
  }

  // Widget auxiliar para botões de menu no final
  Widget _buildProfileOption({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF0E382C).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFF0E382C)),
        ),
        title: Text(
          text,
          style: GoogleFonts.openSans(fontWeight: FontWeight.w600),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey,
        ),
        onTap: onTap,
      ),
    );
  }
}
