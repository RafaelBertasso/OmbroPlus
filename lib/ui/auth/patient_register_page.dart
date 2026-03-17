import 'package:Ombro_Plus/viewmodels/auth/auth_viewmodel.dart';
import 'package:Ombro_Plus/viewmodels/doctor/doctor_patients_viewmodel.dart'; // NOVO IMPORT
import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/formatters/phone_input_formatter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:provider/provider.dart';

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
  final _otherSexController = TextEditingController();

  final ValueNotifier<bool> _obscurePassword = ValueNotifier<bool>(true);
  final ValueNotifier<bool> _obscureConfirmPassword = ValueNotifier<bool>(true);

  int? age;
  String sex = 'masculino';

  String? _inviteCode;
  String? _specialistId;

  bool _isDoctorCreating = false; // NOVA VARIÁVEL PARA O FLUXO DO MÉDICO

  final maskFormatter = MaskTextInputFormatter(
    mask: '##/##/####',
    filter: {"#": RegExp(r'[0-9]')},
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      // Verifica se a tela foi aberta pelo médico
      _isDoctorCreating = args['isDoctorCreating'] ?? false;
      _inviteCode = args['inviteCode'];
      _specialistId = args['specialistId'];
    }
  }

  @override
  void initState() {
    super.initState();
    _birthDateController.addListener(_calculateAgeListener);
  }

  void _calculateAgeListener() {
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
        _resetAge();
      }
    } else {
      _resetAge();
    }
  }

  void _resetAge() {
    if (age != null) {
      setState(() {
        age = null;
        _ageController.text = '';
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _birthDateController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _otherSexController.dispose();
    _obscurePassword.dispose();
    _obscureConfirmPassword.dispose();
    super.dispose();
  }

  String? validateDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Informe a data de nascimento';
    }
    final regex = RegExp(r'^(\d{2})\/(\d{2})\/(\d{4})$');
    if (!regex.hasMatch(value)) {
      return 'Data inválida. Use dd/MM/aaaa';
    }
    if (value.length < 10) return 'Data incompleta.';
    return null;
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (age == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data de nascimento inválida.')),
      );
      return;
    }

    if (!_isDoctorCreating && (_inviteCode == null || _specialistId == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro de fluxo: Código de convite ausente.'),
        ),
      );
      return;
    }

    final finalSex = sex == 'outro' ? _otherSexController.text.trim() : sex;
    if (finalSex.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, especifique o sexo.')),
      );
      return;
    }

    // --- NOVA LÓGICA DIVIDIDA ---
    if (_isDoctorCreating) {
      // 1. FLUXO DO MÉDICO CRIANDO O PACIENTE
      final viewModel = context.read<DoctorPatientsViewModel>();

      final success = await viewModel.createNewPatientAccount(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        nome: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        birthDate: _birthDateController.text.trim(),
        age: age!,
        sex: finalSex,
      );

      if (success && mounted) {
        Navigator.pop(context); // Volta para a lista de pacientes
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Paciente criado com sucesso!')),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(viewModel.error ?? 'Erro ao cadastrar paciente'),
          ),
        );
      }
    } else {
      // 2. FLUXO ORIGINAL DO PACIENTE SE CADASTRANDO VIA CONVITE
      final viewModel = context.read<AuthViewModel>();

      final success = await viewModel.registerPatient(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        nome: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        birthDate: _birthDateController.text.trim(),
        age: age!,
        sex: finalSex,
        inviteCode: _inviteCode!,
        specialistId: _specialistId!,
      );

      if (success && mounted) {
        Navigator.popUntil(context, (route) => route.isFirst);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(viewModel.error ?? 'Erro ao cadastrar')),
        );
      }
    }
  }

  MaterialStateProperty<Color> radioFillColor() {
    return MaterialStateProperty.resolveWith((states) {
      if (states.contains(MaterialState.selected)) {
        return Color(0xFF0E382C);
      }
      return Colors.grey;
    });
  }

  @override
  Widget build(BuildContext context) {
    // ALTERAÇÃO: O ícone de carregamento agora lê do viewModel certo
    final isLoading = _isDoctorCreating
        ? context.select<DoctorPatientsViewModel, bool>((vm) => vm.isLoading)
        : context.select<AuthViewModel, bool>((vm) => vm.isLoading);

    return Scaffold(
      backgroundColor: Color(0xFFF4F7F6),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.arrow_back, color: Colors.black),
                  ),
                  const Spacer(),
                  Image.asset(
                    'assets/images/logo-app.png',
                    width: 120,
                    height: 120,
                  ),
                  const Spacer(),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Se for o médico, podemos dar um pequeno título na tela!
                      if (_isDoctorCreating)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 24.0),
                          child: Text(
                            'Dados do Novo Paciente',
                            style: GoogleFonts.montserrat(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF0E382C),
                            ),
                          ),
                        ),
                      TextFormField(
                        controller: _nameController,
                        textCapitalization: TextCapitalization.words,
                        decoration: InputDecoration(labelText: 'Nome completo'),
                        validator: (v) =>
                            v!.isEmpty ? 'Campo obrigatório' : null,
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
                              ),
                              validator: validateDate,
                            ),
                          ),
                          SizedBox(width: 12),
                          SizedBox(
                            width: 60,
                            child: TextFormField(
                              controller: _ageController,
                              enabled: false,
                              decoration: InputDecoration(labelText: 'Idade'),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Text('Sexo', style: GoogleFonts.openSans(fontSize: 16)),
                      Row(
                        children: [
                          _buildRadio('Masculino', 'masculino'),
                          _buildRadio('Feminino', 'feminino'),
                        ],
                      ),
                      Row(
                        children: [
                          Radio<String>(
                            value: 'outro',
                            groupValue: sex,
                            fillColor: radioFillColor(),
                            onChanged: (v) => setState(() => sex = v!),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: TextFormField(
                              controller: _otherSexController,
                              onTap: () {
                                setState(() {
                                  sex = 'outro';
                                });
                              },
                              decoration: InputDecoration(
                                labelText: 'Digite Aqui',
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              ),
                            ),
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
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(labelText: 'Email'),
                        validator: (v) =>
                            !v!.contains('@') ? 'Email inválido' : null,
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          PhoneInputFormatter(
                            defaultCountryCode: 'BR',
                            allowEndlessPhone: false,
                          ),
                        ],
                        decoration: InputDecoration(
                          labelText: 'Telefone',
                          hintText: '(99) 99999-9999',
                        ),
                        validator: (v) =>
                            v!.length < 14 ? 'Telefone inválido' : null,
                      ),
                      SizedBox(height: 16),
                      ValueListenableBuilder<bool>(
                        valueListenable: _obscurePassword,
                        builder: (context, obscure, _) {
                          return TextFormField(
                            controller: _passwordController,
                            obscureText: obscure,
                            decoration: InputDecoration(
                              labelText: 'Senha Inicial',
                              suffixIcon: IconButton(
                                onPressed: () =>
                                    _obscurePassword.value = !obscure,
                                icon: Icon(
                                  obscure
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                              ),
                            ),
                            validator: (v) =>
                                v!.length < 6 ? 'Mínimo 6 caracteres' : null,
                          );
                        },
                      ),
                      SizedBox(height: 16),
                      ValueListenableBuilder<bool>(
                        valueListenable: _obscureConfirmPassword,
                        builder: (context, obscure, _) {
                          return TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: obscure,
                            decoration: InputDecoration(
                              labelText: 'Confirmar Senha',
                              suffixIcon: IconButton(
                                onPressed: () =>
                                    _obscureConfirmPassword.value = !obscure,
                                icon: Icon(
                                  obscure
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                              ),
                            ),
                            validator: (v) => v != _passwordController.text
                                ? 'Senhas não conferem'
                                : null,
                          );
                        },
                      ),
                      SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _handleRegister,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF0E382C),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: isLoading
                              ? CircularProgressIndicator(color: Colors.white)
                              : Text(
                                  _isDoctorCreating
                                      ? 'Criar Paciente'
                                      : 'Cadastrar',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRadio(String label, String value) {
    return Row(
      children: [
        Radio<String>(
          value: value,
          groupValue: sex,
          fillColor: radioFillColor(),
          onChanged: (v) => setState(() => sex = v!),
        ),
        Text(label, style: GoogleFonts.openSans(fontSize: 16)),
        SizedBox(width: 10),
      ],
    );
  }
}
