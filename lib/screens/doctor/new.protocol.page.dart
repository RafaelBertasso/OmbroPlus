import 'package:Ombro_Plus/components/patient.selection.modal.dart';
import 'package:Ombro_Plus/components/section.title.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

//TODO: Implementar logica para um unico protocolo ativo para um paciente

class NewProtocolPage extends StatefulWidget {
  const NewProtocolPage({super.key});

  @override
  State<NewProtocolPage> createState() => _NewProtocolPageState();
}

class _NewProtocolPageState extends State<NewProtocolPage> {
  String? _selectedPatientId;
  String? _selectedPatientName;

  final _protocolNameController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  final _notesController = TextEditingController();
  bool _isSaving = false;
  Map<String, List<Map<String, dynamic>>> _protocolSchedule = {};

  @override
  void dispose() {
    _protocolNameController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _notesController.dispose();
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
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF0E382C),
              ),
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

  void _selectPatient() {
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

  Future<bool> _hasActiveProtocol(String patientId) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('protocolos')
          .where('pacienteId', isEqualTo: patientId)
          .where('status', isEqualTo: 'active')
          .limit(1)
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      print('NewProtocol: Erro ao verificar protocolo ativo $e');
      return true;
    }
  }

  Future<void> _saveProtocol() async {
    if (_selectedPatientId == null || _protocolNameController.text.isEmpty) {
      return;
    }
    if (_protocolSchedule.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Por favor, adicione exercícios ao cronograma'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }
    setState(() {
      _isSaving = true;
    });

    final patientId = _selectedPatientId!;
    final hasActive = await _hasActiveProtocol(patientId);
    if (hasActive) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'O paciente já possui um protocolo ativo. Por favor, finalize o protocolo anterior antes de criar um novo.',
          ),
          backgroundColor: Colors.orange.shade800,
        ),
      );
      setState(() {
        _isSaving = false;
      });
      return;
    }

    final specialistId = FirebaseAuth.instance.currentUser?.uid;
    final protocolName = _protocolNameController.text.trim();
    final patientName = _selectedPatientName;

    final totalEstimatedSessions = _protocolSchedule.keys.length;
    final newProtocolData = {
      'nome': _protocolNameController.text.trim(),
      'pacienteId': _selectedPatientId,
      'especialistaId': specialistId,
      'dataInicio': _parseDateString(_startDateController.text),
      'dataFim': _parseDateString(_endDateController.text),
      'notas': _notesController.text.trim(),
      'schedule': _protocolSchedule,
      'status': 'active',
      'totalSessoesEstimadas': totalEstimatedSessions,
      'sessoesConcluidas': 0,
      'criadoEm': FieldValue.serverTimestamp(),
    };
    try {
      final newDocRef = await FirebaseFirestore.instance
          .collection('protocolos')
          .add(newProtocolData);
      final newProtocolId = newDocRef.id;

      await FirebaseFirestore.instance
          .collection('pacientes')
          .doc(_selectedPatientId)
          .update({'protocoloAtivoId': newProtocolId});
      await FirebaseFirestore.instance.collection('activity_feed').add({
        'type': 'PROTOCOL_CREATED',
        'patientName': patientName,
        'message':
            'Protocolo $protocolName criado para o paciente $patientName',
        'timestamp': FieldValue.serverTimestamp(),
        'patientId': _selectedPatientId,
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Protocolo criado e agendado com sucesso!')),
      );
      Navigator.pop(context);
    } catch (_) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao salvar protocolo')));
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  DateTime? _parseDateString(String dateString) {
    try {
      final parts = dateString.split('/');
      if (parts.length == 3) {
        return DateTime(
          int.parse(parts[2]),
          int.parse(parts[1]),
          int.parse(parts[0]),
        );
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0E382C),
        title: Text(
          'Criar Novo Protocolo',
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white, size: 26),
        elevation: 0.4,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
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
                  fillColor: Color(0xFFF4F7F6),
                ),
              ),
              SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _selectPatient,
                icon: Icon(Icons.person_search, color: Color(0xFF0E382C)),
                label: Text(
                  _selectedPatientName != null
                      ? 'Paciente: $_selectedPatientName'
                      : 'Selecionar Paciente',
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.w600,
                    color: _selectedPatientName != null
                        ? Colors.black
                        : Colors.black54,
                    fontSize: 16,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                  padding: EdgeInsets.symmetric(vertical: 14),
                  side: BorderSide(
                    color: _selectedPatientName == null
                        ? Colors.redAccent
                        : Color(0xFF0E382C),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 30),

              SectionTitle(title: 'Cronograma de Exercícios'),
              SizedBox(height: 12),
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final startDateString = _startDateController.text;
                        final endDateString = _endDateController.text;

                        if (_selectedPatientId == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Por favor, selecione um paciente antes de adicionar exercícios.',
                              ),
                              backgroundColor: Colors.redAccent,
                            ),
                          );
                          return;
                        }

                        if (startDateString.isEmpty || endDateString.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Por favor, selecione as datas de início e término antes de adicionar exercícios.',
                              ),
                              backgroundColor: Colors.redAccent,
                            ),
                          );
                          return;
                        }
                        final startDate = _parseDateString(startDateString);
                        final endDate = _parseDateString(endDateString);

                        if (startDate == null ||
                            endDate == null ||
                            endDate.isBefore(startDate)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Por favor, verifique as datas. A data de término deve ser após a data de início.',
                              ),
                              backgroundColor: Colors.redAccent,
                            ),
                          );
                          return;
                        }

                        final result = await Navigator.pushNamed(
                          context,
                          '/protocol-schedule-editor',
                          arguments: {
                            'patientId': _selectedPatientId,
                            'startDate': startDate.toIso8601String(),
                            'endDate': endDate.toIso8601String(),
                            'currentSchedule': _protocolSchedule,
                          },
                        );
                        if (result != null &&
                            result is Map<String, List<Map<String, dynamic>>>) {
                          setState(() {
                            _protocolSchedule = result;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Cronograma atualizado! Salve o protocolo para finalizar',
                              ),
                            ),
                          );
                        }
                      },
                      icon: Icon(Icons.calendar_month, color: Colors.black),
                      label: Text(
                        'Criar Cronograma',
                        style: GoogleFonts.openSans(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFE0E0E0),
                        minimumSize: Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 30),

                  // Agendar
                  SectionTitle(title: 'Agendamento e Notas'),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _startDateController,
                          readOnly: true,
                          onTap: () => _selectDate(_startDateController),
                          decoration: InputDecoration(
                            labelText: 'Início',
                            hintText: 'Data de Início',
                            prefixIcon: Icon(Icons.calendar_today, size: 20),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            filled: true,
                            fillColor: Color(0xFFF4F7F6),
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
                            hintText: 'Data de Término',
                            prefixIcon: Icon(Icons.event_available, size: 20),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            filled: true,
                            fillColor: Color(0xFFF4F7F6),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 26),

                  TextFormField(
                    controller: _notesController,
                    maxLines: 6,
                    decoration: InputDecoration(
                      labelText: 'Anotações/Instruções para o Paciente',
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(13),
                      ),
                      filled: true,
                      fillColor: Color(0xFFF4F7F6),
                    ),
                  ),
                  SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveProtocol,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF0E382C),
                        minimumSize: Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(9),
                        ),
                      ),
                      child: Text(
                        'Salvar Protocolo',
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
            ],
          ),
        ),
      ),
    );
  }
}
