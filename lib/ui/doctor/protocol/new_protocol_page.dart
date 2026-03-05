import 'package:Ombro_Plus/models/protocol_model.dart';
import 'package:Ombro_Plus/repositories/doctor_repository.dart';
import 'package:Ombro_Plus/ui/doctor/protocol/protocol_schedule_editor_page.dart';
import 'package:Ombro_Plus/ui/doctor/protocol/widgets/patient_selection_modal.dart';
import 'package:Ombro_Plus/ui/doctor/protocol/widgets/specialist_selection_modal.dart';
import 'package:Ombro_Plus/ui/doctor/protocol/widgets/specialist_selector.dart';
import 'package:Ombro_Plus/ui/shared/widgets/section_title.dart';
import 'package:Ombro_Plus/ui/doctor/protocol/widgets/patient_selector.dart';
import 'package:Ombro_Plus/ui/doctor/protocol/widgets/schedule_button.dart';
import 'package:Ombro_Plus/viewmodels/doctor/new_protocol_viewmodel.dart';
import 'package:Ombro_Plus/viewmodels/doctor/protocol_schedule_viewmodel.dart';
import 'package:Ombro_Plus/viewmodels/doctor/specialist_selection_viewmodel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class NewProtocolPage extends StatefulWidget {
  const NewProtocolPage({super.key});

  @override
  State<NewProtocolPage> createState() => _NewProtocolPageState();
}

class _NewProtocolPageState extends State<NewProtocolPage> {
  String? _selectedPatientId;
  String? _selectedPatientName;
  List<String> _selectedColaboradoresIds = [];
  List<String> _selectedColaboradoresNames = [];

  final _protocolNameController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  final _notesController = TextEditingController();
  final _materialUrlController = TextEditingController();

  @override
  void dispose() {
    _protocolNameController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _notesController.dispose();
    _materialUrlController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(TextEditingController controller) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0E382C),
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        controller.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  void _openPatientModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return PatientSelectionModal(
            scrollController: scrollController,
            onPatientSelected: (id, name) {
              setState(() {
                _selectedPatientId = id;
                _selectedPatientName = name;
              });
              Navigator.pop(context);
            },
          );
        },
      ),
    );
  }

  void _openSpecialistModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return ChangeNotifierProvider(
            create: (_) =>
                SpecialistSelectionViewmodel(repository: DoctorListRepository())
                  ..init(_selectedColaboradoresIds),
            child: SpecialistSelectionModal(
              scrollController: scrollController,
              onSelectionCompleted: (ids, names) {
                setState(() {
                  _selectedColaboradoresIds = ids;
                  _selectedColaboradoresNames = names;
                });
                Navigator.pop(context);
              },
            ),
          );
        },
      ),
    );
  }

  DateTime? _parseDate(String date) {
    try {
      return DateFormat('dd/MM/yyyy').parse(date);
    } catch (_) {
      return null;
    }
  }

  Future<void> _openScheduleEditor() async {
    if (_selectedPatientId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione um paciente primeiro.')),
      );
      return;
    }
    if (_startDateController.text.isEmpty || _endDateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Defina as datas antes de criar o cronograma'),
        ),
      );
      return;
    }

    // --- CÁLCULO DO LIMITE DE SEMANAS ---
    final start = _parseDate(_startDateController.text);
    final end = _parseDate(_endDateController.text);

    if (start == null || end == null || end.isBefore(start)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Por favor, certifique-se que a data final é após a inicial.',
          ),
        ),
      );
      return;
    }

    // Calcula a diferença em dias (+1 para ser inclusivo)
    final int diffDays = end.difference(start).inDays + 1;

    // Divide por 7 e arredonda para cima para descobrir o máximo de semanas!
    int maxWeeks = (diffDays / 7).ceil();
    if (maxWeeks < 1) maxWeeks = 1; // Segurança mínima
    // ------------------------------------

    final newProtocolViewModel = context.read<NewProtocolViewModel>();

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          // Aqui nós passamos o NOVO limite de semanas como segundo parâmetro!
          create: (_) =>
              ProtocolScheduleViewModel()
                ..init(newProtocolViewModel.sessions, maxWeeks),
          child: const ProtocolScheduleEditorPage(),
        ),
      ),
    );

    if (result != null && result is List<ProtocolSession>) {
      newProtocolViewModel.updateSessions(result);
    }
  }

  Future<void> _handleSave() async {
    final viewModel = context.read<NewProtocolViewModel>();
    final specialistId = FirebaseAuth.instance.currentUser?.uid;

    if (specialistId == null) return;

    final success = await viewModel.saveProtocol(
      nome: _protocolNameController.text.trim(),
      pacienteId: _selectedPatientId ?? '',
      pacienteName: _selectedPatientName ?? '',
      especialistaId: specialistId,
      allowedSpecialists: _selectedColaboradoresIds,
      dataInicio: _parseDate(_startDateController.text),
      dataFim: _parseDate(_endDateController.text),
      materialUrl: _materialUrlController.text.trim(),
      notas: _notesController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Protocolo criado com sucesso.')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(viewModel.error ?? 'Erro desconhecido ao salvar.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<NewProtocolViewModel>();

    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0E382C),
        title: Text(
          'Criar Novo Protocolo',
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionTitle(title: 'Configurações Básicas'),

                TextFormField(
                  controller: _protocolNameController,
                  decoration: InputDecoration(
                    labelText: 'Nome do Protocolo',
                    hintText: 'Ex: Fase 1 - Fortalecimento',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF4F7F6),
                  ),
                ),
                SizedBox(height: 12),

                PatientSelector(
                  selectedName: _selectedPatientName,
                  onTap: _openPatientModal,
                ),
                SizedBox(height: 12),

                SpecialistSelector(
                  selectedNames: _selectedColaboradoresNames,
                  onTap: _openSpecialistModal,
                ),
                SizedBox(height: 30),

                SectionTitle(title: 'Datas e Anotações'),
                SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _startDateController,
                        readOnly: true,
                        onTap: () => _selectDate(_startDateController),
                        decoration: InputDecoration(
                          labelText: 'Início',
                          prefixIcon: Icon(Icons.calendar_today, size: 20),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _endDateController,
                        readOnly: true,
                        onTap: () => _selectDate(_endDateController),
                        decoration: InputDecoration(
                          labelText: 'Fim',
                          prefixIcon: Icon(Icons.event_available, size: 20),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 30),

                SectionTitle(title: 'Cronograma e Conteúdo'),
                SizedBox(height: 12),

                ScheduleButton(
                  onPressed: _openScheduleEditor,
                  hasItems: viewModel.sessions.isNotEmpty,
                ),
                SizedBox(height: 16),

                TextFormField(
                  controller: _materialUrlController,
                  decoration: InputDecoration(
                    labelText: 'Link do Material (PDF/Drive)',
                    hintText: 'Cole aqui o link do material (opcional)',
                    prefixIcon: const Icon(Icons.link, size: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                const SizedBox(height: 26),

                TextFormField(
                  controller: _notesController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: 'Anotações',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                  ),
                ),
                SizedBox(height: 30),

                Container(
                  margin: EdgeInsets.only(bottom: bottomPadding + 15),
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: viewModel.isLoading ? null : _handleSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0E382C),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadiusGeometry.circular(9),
                      ),
                    ),
                    child: Text(
                      viewModel.isLoading ? 'Salvando...' : 'Salvar Protocolo',
                      style: GoogleFonts.openSans(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
          if (viewModel.isLoading)
            Container(
              color: Colors.black45,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}
