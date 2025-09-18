import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/formatters/phone_input_formatter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class DoctorRegisterPage extends StatefulWidget {
  const DoctorRegisterPage({super.key});

  @override
  State<DoctorRegisterPage> createState() => _DoctorRegisterPageState();
}

class _DoctorRegisterPageState extends State<DoctorRegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _crefitoController = TextEditingController();
  final _crmController = TextEditingController();
  String _role = 'especialista';

  final maskFormatter = MaskTextInputFormatter(
    mask: '##/##/####',
    filter: {"#": RegExp(r'[0-9]')},
  );

  final ValueNotifier<bool> _obscurePassword = ValueNotifier<bool>(true);
  final ValueNotifier<bool> _obscureConfirmPassword = ValueNotifier<bool>(true);

  MaterialStateProperty<Color> radioFillColor() {
    return MaterialStateProperty.resolveWith((states) {
      if (states.contains(MaterialState.selected)) {
        return Color(0xFF0E382C);
      }
      return Colors.grey;
    });
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Informe a senha';
    }
    if (value.length < 6) {
      return 'A senha deve ter pelo menos 6 caracteres';
    }
    if (value != _passwordController.text) {
      return 'As senhas não coincidem';
    }
    return null;
  }

  Future<void> registerSpecialist() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );
      String uid = userCredential.user!.uid;

      final specialistData = {
        'nome': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'telefone': _phoneController.text.trim(),
        'data_cadastro': DateTime.now().toIso8601String(),
        'isAdmin': _role == 'administrador',
      };
      final docRef = FirebaseFirestore.instance
          .collection('especialistas')
          .doc(uid);
      await docRef.set(specialistData);
      Navigator.pushNamed(context, '/doctor-home');
    } on FirebaseAuthException catch (e) {
      String message = 'Erro ao cadastrar conta';
      if (e.code == 'email-already-in-use') {
        message = 'O email já está em uso';
      } else if (e.code == 'invalid-email') {
        message = 'Email inválido';
      } else if (e.code == 'weak-password') {
        message = 'A senha é muito fraca';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
                        decoration: InputDecoration(labelText: 'Nome Completo'),
                        textCapitalization: TextCapitalization.words,
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'E-mail para contato e login',
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Informe o email';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _phoneController,
                        decoration: InputDecoration(
                          labelText: 'Telefone/WhatsApp',
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
                      SizedBox(height: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Tipo de Usuário',
                              style: GoogleFonts.openSans(fontSize: 16),
                            ),
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Radio(
                                value: 'especialista',
                                groupValue: _role,
                                fillColor: radioFillColor(),
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      _role = value;
                                    });
                                  }
                                },
                              ),
                              Text(
                                'Especialista',
                                style: GoogleFonts.montserrat(fontSize: 16),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Radio(
                                value: 'administrador',
                                groupValue: _role,
                                fillColor: radioFillColor(),
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      _role = value;
                                    });
                                  }
                                },
                              ),
                              Text(
                                'Administrador',
                                style: GoogleFonts.montserrat(fontSize: 16),
                              ),
                            ],
                          ),
                        ],
                      ),
                      ValueListenableBuilder<bool>(
                        valueListenable: _obscurePassword,
                        builder: (context, value, child) {
                          return TextFormField(
                            controller: _passwordController,
                            decoration: InputDecoration(
                              labelText: 'Senha',
                              suffixIcon: IconButton(
                                icon: Icon(
                                  value
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () =>
                                    _obscurePassword.value = !value,
                              ),
                            ),
                            obscureText: value,
                          );
                        },
                      ),
                      SizedBox(height: 16),
                      ValueListenableBuilder<bool>(
                        valueListenable: _obscureConfirmPassword,
                        builder: (context, value, child) {
                          return TextFormField(
                            controller: _confirmPasswordController,
                            decoration: InputDecoration(
                              labelText: 'Confirmar Senha',
                              labelStyle: TextStyle(color: Color(0xFF0E382C)),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0xFF0E382C),
                                ),
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey),
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  value
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () =>
                                    _obscureConfirmPassword.value = !value,
                              ),
                            ),
                            obscureText: value,
                            validator: validatePassword,
                          );
                        },
                      ),
                      SizedBox(height: 24),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF0E382C),
                          minimumSize: Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () => registerSpecialist(),
                        child: Text(
                          'Cadastrar',
                          style: GoogleFonts.montserrat(
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
