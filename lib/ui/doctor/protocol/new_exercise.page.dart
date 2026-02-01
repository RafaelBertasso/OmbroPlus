import 'package:Ombro_Plus/components/section.title.dart';
import 'package:Ombro_Plus/viewmodels/doctor/new_exercise.viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class NewExercisePage extends StatefulWidget {
  const NewExercisePage({super.key});

  @override
  State<NewExercisePage> createState() => _NewExercisePageState();
}

class _NewExercisePageState extends State<NewExercisePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _youtubeUrlController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _youtubeUrlController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final viewModel = context.read<NewExerciseViewModel>();

    final success = await viewModel.saveExercise(
      nome: _nameController.text.trim(),
      descricao: _descriptionController.text.trim(),
      youtubeUrl: _youtubeUrlController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Exercício salvo com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(viewModel.error ?? 'Erro ao salvar.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Usamos select para reconstruir apenas se o loading mudar
    final isLoading = context.select<NewExerciseViewModel, bool>(
      (vm) => vm.isLoading,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0E382C),
        title: Text(
          'Adicionar Exercício',
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white, size: 26),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionTitle(title: 'Identificação do Exercício'),
              const SizedBox(height: 16),

              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.sentences,
                decoration: _inputDecoration(
                  'Nome do Exercício',
                  hint: 'Ex: Elevação Lateral do Ombro',
                ),
                validator: (value) =>
                    value!.isEmpty ? 'O nome é obrigatório.' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _descriptionController,
                textCapitalization: TextCapitalization.sentences,
                maxLines: 6,
                decoration: _inputDecoration(
                  'Descrição e Instruções',
                  hint: 'Passos detalhados para o paciente',
                ).copyWith(alignLabelWithHint: true),
                validator: (value) =>
                    value!.isEmpty ? 'A descrição é obrigatória.' : null,
              ),
              const SizedBox(height: 30),

              SectionTitle(title: 'Vídeo de Ajuda'),
              const SizedBox(height: 16),

              TextFormField(
                controller: _youtubeUrlController,
                keyboardType: TextInputType.url,
                decoration:
                    _inputDecoration(
                      'Link do Youtube',
                      hint: 'Cole o link do seu vídeo aqui',
                    ).copyWith(
                      prefixIcon: const Icon(
                        Icons.videocam_rounded,
                        color: Color(0xFF0E382C),
                      ),
                    ),
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    // Validação rápida na UI, validação real ocorre no ViewModel
                    if (!value.contains('youtube.com') &&
                        !value.contains('youtu.be')) {
                      return 'Link do YouTube inválido';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),

              Text(
                'O vídeo será exibido no aplicativo do paciente. Use um vídeo claro e objetivo.',
                style: GoogleFonts.openSans(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _handleSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0E382C),
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'Salvar Exercício',
                          style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),
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
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      filled: true,
      fillColor: Colors
          .white, // Alterado para branco para contraste melhor no fundo cinza
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
}
