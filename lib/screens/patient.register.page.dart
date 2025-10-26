import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class PatientRegisterPage extends StatefulWidget {
  const PatientRegisterPage({super.key});

  @override
  State<PatientRegisterPage> createState() => _PatientRegisterPageState();
}

class _PatientRegisterPageState extends State<PatientRegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _ageController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _sexController = TextEditingController();
  final _otherSexController = TextEditingController();

  final maskFormatter = MaskTextInputFormatter(
    mask: '##/##/####',
    filter: {"#": RegExp(r'[0-9]')},
  );

  final ValueNotifier<bool> _obscurePassword = ValueNotifier<bool>(true);
  final ValueNotifier<bool> _obscureConfirmPassword = ValueNotifier<bool>(true);

  DateTime? birthDate;
  int? age;
  String sex = 'masculino';

  MaterialStateProperty<Color> radioFillColor() {
    return MaterialStateProperty.resolveWith((states) {
      if (states.contains(MaterialState.selected)) {
        return Color(0xFF0E382C);
      }
      return Colors.grey;
    });
  }

  String? validateDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Informe a data de nascimento';
    }
    final regex = RegExp(r'^(\d{2})\/(\d{2})\/(\d{4})$');
    if (!regex.hasMatch(value)) {
      return 'Data inválida. Use dd/MM/aaaa';
    }

    final match = regex.firstMatch(value);
    if (match == null) {
      return 'Data inválida';
    }

    final day = int.tryParse(match.group(1)!);
    final month = int.tryParse(match.group(2)!);
    final year = int.tryParse(match.group(3)!);

    if (day == null || month == null || year == null) {
      return 'Data inválida';
    }

    final now = DateTime.now();

    if (month < 1 || month > 12) {
      return 'Mês inválido';
    }

    if (year > now.year) {
      return 'Ano inválido';
    }

    if (year < 1900) {
      return 'Ano muito antigo';
    }

    try {
      final date = DateTime(year, month, day);
      if (date.month != month || date.day != day) {
        return 'Data inválida';
      }
    } catch (_) {
      return 'Data inválida';
    }

    return null;
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

  Future<void> registerPatient() async {
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

      final patientData = {
        'nome': _nameController.text.trim(),
        'data_nascimento': _birthDateController.text.trim(),
        'idade': age,
        'sexo': sex == 'outro' ? _otherSexController.text.trim() : sex,
        'email': _emailController.text.trim(),
        'telefone': _phoneController.text.trim(),
        'data_cadastro': DateTime.now().toIso8601String(),
      };
      final docRef = FirebaseFirestore.instance
          .collection('pacientes')
          .doc(uid);
      await docRef.set(patientData);
      Navigator.pushNamed(context, '/patient-home');
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
  void initState() {
    super.initState();

    _birthDateController.addListener(() {
      final text = _birthDateController.text;
      if (text.length == 10) {
        try {
          final parts = text.split('/');
          final day = int.parse(parts[0]);
          final month = int.parse(parts[1]);
          final year = int.parse(parts[2]);
          final birthDate = DateTime(year, month, day);
          final currentDate = DateTime.now();

          int calculatedAge = currentDate.year - birthDate.year;
          if (currentDate.month < birthDate.month ||
              (currentDate.month == birthDate.month &&
                  currentDate.day < birthDate.day)) {
            calculatedAge--;
          }
          setState(() {
            age = calculatedAge;
            _ageController.text = age.toString();
          });
        } catch (e) {
          setState(() {
            age = null;
            _ageController.text = '';
          });
        }
      } else {
        setState(() {
          age = null;
          _ageController.text = '';
        });
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _birthDateController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _sexController.dispose();
    _obscurePassword.dispose();
    _obscureConfirmPassword.dispose();
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
                  icon: Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () => Navigator.pop(context),
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
                        textCapitalization: TextCapitalization.words,
                        decoration: InputDecoration(labelText: 'Nome completo'),
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _birthDateController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [maskFormatter],
                              decoration: InputDecoration(
                                labelText: 'Data de Nascimento',

                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 15,
                                  horizontal: 12,
                                ),
                              ),
                              style: GoogleFonts.openSans(fontSize: 16),
                              validator: validateDate,
                            ),
                          ),
                          SizedBox(width: 12),
                          Container(
                            width: 60,
                            child: TextFormField(
                              enabled: false,
                              decoration: InputDecoration(labelText: 'Idade'),
                              controller: _ageController,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Sexo',
                            style: GoogleFonts.openSans(fontSize: 16),
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Radio(
                                value: 'masculino',
                                groupValue: sex,
                                fillColor: radioFillColor(),
                                onChanged: (value) => setState(() {
                                  sex = 'masculino';
                                }),
                              ),
                              Text(
                                'Masculino',
                                style: GoogleFonts.openSans(fontSize: 16),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Radio(
                                value: 'feminino',
                                groupValue: sex,
                                fillColor: radioFillColor(),
                                onChanged: (value) => setState(() {
                                  sex = 'feminino';
                                }),
                              ),
                              Text(
                                'Feminino',
                                style: GoogleFonts.openSans(fontSize: 16),
                              ),
                            ],
                          ),
                          if (sex != 'masculino' && sex != 'feminino')
                            Container(),
                          Column(
                            children: [
                              Row(
                                children: [
                                  Radio(
                                    value: 'outro',
                                    groupValue: sex,
                                    fillColor: radioFillColor(),
                                    onChanged: (value) => setState(() {
                                      sex = 'outro';
                                    }),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: EdgeInsets.only(left: 8),
                                      child: TextFormField(
                                        controller: _otherSexController,
                                        decoration: InputDecoration(
                                          labelText: 'Escreva aqui',
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Contatos',
                            style: GoogleFonts.openSans(fontSize: 16),
                          ),
                          SizedBox(height: 8),
                          TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              labelText: 'Email para contato e login',
                            ),
                            keyboardType: TextInputType.emailAddress,
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
                                  labelStyle: TextStyle(
                                    color: Color(0xFF0E382C),
                                  ),
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
                            onPressed: () => registerPatient(),
                            child: Text(
                              'Cadastrar',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
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
