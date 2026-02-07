import 'package:Ombro_Plus/ui/shared/widgets/section_title.dart';
import 'package:Ombro_Plus/ui/shared/widgets/radio_group_field.dart';
import 'package:Ombro_Plus/ui/shared/widgets/styled_dropdown_field.dart';
import 'package:Ombro_Plus/viewmodels/shared/patient_clinical_form_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class PatientClinicalFormPage extends StatefulWidget {
  const PatientClinicalFormPage({super.key});

  @override
  State<PatientClinicalFormPage> createState() =>
      _PatientClinicalFormPageState();
}

class _PatientClinicalFormPageState extends State<PatientClinicalFormPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers de Texto (A View cuida do texto, o ViewModel cuida dos valores selecionados)
  final _doencasAssociadasController = TextEditingController();
  final _diagnosticoOutroController = TextEditingController();
  final _detalhesTratamentoController = TextEditingController();
  final _dataTratamentoController = MaskedTextController(mask: '00/00/0000');
  final _medicoResponsavelController = TextEditingController();
  final _objetivoOutroController = TextEditingController();
  final _dificuldadesOutrasController = TextEditingController();

  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      final patientId = args?['id'] as String?;

      if (patientId != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _loadData(patientId);
        });
      } else {
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => Navigator.pop(context),
        );
      }
      _isInitialized = true;
    }
  }

  Future<void> _loadData(String patientId) async {
    final viewModel = context.read<PatientClinicalFormViewModel>();
    final data = await viewModel.loadClinicalData(patientId);

    // Popula os controllers com os textos que vieram do banco
    if (data != null && mounted) {
      _doencasAssociadasController.text = data['doencasAssociadas'] ?? '';
      _detalhesTratamentoController.text = data['detalhesTratamento'] ?? '';
      _dataTratamentoController.text = data['dataTratamento'] ?? '';
      _medicoResponsavelController.text = data['medicoResponsavel'] ?? '';

      _diagnosticoOutroController.text = data['diagnosticoOutroText'] ?? '';
      _objetivoOutroController.text = data['objetivoOutroText'] ?? '';
      _dificuldadesOutrasController.text = data['dificuldadesOutrosText'] ?? '';
    }
  }

  @override
  void dispose() {
    _detalhesTratamentoController.dispose();
    _dataTratamentoController.dispose();
    _medicoResponsavelController.dispose();
    _doencasAssociadasController.dispose();
    _diagnosticoOutroController.dispose();
    _objetivoOutroController.dispose();
    _dificuldadesOutrasController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(primary: Color(0xFF0E382C)),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _dataTratamentoController.text = DateFormat(
          'dd/MM/yyyy',
        ).format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      appBar: AppBar(
        title: Text(
          'Ficha Clínica',
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF0E382C),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Consumer<PatientClinicalFormViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF0E382C)),
            );
          }

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const SectionTitle(title: '1. Histórico e Condições Gerais'),
                const SizedBox(height: 10),

                RadioGroupField<LadoAfetado>(
                  title: 'Lado Afetado',
                  groupValue: viewModel.ladoAfetado,
                  onChanged: viewModel.setLadoAfetado,
                  values: LadoAfetado.values,
                ),

                RadioGroupField<String>(
                  title: 'Já fez Fisioterapia antes?',
                  groupValue: viewModel.fezFisioterapiaAntes == true
                      ? 'Sim'
                      : (viewModel.fezFisioterapiaAntes == false
                            ? 'Não'
                            : null),
                  onChanged: viewModel.setFezFisioterapia,
                  values: const ['Sim', 'Não'],
                ),

                TextFormField(
                  controller: _doencasAssociadasController,
                  decoration: const InputDecoration(
                    labelText: 'Doenças Associadas (ex: Diabetes)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 30),

                const SectionTitle(title: '2. Diagnóstico e Tratamento'),
                const SizedBox(height: 10),

                StyledDropdownField<String>(
                  labelText: 'Diagnóstico Principal',
                  initialValue: viewModel.diagnosticoPrincipal,
                  onChanged: (val) {
                    viewModel.setDiagnostico(val);
                    if (val != 'Outro') _diagnosticoOutroController.clear();
                  },
                  items: viewModel.diagnosticos
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  validator: (v) => v == null ? 'Obrigatório' : null,
                ),
                if (viewModel.isDiagnosticoOutroSelected)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: TextFormField(
                      controller: _diagnosticoOutroController,
                      decoration: const InputDecoration(
                        labelText: 'Especifique o Diagnóstico',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) =>
                          v!.isEmpty ? 'Especifique o diagnóstico' : null,
                    ),
                  ),
                const SizedBox(height: 16),

                RadioGroupField<String>(
                  title: 'Tipo de Tratamento Feito:',
                  groupValue: viewModel.tipoTratamento,
                  onChanged: (val) {
                    viewModel.setTipoTratamento(val);
                    if (val != 'Cirurgia') {
                      _detalhesTratamentoController.clear();
                    }
                  },
                  values: const ['Cirurgia', 'Conservador'],
                ),

                TextFormField(
                  controller: _detalhesTratamentoController,
                  decoration: InputDecoration(
                    labelText: 'Detalhes da Cirurgia (Qual foi feita?)',
                    border: const OutlineInputBorder(),
                    enabled: viewModel.tipoTratamento == 'Cirurgia',
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _dataTratamentoController,
                  decoration: const InputDecoration(
                    labelText: 'Data de Início/Cirurgia',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  readOnly: true,
                  onTap: () => _selectDate(context),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _medicoResponsavelController,
                  decoration: const InputDecoration(
                    labelText: 'Médico Responsável',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 30),

                const SectionTitle(title: '3. Situação Funcional e Metas'),
                const SizedBox(height: 10),

                StyledDropdownField<String>(
                  labelText: 'Objetivo Principal',
                  initialValue: viewModel.objetivoTratamento,
                  onChanged: (val) {
                    viewModel.setObjetivo(val);
                    if (val != 'Outro') _objetivoOutroController.clear();
                  },
                  items: viewModel.objetivos
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                ),
                if (viewModel.isObjetivoOutroSelected)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: TextFormField(
                      controller: _objetivoOutroController,
                      decoration: const InputDecoration(
                        labelText: 'Especifique o Objetivo',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) =>
                          v!.isEmpty ? 'Especifique o objetivo' : null,
                    ),
                  ),
                const SizedBox(height: 16),

                RadioGroupField<NivelDor>(
                  title: 'Dor (Nível de Intensidade)',
                  groupValue: viewModel.nivelDor,
                  onChanged: viewModel.setNivelDor,
                  values: NivelDor.values,
                ),

                RadioGroupField<NivelMobilidade>(
                  title: 'Mobilidade do Ombro',
                  groupValue: viewModel.mobilidadeOmbro,
                  onChanged: viewModel.setMobilidade,
                  values: NivelMobilidade.values,
                ),

                // Checkboxes de Dificuldades
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 4),
                      child: Text(
                        'Dificuldades Principais:',
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    ...viewModel.dificuldadesPrincipais.keys.map((key) {
                      return CheckboxListTile(
                        title: Text(key),
                        value: viewModel.dificuldadesPrincipais[key],
                        activeColor: const Color(0xFF0E382C),
                        controlAffinity: ListTileControlAffinity.leading,
                        dense: true,
                        onChanged: (bool? val) {
                          viewModel.setDificuldade(key, val ?? false);
                          if (key == 'Outros' && val == false)
                            _dificuldadesOutrasController.clear();
                        },
                      );
                    }),
                    if (viewModel.dificuldadesPrincipais['Outros'] == true)
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 16,
                          left: 16,
                          right: 16,
                        ),
                        child: TextFormField(
                          controller: _dificuldadesOutrasController,
                          decoration: const InputDecoration(
                            labelText: 'Especifique a Dificuldade',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) => v!.isEmpty ? 'Especifique' : null,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 30),

                // Botão Salvar
                ElevatedButton(
                  onPressed: viewModel.isSaving
                      ? null
                      : () async {
                          if (_formKey.currentState!.validate()) {
                            FocusScope.of(context).unfocus();
                            final success = await viewModel.saveClinicalData(
                              doencas: _doencasAssociadasController.text.trim(),
                              detalhesTratamento: _detalhesTratamentoController
                                  .text
                                  .trim(),
                              dataTratamento: _dataTratamentoController.text
                                  .trim(),
                              medico: _medicoResponsavelController.text.trim(),
                              diagnosticoOutro: _diagnosticoOutroController.text
                                  .trim(),
                              objetivoOutro: _objetivoOutroController.text
                                  .trim(),
                              dificuldadesOutro: _dificuldadesOutrasController
                                  .text
                                  .trim(),
                            );
                            if (success && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Ficha atualizada!'),
                                ),
                              );
                              Navigator.pop(context, true);
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0E382C),
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: viewModel.isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'Salvar Ficha',
                          style: GoogleFonts.montserrat(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }
}
