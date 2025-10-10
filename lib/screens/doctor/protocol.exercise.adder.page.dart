import 'package:Ombro_Plus/components/section.title.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class ProtocolExerciseAdderPage extends StatefulWidget {
  final List<String> protocolDays;
  final String patientId;
  const ProtocolExerciseAdderPage({
    super.key,
    required this.protocolDays,
    required this.patientId,
  });

  @override
  State<ProtocolExerciseAdderPage> createState() =>
      _ProtocolExerciseAdderPageState();
}

class _ProtocolExerciseAdderPageState extends State<ProtocolExerciseAdderPage> {
  final _formKey = GlobalKey<FormState>();
  final _seriesController = TextEditingController();
  final _repetitionsController = TextEditingController();

  bool _isSaving = false;
  String? _selectedExerciseId;
  String? _selectedExerciseName;

  final Map<String, bool> _selectedDays = {};

  @override
  void initState() {
    super.initState();
    for (var dayIsoString in widget.protocolDays) {
      _selectedDays[dayIsoString] = false;
    }
  }

  @override
  void dispose() {
    _seriesController.dispose();
    _repetitionsController.dispose();
    super.dispose();
  }

  Future<void> _saveScheduleEntries() async {
    if (!_formKey.currentState!.validate() || _selectedExerciseId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecione o exercício e defina a carga.'),
        ),
      );
      return;
    }
    final daysToSchedule = _selectedDays.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();
    if (daysToSchedule.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecione pelo menos um dia para agendar.'),
        ),
      );
      return;
    }
    setState(() {
      _isSaving = true;
    });

    final Map<String, dynamic> newScheduleEntry = {
      'exercicioId': _selectedExerciseId,
      'exercicioNome': _selectedExerciseName,
      'series': int.parse(_seriesController.text),
      'repeticoes': int.parse(_repetitionsController.text),
      'diasIso': daysToSchedule,
    };
    Navigator.pop(context, newScheduleEntry);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF4F7F6),
      appBar: AppBar(
        backgroundColor: Color(0xFF0E382C),
        title: Text(
          'Agendar Exercício',
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: IconThemeData(color: Colors.white, size: 26),
        elevation: 0.4,
        centerTitle: true,
        automaticallyImplyLeading: true,
      ),
      endDrawer: Drawer(
        child: Column(
          children: [
            Container(
              color: Color(0xFF0E382C),
              padding: EdgeInsets.only(
                top: 40,
                bottom: 16,
                left: 16,
                right: 16,
              ),
              width: double.infinity,
              child: Row(
                children: [
                  Text(
                    'Exercícios Adicionados',
                    style: GoogleFonts.montserrat(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('exercicios')
                    .orderBy('nome')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF0E382C),
                      ),
                    );
                  }
                  if (snapshot.hasError) {
                    return Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('Erro ao carregar exercícios'),
                    );
                  }
                  final documents = snapshot.data?.docs ?? [];

                  if (documents.isEmpty) {
                    return Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Nenhum exercício encontrado.',
                        style: GoogleFonts.montserrat(color: Colors.black54),
                      ),
                    );
                  }
                  return ListView.separated(
                    itemCount: documents.length,
                    separatorBuilder: (_, __) => Divider(height: 1),
                    itemBuilder: (context, index) {
                      final data =
                          documents[index].data() as Map<String, dynamic>;
                      final exerciseName = data['nome'] ?? 'Sem Nome';

                      return ListTile(
                        title: Text(
                          exerciseName,
                          style: GoogleFonts.openSans(fontSize: 15),
                        ),
                        trailing: Icon(Icons.info_outline, color: Colors.grey),
                        onTap: () => Navigator.pop(context),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionTitle(title: '1. Seleção e Carga'),
                    _buildExerciseAutocomplete(),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _seriesController,
                            keyboardType: TextInputType.number,
                            decoration: _inputDecoration('Séries'),
                            validator: (v) => v!.isEmpty ? 'Obrigatório' : null,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _repetitionsController,
                            keyboardType: TextInputType.number,
                            decoration: _inputDecoration('Repetições'),
                            validator: (v) => v!.isEmpty ? 'Obrigatório' : null,
                          ),
                        ),
                      ],
                    ),
                    Divider(height: 1),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 16),
                          SectionTitle(title: '2. Agendar Exercícios'),
                          TextButton(
                            onPressed: _toggleSelectAll,
                            child: Text(
                              'Selecionar Todos / Desmarcar Todos',
                              style: GoogleFonts.montserrat(
                                color: Color(0xFF0E382C),
                              ),
                            ),
                          ),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: widget.protocolDays.length,
                            itemBuilder: (context, index) {
                              final dayIsoString = widget.protocolDays[index];
                              final day = DateTime.parse(dayIsoString);
                              final dateKey = DateFormat(
                                'EEE, dd/MM',
                              ).format(day);
                              return CheckboxListTile(
                                title: Text(dateKey),
                                value: _selectedDays[dayIsoString] ?? false,
                                onChanged: (bool? value) {
                                  setState(() {
                                    _selectedDays[dayIsoString] =
                                        value ?? false;
                                  });
                                },
                                activeColor: Color(0xFF0E382C),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: EdgeInsets.fromLTRB(20, 10, 20, 20),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _saveScheduleEntries,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF0E382C),
                            minimumSize: Size(double.infinity, 48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: _isSaving
                              ? CircularProgressIndicator(color: Colors.white)
                              : Text(
                                  'Adicionar ao Protocolo',
                                  style: GoogleFonts.montserrat(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
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

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      filled: true,
      fillColor: Colors.white,
    );
  }

  void _toggleSelectAll() {
    final allSelected = _selectedDays.values.every((isSelected) => isSelected);
    final newState = !allSelected;
    setState(() {
      _selectedDays.updateAll((key, value) => newState);
    });
  }

  Widget _buildExerciseAutocomplete() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('exercicios').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          debugPrint('Erro ao carregar exercícios: ${snapshot.error}');
          return const Text('Erro ao carregar exercícios.');
        }
        final exerciseOptions = snapshot.data!.docs
            .map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return data['nome'] as String ?? '';
            })
            .where((nome) => nome.isNotEmpty)
            .toList();

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Autocomplete<String>(
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text == '') {
                    return const Iterable<String>.empty();
                  }
                  return exerciseOptions.where((String option) {
                    return option.toLowerCase().contains(
                      textEditingValue.text.toLowerCase(),
                    );
                  });
                },
                onSelected: (String selection) {
                  final selectedDoc = snapshot.data!.docs.firstWhere(
                    (doc) =>
                        (doc.data() as Map<String, dynamic>)['nome'] ==
                        selection,
                  );

                  setState(() {
                    _selectedExerciseName = selection;
                    _selectedExerciseId = selectedDoc.id;
                  });
                },
                fieldViewBuilder:
                    (
                      context,
                      textEditingController,
                      focusNode,
                      onFieldSubmitted,
                    ) {
                      return TextFormField(
                        controller: textEditingController,
                        focusNode: focusNode,
                        decoration: _inputDecoration(
                          'Buscar Exercício na Biblioteca',
                        ),
                        validator: (v) => _selectedExerciseName == null
                            ? 'Selecione um exercício válido.'
                            : null,
                        onChanged: (text) {
                          if (text != _selectedExerciseName) {
                            _selectedExerciseId = null;
                            _selectedExerciseName = null;
                          }
                        },
                      );
                    },
              ),
            ),
            SizedBox(width: 8),
            SizedBox(
              height: 50,
              child: IconButton(
                onPressed: () async {
                  final result = await Navigator.pushNamed(
                    context,
                    '/new-exercise',
                  );
                  if (result == true) {
                    setState(() {});
                  }
                },
                icon: Icon(
                  Icons.add_box_outlined,
                  size: 30,
                  color: Color(0xFF0E382C),
                ),
                tooltip: 'Adicionar Novo Exercício',
              ),
            ),
          ],
        );
      },
    );
  }
}
