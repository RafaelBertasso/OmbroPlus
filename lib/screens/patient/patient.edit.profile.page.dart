import 'package:Ombro_Plus/components/app.logo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/formatters/phone_input_formatter.dart';
import 'package:google_fonts/google_fonts.dart';

class PatientEditProfilePage extends StatefulWidget {
  const PatientEditProfilePage({super.key});

  @override
  State<PatientEditProfilePage> createState() => _PatientEditProfilePageState();
}

class _PatientEditProfilePageState extends State<PatientEditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _sexController = TextEditingController();

  bool _isSaving = false;
  String? _patientId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_patientId == null) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      final passedId =
          args?['id'] as String? ?? FirebaseAuth.instance.currentUser?.uid;

      if (passedId != null) {
        _patientId = passedId;
        _loadUserData(_patientId!);
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pop(context);
        });
      }
    }
  }

  Future<void> _loadUserData(String docId) async {
    final doc = await FirebaseFirestore.instance
        .collection('pacientes')
        .doc(docId)
        .get();
    final data = doc.data();
    if (data != null) {
      setState(() {
        _nameController.text = data['nome'] ?? '';
        _emailController.text = data['email'] ?? '';
        _phoneController.text = data['telefone'] ?? '';
        _birthDateController.text = data['data_nascimento'] ?? 'Não informado';
        _sexController.text = (data['sexo'] ?? 'Não informado');
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate() || _patientId == null) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final targetDocId = _patientId!;
    final currentUser = FirebaseAuth.instance.currentUser;

    try {
      final isEditingSelf = currentUser?.uid == targetDocId;
      if (isEditingSelf && currentUser != null) {
        final isEmailChanged =
            currentUser.email != _emailController.text.trim();

        if (isEmailChanged) {
          await currentUser.verifyBeforeUpdateEmail(
            _emailController.text.trim(),
          );

          if (!mounted) return;
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return AlertDialog(
                backgroundColor: const Color(0xFFF4F7F6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                title: Text(
                  'Verificação de e-mail necessária',
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0E382C),
                  ),
                ),
                content: Text(
                  'Um link de verificação foi enviado para o novo e-mail. Por favor, acesse sua caixa de entrada e complete a alteração.',
                  style: GoogleFonts.openSans(color: Colors.black),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context, true);
                    },
                    child: Text(
                      'OK',
                      style: GoogleFonts.openSans(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0E382C),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
          return;
        }
      }

      await FirebaseFirestore.instance
          .collection('pacientes')
          .doc(targetDocId)
          .update({
            'nome': _nameController.text.trim(),
            'email': _emailController.text.trim(),
            'telefone': _phoneController.text.trim(),
          });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Perfil atualizado com sucesso!'),
          backgroundColor: const Color(0xFF0E382C),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      print('Erro ao salvar o perfil do paciente: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar o perfil.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _birthDateController.dispose();
    _sexController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      body: Column(
        children: [
          Row(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  tooltip: 'Voltar',
                ),
              ),
              const Spacer(),
              AppLogo(),
              const Spacer(),
              const SizedBox(width: 48),
            ],
          ),
          Center(
            child: Text(
              'Editar Dados Pessoais',
              style: GoogleFonts.montserrat(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0E382C),
              ),
            ),
          ),
          const SizedBox(height: 16),

          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Nome completo',
                          enabled: false,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _phoneController,
                        decoration: const InputDecoration(
                          labelText: 'Telefone/WhatsApp',
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (value) => value!.isEmpty
                            ? 'O telefone não pode ser vazio'
                            : null,
                        inputFormatters: [
                          PhoneInputFormatter(
                            defaultCountryCode: 'BR',
                            allowEndlessPhone: false,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email para contato e login',
                          helperText:
                              'Alterar o e-mail requer verificação por link.',
                          helperStyle: TextStyle(color: Colors.black54),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) => value!.isEmpty
                            ? 'O email não pode ser vazio'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _birthDateController,
                        decoration: const InputDecoration(
                          labelText: 'Data de Nascimento',
                          enabled: false,
                        ),
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _sexController,
                        decoration: const InputDecoration(
                          labelText: 'Sexo',
                          enabled: false,
                        ),
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: _isSaving ? null : _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0E382C),
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isSaving
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : Text(
                                'Salvar Alterações',
                                style: GoogleFonts.openSans(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
