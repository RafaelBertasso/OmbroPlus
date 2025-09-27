import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/formatters/masked_input_formatter.dart';
import 'package:flutter_multi_formatter/formatters/phone_input_formatter.dart';
import 'package:google_fonts/google_fonts.dart';

class DoctorEditProfilePage extends StatefulWidget {
  const DoctorEditProfilePage({super.key});

  @override
  State<DoctorEditProfilePage> createState() => _DoctorEditProfilePageState();
}

class _DoctorEditProfilePageState extends State<DoctorEditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _crefitoController = TextEditingController();
  final _crmController = TextEditingController();

  final crefitoMaskFormatter = MaskedInputFormatter('000000-A');
  final crmMaskFormatter = MaskedInputFormatter('00000000-0/BR');

  bool _isSaving = false;
  String? _specialistId;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_specialistId == null) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      final passedId = args?['id'] as String;

      _specialistId = passedId;
      _loadUserData(_specialistId!);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erro: ID do especialista não encontrado. Certifique-se de estar logado ou de ter navegado a partir da lista.',
          ),
        ),
      );
    }
  }

  Future<void> _loadUserData(String docId) async {
    final doc = await FirebaseFirestore.instance
        .collection('especialistas')
        .doc(docId)
        .get();
    final data = doc.data();
    if (data != null) {
      _nameController.text = data['nome'] ?? '';
      _emailController.text = data['email'] ?? '';
      _phoneController.text = data['telefone'] ?? '';
      _crefitoController.text = data['crefito'] ?? '';
      _crmController.text = data['crm'] ?? '';
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });
    final targetDocId = _specialistId!;
    final currentUser = FirebaseAuth.instance.currentUser;
    try {
      final isEditingSelf = currentUser?.uid == targetDocId;
      if (isEditingSelf) {
        final isEmailChanged =
            currentUser!.email != _emailController.text.trim();
        if (isEmailChanged) {
          await currentUser.verifyBeforeUpdateEmail(
            _emailController.text.trim(),
          );
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
                  'Um link de verificação foi enviado para o novo endereço de e-mail. Por favor, acesse sua caixa de entrada e complete a alteração.',
                  style: GoogleFonts.openSans(color: Colors.black),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
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
        }
      }
      await FirebaseFirestore.instance
          .collection('especialistas')
          .doc(targetDocId)
          .update({
            'email': _emailController.text.trim(),
            'telefone': _phoneController.text.trim(),
            'crefito': _crefitoController.text.trim(),
            'crm': _crmController.text.trim(),
          });

      final messenger = ScaffoldMessenger.of(context);
      messenger.showMaterialBanner(
        MaterialBanner(
          content: Text(
            'Perfil atualizado com sucesso!',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Color(0xFF0E382C),
          leading: Icon(Icons.check_circle_outline, color: Colors.white),
          actions: [
            TextButton(
              onPressed: () => messenger.hideCurrentMaterialBanner(),
              child: Icon(Icons.close, color: Colors.white),
            ),
          ],
        ),
      );
      Future.delayed(Duration(seconds: 3), () {
        messenger.hideCurrentMaterialBanner();
      });
      Navigator.pop(context);
    } catch (e) {
      print(e.toString());
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
    _crefitoController.dispose();
    _crmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF4F7F6),
      body: Column(
        children: [
          Row(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.arrow_back, color: Colors.black),
                  tooltip: 'Voltar',
                ),
              ),
              Spacer(),
              Center(
                child: Image.asset(
                  'assets/images/logo-app.png',
                  width: 150,
                  height: 150,
                ),
              ),
              Spacer(),
              SizedBox(width: 48),
            ],
          ),
          Center(
            child: Text(
              'Editar Perfil',
              style: GoogleFonts.montserrat(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Nome completo',
                          enabled: false,
                        ),
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _phoneController,
                        decoration: InputDecoration(
                          labelText: 'Telefone/WhatsApp',
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (value) => value!.isEmpty
                            ? 'O telefonte não pode ser vazio'
                            : null,
                        inputFormatters: [
                          PhoneInputFormatter(
                            defaultCountryCode: 'BR',
                            allowEndlessPhone: false,
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email para contato e login',
                          helper: Text(
                            'Para atualizar o e-mail, faça login novamente.',
                            style: TextStyle(color: Colors.black54),
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) => value!.isEmpty
                            ? 'O email não pode ser vazio'
                            : null,
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _crefitoController,
                        decoration: InputDecoration(
                          labelText: 'CREFITO (Opcional)',
                        ),
                        inputFormatters: [crefitoMaskFormatter],
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _crmController,
                        decoration: InputDecoration(
                          labelText: 'CRM (Opcional)',
                        ),
                        inputFormatters: [crmMaskFormatter],
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _isSaving ? null : _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF0E382C),
                          minimumSize: Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadiusGeometry.circular(8),
                          ),
                        ),
                        child: _isSaving
                            ? CircularProgressIndicator(color: Colors.white)
                            : Text(
                                'Salvar',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
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
