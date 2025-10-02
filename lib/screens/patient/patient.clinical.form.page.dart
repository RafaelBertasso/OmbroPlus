import 'package:Ombro_Plus/components/section.title.dart';
import 'package:Ombro_Plus/components/radio.group.field.dart';
import 'package:Ombro_Plus/components/styled.dropdown.field.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

enum LadoAfetado { direito, esquerdo, ambos }

enum NivelDor { leve, moderado, intensa }

enum NivelMobilidade { limitada, parcial, boa }

class PatientClinicalFormPage extends StatefulWidget {
  const PatientClinicalFormPage({super.key});

  @override
  State<PatientClinicalFormPage> createState() =>
      _PatientClinicalFormPageState();
}

class _PatientClinicalFormPageState extends State<PatientClinicalFormPage> {
  final _formKey = GlobalKey<FormState>();
  String? _patientId;
  bool _isLoading = true;
  bool _isSaving = false;

  String? _diagnosticoPrincipal;
  bool _isDiagnosticoOutroSelected = false;
  final _diagnosticoOutroController = TextEditingController();
  String? _tipoTratamento;
  final _detalhesTratamentoController = TextEditingController();
  final _dataTratamentoController = MaskedTextController(mask: '00/00/0000');
  final _medicoResponsavelController = TextEditingController();

  LadoAfetado? _ladoAfetado;
  bool? _fezFisioterapiaAntes;
  final _doencasAssociadasController = TextEditingController();
  NivelDor? _nivelDor;
  NivelMobilidade? _mobilidadeOmbro;
  Map<String, bool> _dificuldadesPrincipais = {
    'Levantar Braço': false,
    'Dormir': false,
    'Atividades Diárias': false,
    'Exercícios': false,
    'Outros': false,
  };
  final _dificuldadesOutrasController = TextEditingController();
  String? _objetivoTratamento;
  bool _isObjetivoOutroSelected = false;
  final _objetivoOutroController = TextEditingController();

  final List<String> _diagnosticos = [
    'Lesão do Manguito Rotador',
    'Luxação',
    'Artrose',
    'Fratura',
    'Reparo Cirúrgico',
    'Instabilidade',
    'Outro',
  ];
  final List<String> _objetivos = [
    'Voltar ao Esporte',
    'Melhorar Dor',
    'Rotina Diária',
    'Estética',
    'Outro',
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_patientId == null) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      _patientId = args?['id'] as String?;

