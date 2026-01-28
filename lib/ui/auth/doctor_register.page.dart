import 'package:Ombro_Plus/viewmodels/auth/doctor_register.viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/formatters/phone_input_formatter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:provider/provider.dart';

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

  final crefitoMaskFormatter = MaskTextInputFormatter(
    mask: '######-A',
    filter: {"#": RegExp(r'[0-9]'), "A": RegExp(r'[A-Za-z]')},
  );

  final crmMaskFormatter = MaskTextInputFormatter(
    mask: '########-#/BR',
    filter: {
      "#": RegExp(r'[0-9]'),
      "B": RegExp(r'[A-Za-z]'),
      "R": RegExp(r'[A-Za-z]'),
    },
  );

  final ValueNotifier<bool> _obscurePassword = ValueNotifier<bool>(true);
  final ValueNotifier<bool> _obscureConfirmPassword = ValueNotifier<bool>(true);

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _crefitoController.dispose();
    _crmController.dispose();
    _obscurePassword.dispose();
    _obscureConfirmPassword.dispose();
    super.dispose();
  }

  String? _validatePassword(String? value) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ), // Ícone padrão
        ),
      ),
      // SafeArea envolve tudo
      body: SafeArea(
        // SingleChildScrollView é o pai direto para garantir rolagem sem erros
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          child: Column(
            children: [
              // Logo
              Center(
                child: Image.asset(
                  'assets/images/logo-app.png',
                  width: 120,
                  height: 120,
                ),
              ),
              const SizedBox(height: 20),

              // Formulário (Removemos o Expanded aqui)
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Cadastro de Especialista',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0E382C),
                      ),
                    ),
                    const SizedBox(height: 30),

                    TextFormField(
                      controller: _nameController,
                      decoration: _inputDecoration('Nome Completo'),
                      textCapitalization: TextCapitalization.words,
                      validator: (v) => v!.isEmpty ? 'Informe o nome' : null,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _emailController,
                      decoration: _inputDecoration(
                        'E-mail para contato e login',
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) =>
                          v!.contains('@') ? null : 'E-mail inválido',
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _phoneController,
                      decoration: _inputDecoration(
                        'Telefone/WhatsApp',
                        hint: '(99) 99999-9999',
                      ),
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        PhoneInputFormatter(
                          defaultCountryCode: 'BR',
                          allowEndlessPhone: false,
                        ),
                      ],
                      validator: (v) =>
                          v!.length < 14 ? 'Telefone inválido' : null,
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _crefitoController,
                            decoration: _inputDecoration('CREFITO'),
                            inputFormatters: [crefitoMaskFormatter],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _crmController,
                            decoration: _inputDecoration('CRM'),
                            inputFormatters: [crmMaskFormatter],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    ValueListenableBuilder<bool>(
                      valueListenable: _obscurePassword,
                      builder: (context, isObscure, _) {
                        return TextFormField(
                          controller: _passwordController,
                          decoration: _inputDecoration('Senha').copyWith(
                            suffixIcon: IconButton(
                              onPressed: () =>
                                  _obscurePassword.value = !isObscure,
                              icon: Icon(
                                isObscure
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                            ),
                          ),
                          obscureText: isObscure,
                          validator: (v) =>
                              v!.length < 6 ? 'Mínimo de 6 caracteres' : null,
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    ValueListenableBuilder<bool>(
                      valueListenable: _obscureConfirmPassword,
                      builder: (context, isObscure, _) {
                        return TextFormField(
                          controller: _confirmPasswordController,
                          decoration: _inputDecoration('Confirmar Senha')
                              .copyWith(
                                suffixIcon: IconButton(
                                  onPressed: () =>
                                      _obscureConfirmPassword.value =
                                          !isObscure,
                                  icon: Icon(
                                    isObscure
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                  ),
                                ),
                              ),
                          obscureText: isObscure,
                          validator: _validatePassword,
                        );
                      },
                    ),
                    const SizedBox(height: 32),

                    // Botão com Consumer
                    Consumer<DoctorRegisterViewModel>(
                      builder: (context, viewModel, child) {
                        return SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0E382C),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: viewModel.isLoading
                                ? null
                                : () async {
                                    if (_formKey.currentState!.validate()) {
                                      // Fecha o teclado para evitar erros de UI
                                      FocusScope.of(context).unfocus();

                                      final success = await viewModel.register(
                                        name: _nameController.text.trim(),
                                        email: _emailController.text.trim(),
                                        phone: _phoneController.text.trim(),
                                        password: _passwordController.text
                                            .trim(),
                                        crefito: _crefitoController.text.trim(),
                                        crm: _crmController.text.trim(),
                                      );

                                      if (!context.mounted) return;

                                      if (success) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Especialista cadastrado com sucesso!',
                                            ),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                        Navigator.pop(context);
                                      } else {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              viewModel.error ??
                                                  'Erro desconhecido',
                                            ),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    }
                                  },
                            child: viewModel.isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : Text(
                                    'CADASTRAR',
                                    style: GoogleFonts.montserrat(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      labelStyle: const TextStyle(color: Color(0xFF0E382C)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF0E382C), width: 1.5),
      ),
    );
  }
}
