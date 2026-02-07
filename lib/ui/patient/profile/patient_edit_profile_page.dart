import 'package:Ombro_Plus/ui/shared/widgets/app_logo.dart';
import 'package:Ombro_Plus/viewmodels/patient/patient_edit_profile_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/formatters/phone_input_formatter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class PatientEditProfilePage extends StatefulWidget {
  const PatientEditProfilePage({super.key});

  @override
  State<PatientEditProfilePage> createState() => _PatientEditProfilePageState();
}

class _PatientEditProfilePageState extends State<PatientEditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _birthDateController;
  late TextEditingController _sexController;

  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _birthDateController = TextEditingController();
    _sexController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_isInitialized) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      final passedId = args?['id'] as String?;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<PatientEditProfileViewModel>().initialize(passedId).then((
          _,
        ) {
          final vm = context.read<PatientEditProfileViewModel>();
          if (vm.userData != null) {
            _nameController.text = vm.userData!['nome'] ?? '';
            _emailController.text = vm.userData!['email'] ?? '';
            _phoneController.text = vm.userData!['telefone'] ?? '';
            _birthDateController.text =
                vm.userData!['data_nascimento'] ?? 'Não informado';
            _sexController.text = vm.userData!['sexo'] ?? 'Não informado';
          }
        });
      });
      _isInitialized = true;
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
      body: Consumer<PatientEditProfileViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF0E382C)),
            );
          }

          if (viewModel.error != null && viewModel.userData == null) {
            return Center(child: Text("Erro: ${viewModel.error}"));
          }

          return Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.only(
                  top: 40,
                  left: 16,
                  right: 16,
                  bottom: 10,
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                    ),
                    const Spacer(),
                    const AppLogo(),
                    const Spacer(),
                    const SizedBox(width: 48), // Balanço visual
                  ],
                ),
              ),

              Text(
                'Editar Dados',
                style: GoogleFonts.montserrat(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0E382C),
                ),
              ),
              const SizedBox(height: 16),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _nameController,
                          decoration: _inputDecoration(
                            'Nome Completo',
                          ).copyWith(enabled: false),
                          readOnly: true,
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _phoneController,
                          decoration: _inputDecoration('Telefone/WhatsApp'),
                          keyboardType: TextInputType.phone,
                          inputFormatters: [
                            PhoneInputFormatter(
                              defaultCountryCode: 'BR',
                              allowEndlessPhone: false,
                            ),
                          ],
                          validator: (v) => v!.isEmpty
                              ? 'O telefone não pode ser vazio'
                              : null,
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _emailController,
                          decoration: _inputDecoration('E-mail de Login').copyWith(
                            helperText:
                                'Alterar o e-mail requer verificação por link.',
                            helperStyle: const TextStyle(color: Colors.black54),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) =>
                              v!.isEmpty ? 'O email não pode ser vazio' : null,
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _birthDateController,
                          decoration: _inputDecoration(
                            'Data de Nascimento',
                          ).copyWith(enabled: false),
                          readOnly: true,
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _sexController,
                          decoration: _inputDecoration(
                            'Sexo',
                          ).copyWith(enabled: false),
                          readOnly: true,
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                        const SizedBox(height: 32),

                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0E382C),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: viewModel.isSaving
                                ? null
                                : () async {
                                    if (_formKey.currentState!.validate()) {
                                      FocusScope.of(context).unfocus();

                                      final success = await viewModel
                                          .saveProfile(
                                            name: _nameController.text.trim(),
                                            email: _emailController.text.trim(),
                                            phone: _phoneController.text.trim(),
                                            context: context,
                                          );

                                      if (success && context.mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Perfil atualizado com sucesso!',
                                            ),
                                          ),
                                        );
                                        Navigator.pop(context, true);
                                      } else if (viewModel.error != null &&
                                          context.mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(viewModel.error!),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    }
                                  },
                            child: viewModel.isSaving
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : Text(
                                    'SALVAR ALTERAÇÕES',
                                    style: GoogleFonts.montserrat(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
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
          );
        },
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Color(0xFF0E382C)),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF0E382C), width: 1.5),
      ),
    );
  }
}