      if (_patientId != null) {
        _loadClinicalData();
      } else {
        final dynamic idValue = args?['id'];
        if (idValue is String) {
          _patientId = idValue;
          _loadClinicalData();
        } else {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pop(context);
          });
        }
      }
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

  Future<void> _loadClinicalData() async {
    if (_patientId == null) return;
    await Future.delayed(Duration(milliseconds: 500));

    try {
      final doc = await FirebaseFirestore.instance
          .collection('pacientes')
          .doc(_patientId)
          .get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;

        setState(() {
          _diagnosticoPrincipal = data['diagnosticoPrincipal'];
          //TODO: completar carregamento dos campos
        });
      }
    } catch (e) {
      print('Erro ao carregar dados clínicos: $e');
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _saveClinicalData() async {
    if (!_formKey.currentState!.validate() || _patientId == null) return;
    setState(() {
      _isSaving = true;
    });

    String? finalDiagnostico = _diagnosticoPrincipal;
    if (_isDiagnosticoOutroSelected) {
      final specifiedText = _diagnosticoOutroController.text.trim();
      if (specifiedText.isNotEmpty) {
        finalDiagnostico = 'Outro: $specifiedText';
      }
    }
    String? finalObjetivo = _objetivoTratamento;
    if (_isObjetivoOutroSelected) {
      final specifiedText = _objetivoOutroController.text.trim();
      if (specifiedText.isNotEmpty) {
        finalObjetivo = 'Outro: $specifiedText';
      }
    }
    final List<String> dificuldadesSelecionadas = [];
    _dificuldadesPrincipais.forEach((key, isSelected) {
      if (isSelected) {
        if (key == 'Outros') {
          final specifiedText = _dificuldadesOutrasController.text.trim();
          if (specifiedText.isNotEmpty) {
            dificuldadesSelecionadas.add('Outras: $specifiedText');
          }
        } else {
          dificuldadesSelecionadas.add(key);
        }
      }
    });
    try {
      await FirebaseFirestore.instance
          .collection('pacientes')
          .doc(_patientId)
          .set({
            'ladoAfetado': _ladoAfetado?.name,
            'fezFisioterapiaAntes': _fezFisioterapiaAntes,
            'doencasAssociadas': _doencasAssociadasController.text.trim(),

            'diagnosticoPrincipal': finalDiagnostico,
            'tipoTratamento': _tipoTratamento,
            'detalhesTratamento': _detalhesTratamentoController.text.trim(),
            'dataTratamento': _dataTratamentoController.text.trim(),
            'medicoResponsavel': _medicoResponsavelController.text.trim(),

            'nivelDor': _nivelDor?.name,
            'mobilidadeOmbro': _mobilidadeOmbro?.name,
            'dificuldadesPrincipais': dificuldadesSelecionadas,
            'objetivoTratamento': finalObjetivo,

            'lastClinicalUpdate': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ficha clínica salva com sucesso!')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao salvar ficha')));
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(0xFF0E382C),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: Color(0xFF0E382C)),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        final formattedDate = DateFormat('dd/MM/yyyy').format(picked);
        _dataTratamentoController.text = formattedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF4F7F6),
      appBar: AppBar(
        title: Text(
          'Ficha Clínica',
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFF0E382C),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Color(0xFF0E382C)))
          : Form(
              key: _formKey,
              child: ListView(
                padding: EdgeInsets.all(20),
                children: [
                  SectionTitle(title: '1. Histórico e Condições Gerais'),
                  SizedBox(height: 10),
                  RadioGroupField(
                    title: 'Lado Afetado',
                    groupValue: _ladoAfetado,
                    onChanged: (val) => setState(() {
                      _ladoAfetado = val;
                    }),
                    values: LadoAfetado.values,
                  ),
                  RadioGroupField(
                    title: 'Já fez Fisioterapia antes?',
                    groupValue: _fezFisioterapiaAntes,
                    onChanged: (val) => setState(() {
                      _fezFisioterapiaAntes = val;
                    }),
                    values: [true, false],
                  ),
                  TextFormField(
                    controller: _doencasAssociadasController,
                    decoration: InputDecoration(
                      labelText: 'Doenças Associadas (ex: Diabetes)',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                  SizedBox(height: 30),
                  SectionTitle(title: '2. Diagnóstico e Tratamento'),
                  SizedBox(height: 10),
                  StyledDropdownField<String>(
                    labelText: 'Diagnóstico Principal',
                    initialValue: _diagnosticoPrincipal,
                    onChanged: (val) => setState(() {
                      _diagnosticoPrincipal = val;
                      final bool isOutro = val == 'Outro';
                      _isDiagnosticoOutroSelected = isOutro;
                      if (!isOutro) {
                        _diagnosticoOutroController.clear();
                      }
                    }),
                    items: _diagnosticos
                        .map(
                          (e) => DropdownMenuItem<String>(
                            value: e,
                            child: Text(e),
                          ),
                        )
                        .toList(),
                    validator: (value) => value == null ? 'Obrigatório' : null,
                  ),
                  if (_isDiagnosticoOutroSelected)
                    Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: TextFormField(
                        controller: _diagnosticoOutroController,
                        decoration: InputDecoration(
                          labelText: 'Especifique',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 2,
                        validator: (value) {
                          if (_isDiagnosticoOutroSelected &&
                              (value == null || value.isEmpty)) {
                            return 'A especificação do diagnóstico é obrigatória.';
                          }
                          return null;
                        },
                      ),
                    ),
                  SizedBox(height: 16),
                  RadioGroupField(
                    title: 'Tipo de Tratamento Feito:',
                    groupValue: _tipoTratamento,
                    onChanged: (val) => setState(() {
                      _tipoTratamento = val;
                    }),
                    values: ['Cirurgia', 'Conservador'],
                  ),
                  TextFormField(
                    controller: _detalhesTratamentoController,
                    decoration: InputDecoration(
                      labelText:
                          'Detalhes \n(Qual Cirurgia/Fisioterapia? quando?)',
                      border: OutlineInputBorder(),
                      enabled: _tipoTratamento != null,
                    ),
                    validator: (value) {
                      if (_tipoTratamento != null &&
                          (value == null || value.isEmpty)) {
                        return 'Detalhes do tratamento são obrigatórios';
                      }
                      return null;
                    },
                    maxLines: 2,
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _dataTratamentoController,
                    decoration: InputDecoration(
                      labelText: 'Data da Cirurgia / Início do Tratamento',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.calendar_today_outlined),
                    ),
                    readOnly: true,
                    onTap: () => _selectDate(context),
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _medicoResponsavelController,
                    decoration: InputDecoration(
                      labelText: 'Médico Responsável',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 30),
                  SectionTitle(title: '3. Situação Funcional e Metas'),
                  SizedBox(height: 10),
                  StyledDropdownField<String>(
                    labelText: 'Objetivo Principal do Tratamento',
                    initialValue: _objetivoTratamento,
                    onChanged: (val) => setState(() {
                      _objetivoTratamento = val;
                      final bool isOutro = val == 'Outro';
                      _isObjetivoOutroSelected = isOutro;
                      if (!isOutro) {
                        _objetivoOutroController.clear();
                      }
                    }),
                    items: _objetivos
                        .map(
                          (e) => DropdownMenuItem<String>(
                            value: e,
                            child: Text(e),
                          ),
                        )
                        .toList(),
                    validator: (value) => value == null ? 'Obrigatório' : null,
                  ),
                  if (_isObjetivoOutroSelected)
                    Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: TextFormField(
                        controller: _objetivoOutroController,
                        decoration: InputDecoration(
                          labelText: 'Especifique',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 2,
                        validator: (value) {
                          if (_isObjetivoOutroSelected &&
                              (value == null || value.isEmpty)) {
                            return 'Por favor, especifique o objetivo.';
                          }
                          return null;
                        },
                      ),
                    ),
                  SizedBox(height: 16),
                  RadioGroupField<NivelDor>(
                    title: 'Dor (Nível de Intensidade)',
                    groupValue: _nivelDor,
                    onChanged: (val) => setState(() {
                      _nivelDor = val;
                    }),
                    values: NivelDor.values,
                  ),
                  RadioGroupField<NivelMobilidade>(
                    title: 'Mobilidade do Ombro',
                    groupValue: _mobilidadeOmbro,
                    onChanged: (val) => setState(() {
                      _mobilidadeOmbro = val;
                    }),
                    values: NivelMobilidade.values,
                  ),
                  _buildDificuldadesCheckboxes(),
                  SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: _isSaving ? null : _saveClinicalData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0E382C),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isSaving
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
            ),
    );
  }

  Widget _buildDificuldadesCheckboxes() {
    final bool isOutroSelected = _dificuldadesPrincipais['Outros'] ?? false;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 8, bottom: 4),
          child: Text(
            'Dificuldades Principais:',
            style: GoogleFonts.montserrat(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
        ..._dificuldadesPrincipais.keys.map((key) {
          return CheckboxListTile(
            title: Text(key),
            value: _dificuldadesPrincipais[key],
            onChanged: (bool? value) {
              setState(() {
                _dificuldadesPrincipais[key] = value!;

                if (key == 'Outros' && value == false) {
                  _dificuldadesOutrasController.clear();
                }
              });
            },
            activeColor: Color(0xFF0E382C),
            controlAffinity: ListTileControlAffinity.leading,
            dense: true,
          );
        }),
        if (isOutroSelected)
          Padding(
            padding: EdgeInsets.only(top: 16, left: 16, right: 16),
            child: TextFormField(
              controller: _dificuldadesOutrasController,
              decoration: InputDecoration(
                labelText: 'Especifique',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
              validator: (value) {
                if (isOutroSelected && (value == null || value.isEmpty)) {
                  return 'A especificação das dificuldades é obrigatória.';
                }
                return null;
              },
            ),
          ),
        Divider(),
      ],
    );
  }
}
