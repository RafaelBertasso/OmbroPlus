import 'package:Ombro_Plus/ui/shared/widgets/config_tile.dart';
import 'package:Ombro_Plus/ui/doctor/profile/widgets/delete_account_dialog.dart';
import 'package:Ombro_Plus/viewmodels/patient/patient_profile.viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class PatientSettingsPage extends StatefulWidget {
  const PatientSettingsPage({super.key});

  @override
  State<PatientSettingsPage> createState() => _PatientSettingsPageState();
}

class _PatientSettingsPageState extends State<PatientSettingsPage> {
  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => DeleteAccountDialog(
        isLoading: context.watch<PatientProfileViewModel>().isLoading,
        onConfirm: (password) async {
          FocusScope.of(context).unfocus();

          final viewModel = context.read<PatientProfileViewModel>();
          final success = await viewModel.deleteAccount(password);

          if (success) {
            if (!context.mounted) return;
            Navigator.pop(context); // Fecha Dialog
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
      appBar: AppBar(
        title: Text(
          'Configurações',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF0E382C),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ConfigTile(
            icon: Icons.lock_outline,
            onTap: () => Navigator.pushNamed(context, '/forgot-password'),
            title: 'Mudar Senha',
          ),
          // ConfigTile(
          //   icon: Icons.description_outlined,
          //   onTap: () => Navigator.pushNamed(context, '/terms-of-use'),
          //   title: 'Termos de Uso',
          // ),
          const Divider(height: 40),

          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.delete_forever, color: Colors.red),
            ),
            title: Text(
              'Excluir Conta',
              style: GoogleFonts.montserrat(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: const Text(
              'Esta ação apagará todos os seus dados e histórico clínico.',
            ),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.red,
            ),
            onTap: () => _showDeleteAccountDialog(context),
          ),
        ],
      ),
    );
  }
}
