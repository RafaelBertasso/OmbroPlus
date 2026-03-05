import 'package:Ombro_Plus/ui/shared/widgets/section_title.dart';
import 'package:Ombro_Plus/models/exercise_model.dart';
import 'package:Ombro_Plus/viewmodels/doctor/add_exercise_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ProtocolExerciseAdderPage extends StatefulWidget {
  const ProtocolExerciseAdderPage({super.key});

  @override
  State<ProtocolExerciseAdderPage> createState() =>
      _ProtocolExerciseAdderPageState();
}

class _ProtocolExerciseAdderPageState extends State<ProtocolExerciseAdderPage> {
  final _formKey = GlobalKey<FormState>();
  final _seriesController = TextEditingController();
  final _repetitionsController = TextEditingController();

  TextEditingController? _autoCompleteController;

  @override
  void initState() {
    super.initState();
    // Inicializa sem argumentos de data, apenas carrega exercícios
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AddExerciseViewModel>().initialize();
    });
  }

  @override
  void dispose() {
    _seriesController.dispose();
    _repetitionsController.dispose();
    super.dispose();
  }

  Widget _buildExerciseAutocomplete(AddExerciseViewModel viewModel) {
    return Row(
      children: [
        Expanded(
          child: Autocomplete<ExerciseModel>(
            displayStringForOption: (ExerciseModel option) => option.nome,
            optionsBuilder: (TextEditingValue textEditingValue) {
              if (textEditingValue.text.isEmpty) {
                return const Iterable<ExerciseModel>.empty();
              }
              return viewModel.allExercises.where((ExerciseModel option) {
                return option.nome.toLowerCase().contains(
                  textEditingValue.text.toLowerCase(),
                );
              });
            },
            onSelected: (ExerciseModel selection) {
              viewModel.selectExercise(selection);
            },
            fieldViewBuilder:
                (context, controller, focusNode, onEditingComplete) {
                  _autoCompleteController = controller;

                  return TextFormField(
                    controller: controller,
                    focusNode: focusNode,
                    onEditingComplete: onEditingComplete,
                    decoration: InputDecoration(
                      labelText: 'Buscar Exercício',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    onChanged: (value) {
                      if (viewModel.selectedExercise != null) {
                        if (value != viewModel.selectedExercise!.nome) {
                          viewModel.selectExercise(null);
                        }
                      }
                    },
                    validator: (v) => viewModel.selectedExercise == null
                        ? 'Selecione um exercício da lista'
                        : null,
                  );
                },
          ),
        ),
        const SizedBox(width: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0E382C).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Builder(
            builder: (context) => IconButton(
              icon: const Icon(
                Icons.add_box_outlined,
                color: Color(0xFF0E382C),
              ),
              tooltip: 'Novo Exercício',
              onPressed: () async {
                final result = await Navigator.pushNamed(
                  context,
                  '/new-exercise',
                );
                if (result == true && mounted) {
                  viewModel.refreshExercises();
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExercisesDrawer(AddExerciseViewModel viewModel) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          Container(
            color: const Color(0xFF0E382C),
            padding: const EdgeInsets.fromLTRB(16, 50, 16, 16),
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Biblioteca de Exercícios',
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${viewModel.allExercises.length} disponíveis',
                  style: GoogleFonts.openSans(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          Expanded(
            child: viewModel.allExercises.isEmpty
                ? const Center(child: Text("Nenhum exercício carregado."))
                : ListView.separated(
                    itemCount: viewModel.allExercises.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final exercise = viewModel.allExercises[index];
                      return ListTile(
                        title: Text(
                          exercise.nome,
                          style: GoogleFonts.openSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        trailing: const Icon(
                          Icons.arrow_back,
                          size: 16,
                          color: Color(0xFF0E382C),
                        ),
                        onTap: () {
                          viewModel.selectExercise(exercise);
                          Navigator.pop(context); // Fecha o drawer
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    return Consumer<AddExerciseViewModel>(
      builder: (context, viewModel, child) {
        // Atualiza o texto do autocomplete se o exercício for selecionado via Drawer
        if (viewModel.selectedExercise != null &&
            _autoCompleteController != null) {
          if (_autoCompleteController!.text !=
              viewModel.selectedExercise!.nome) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _autoCompleteController!.text = viewModel.selectedExercise!.nome;
            });
          }
        }

        if (viewModel.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF4F7F6),
          appBar: AppBar(
            backgroundColor: const Color(0xFF0E382C),
            title: Text(
              'Adicionar à Sessão',
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            centerTitle: true,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          endDrawer: _buildExercisesDrawer(viewModel),
          body: Form(
            key: _formKey,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionTitle(title: '1. Seleção de Exercício'),
                        const SizedBox(height: 10),

                        _buildExerciseAutocomplete(viewModel),

                        const SizedBox(height: 20),
                        const Divider(),
                        const SizedBox(height: 10),

                        const SectionTitle(title: '2. Configuração da Carga'),
                        const SizedBox(height: 16),

                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _seriesController,
                                keyboardType: TextInputType.number,
                                decoration: _inputDecoration('Séries'),
                                validator: (v) =>
                                    v!.isEmpty ? 'Obrigatório' : null,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: _repetitionsController,
                                keyboardType: TextInputType.number,
                                decoration: _inputDecoration('Repetições'),
                                validator: (v) =>
                                    v!.isEmpty ? 'Obrigatório' : null,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Botão Salvar Fixo no Rodapé
                Container(
                  margin: EdgeInsets.only(bottom: bottomPadding + 30),
                  padding: const EdgeInsets.all(20),
                  color: Colors.white,
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0E382C),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          final result = viewModel.saveEntry(
                            _seriesController.text,
                            _repetitionsController.text,
                          );

                          if (result != null) {
                            Navigator.pop(context, result);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Selecione um exercício válido.'),
                              ),
                            );
                          }
                        }
                      },
                      child: Text(
                        'Adicionar Exercício',
                        style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      filled: true,
      fillColor: Colors.white,
    );
  }
}
