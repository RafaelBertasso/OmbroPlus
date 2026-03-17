import 'package:Ombro_Plus/viewmodels/auth/auth_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class InviteCodeSheet extends StatefulWidget {
  const InviteCodeSheet({super.key});

  @override
  State<InviteCodeSheet> createState() => _InviteCodeSheetState();
}

class _InviteCodeSheetState extends State<InviteCodeSheet> {
  final _codeController = TextEditingController();
  bool _localLoading = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _verifyCode() async {
    final code = _codeController.text.trim();

    final messenger = ScaffoldMessenger.of(context);

    void showErrorBanner(String message) {
      messenger.clearMaterialBanners();

      messenger.showMaterialBanner(
        MaterialBanner(
          padding: EdgeInsets.zero,
          dividerColor: Colors.transparent,
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  top: 16,
                  left: 16,
                  right: 16,
                  bottom: 12,
                ),
                child: Center(
                  child: Text(
                    message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.0, end: 1.0),
                duration: const Duration(seconds: 3),
                builder: (context, value, child) {
                  return LinearProgressIndicator(
                    value: value,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.white,
                    ),
                    minHeight: 4,
                  );
                },
              ),
            ],
          ),
          backgroundColor: Colors.red.shade800,
          actions: [SizedBox.shrink()],
        ),
      );

      Future.delayed(const Duration(seconds: 3), () {
        messenger.hideCurrentMaterialBanner();
      });
    }

    if (code.isEmpty) {
      showErrorBanner('Por favor, digite o código.');
      return;
    }

    setState(() => _localLoading = true);

    final viewModel = context.read<AuthViewModel>();
    final specialistId = await viewModel.checkInviteCode(code);

    setState(() => _localLoading = false);

    if (!mounted) return;

    if (specialistId != null) {
      messenger.clearMaterialBanners();
      Navigator.pop(context);

      Navigator.pushNamed(
        context,
        '/patient-register',
        arguments: {'inviteCode': code, 'specialistId': specialistId},
      );
    } else {
      showErrorBanner(viewModel.error ?? 'Código inválido');
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(24, 24, 24, bottomPadding + 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text(
            'Código de Convite',
            style: GoogleFonts.montserrat(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0E382C),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 12),

          Text(
            'Insira o código fornecido pelo seu especialista para criar sua conta.',
            style: GoogleFonts.openSans(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),

          TextField(
            controller: _codeController,
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(
              labelText: 'CÓDIGO',
              prefixIcon: Icon(
                Icons.vpn_key_off_outlined,
                color: Color(0xFF0E382C),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Color(0xFFF4F7F6),
            ),
          ),
          SizedBox(height: 24),

          Container(
            margin: EdgeInsets.only(bottom: bottomPadding + 50),
            child: ElevatedButton(
              onPressed: _localLoading ? null : _verifyCode,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF0E382C),
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: _localLoading
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      'VERIFICAR CÓDIGO',
                      style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
