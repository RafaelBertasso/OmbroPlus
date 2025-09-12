// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class PatientRegisterPage extends StatefulWidget {
  const PatientRegisterPage({super.key});

  @override
  State<PatientRegisterPage> createState() => _PatientRegisterPageState();
}

class _PatientRegisterPageState extends State<PatientRegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
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

  Future<void> _pickDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData(
            colorScheme: ColorScheme.light(
              primary: Color(0xFF0E382C),
              onPrimary: Colors.white,
              onSurface: Colors.black,
              surface: Color(0xFFF4F7F6),
            ),
            dialogTheme: DialogThemeData(backgroundColor: Color(0xFFF4F7F6)),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        birthDate = picked;
        _ageController.text = DateFormat('dd/MM/yyyy').format(birthDate!);
        age =
            DateTime.now().year -
            birthDate!.year -
            ((DateTime.now().month < birthDate!.month ||
                    (DateTime.now().month == birthDate!.month &&
                        DateTime.now().day < birthDate!.day))
                ? 1
                : 0);
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 60),
            Center(
              child: Image.asset(
                'assets/images/logo-app.png',
                width: 150,
                height: 150,
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(labelText: 'Nome completo'),
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _ageController,
                            readOnly: true,
                            inputFormatters: [maskFormatter],
                            onTap: () => _pickDate(context),
                            decoration: InputDecoration(
                              labelText: 'Data de Nascimento',
                              suffixIcon: Icon(
                                Icons.calendar_today,
                                size: 20,
                                color: Color(0xFF0E382C),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Container(
                          width: 60,
                          child: TextFormField(
                            enabled: false,
                            decoration: InputDecoration(labelText: 'Idade'),
                            controller: TextEditingController(
                              text: age != null ? age.toString() : '',
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Sexo', style: GoogleFonts.openSans(fontSize: 16)),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Radio(
                              value: 'masculino',
                              groupValue: sex,
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
                            hintText: '(99) 99999-9999',
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
                          onPressed: () {//TODO: Implementar o firebase no cadastro
                          },
                          child: Text(
                            'Cadastrar',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
