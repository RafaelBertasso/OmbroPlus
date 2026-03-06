import 'dart:convert';

import 'package:Ombro_Plus/ui/shared/widgets/app_logo.dart';
import 'package:Ombro_Plus/ui/shared/widgets/build_info_row.dart';
import 'package:Ombro_Plus/ui/shared/widgets/navbar.dart';
import 'package:Ombro_Plus/ui/doctor/profile/widgets/delete_account_dialog.dart';
import 'package:Ombro_Plus/viewmodels/doctor/doctor_profile_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class DoctorProfilePage extends StatefulWidget {
  const DoctorProfilePage({super.key});

  @override
  State<DoctorProfilePage> createState() => _DoctorProfilePageState();
}

class _DoctorProfilePageState extends State<DoctorProfilePage> {
  final int _selectedIndex = 4;

  void _onTabTapped(BuildContext context, int index) {
    if (index == _selectedIndex) return;
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/doctor-home');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/doctor-dashboard');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/doctor-protocols');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/doctor-main-chat');
        break;
      default:
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DoctorProfileViewModel>().loadProfile();
    });
  }

  void _showImageOptions(BuildContext context) {
    final viewModel = context.read<DoctorProfileViewModel>();
    showModalBottomSheet(
      backgroundColor: Color(0xFF0E382C),
      context: context,
      builder: (ctx) => SafeArea(
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
                Navigator.pop(ctx);
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
                Navigator.pop(ctx);
                viewModel.pickAndUploadImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => DeleteAccountDialog(
        isLoading: context.watch<DoctorProfileViewModel>().isLoading,
        onConfirm: (password) async {
          FocusScope.of(context).unfocus();

          final viewModel = context.read<DoctorProfileViewModel>();
          final success = await viewModel.deleteAccount(password);

          if (success) {
            if (!context.mounted) return;
            Navigator.pop(context);
            Navigator.pushNamedAndRemoveUntil(context, '/login', (r) => false);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Conta excluída com sucesso.')),
            );
          } else {
            if (!context.mounted) return;
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(viewModel.error ?? 'Erro ao excluir conta.'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      body: Consumer<DoctorProfileViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading && viewModel.userData == null) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF0E382C)),
            );
          }

          final userData = viewModel.userData ?? {};
          final nome = userData['nome'] ?? 'Especialista';
          final email = userData['email'] ?? '';
          final crefito = userData['crefito'] ?? 'Não informado';
          final crm = userData['crm'] ?? 'Não informado';
          final profileImage = viewModel.profileImage;

          return Column(
            children: [
              // Cabeçalho com Logo e Foto
              SizedBox(
                height: 300,
                width: double.infinity,
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    const AppLogo(), // Seu componente existente
                    Positioned(
                      top: 150,
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
                                        gaplessPlayback: true,
                                      ),
                                    )
                                  : Text(
                                      (nome.isNotEmpty && nome.length >= 2)
                                          ? nome.substring(0, 2).toUpperCase()
                                          : '',
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
                                color: Colors.grey[400],
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.photo,
                                color: Colors.white,
                                size: 24,
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
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    // Seção Dados Pessoais
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
                          onPressed: () =>
                              Navigator.pushNamed(
                                context,
                                '/doctor-edit-profile',
                              ).then((_) {
                                // Recarrega ao voltar da edição
                                viewModel.loadProfile();
                              }),
                          icon: const Icon(
                            Icons.edit,
                            color: Color(0xFF0E382C),
                          ),
                        ),
                      ],
                    ),
                    const Divider(color: Color(0xFF0E382C)),
                    const SizedBox(height: 10),

                    BuildInfoRow(
                      label: 'Nome',
                      value: nome,
                      icon: Icons.person_2_outlined,
                    ),
                    BuildInfoRow(
                      label: 'Telefone',
                      value: userData['telefone'] ?? 'Não informado',
                      icon: Icons.phone_android,
                    ),
                    BuildInfoRow(
                      label: 'E-mail',
                      value: email,
                      icon: Icons.email_outlined,
                    ),

                    const SizedBox(height: 20),

                    // Seção Dados Profissionais
                    Text(
                      'Dados Profissionais',
                      style: GoogleFonts.openSans(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        color: const Color(0xFF0E382C),
                      ),
                    ),
                    const Divider(color: Color(0xFF0E382C)),
                    const SizedBox(height: 10),

                    if ((crefito != 'Não informado') ||
                        (crm != 'Não informado')) ...[
                      if (crefito != 'Não informado')
                        BuildInfoRow(
                          label: 'CREFITO',
                          value: crefito,
                          icon: Icons.badge_outlined,
                        ),
                      if (crm != 'Não informado')
                        BuildInfoRow(
                          label: 'CRM',
                          value: crm,
                          icon: Icons.medical_services_outlined,
                        ),
                    ] else
                      Text(
                        'Dados profissionais não informados',
                        style: GoogleFonts.openSans(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),

                    const SizedBox(height: 20),

                    _buildProfileOption(
                      icon: Icons.settings,
                      text: 'Configurações',
                      onTap: () {
                        Navigator.pushNamed(context, '/doctor-settings');
                      },
                    ),
                    const SizedBox(height: 20),
                    // _buildProfileOption(
                    //   icon: Icons.description_outlined,
                    //   text: 'Termos de Uso',
                    //   onTap: () {
                    //     Navigator.pushNamed(context, '/terms-of-use');
                    //   },
                    // ),
                    // Botão Sair
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
        onTap: (idx) => _onTabTapped(context, idx),
      ),
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Card(
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
      ),
    );
  }
}
