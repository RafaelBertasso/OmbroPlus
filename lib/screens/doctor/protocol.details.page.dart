import 'package:Ombro_Plus/components/info.card.dart';
import 'package:Ombro_Plus/components/protocol.dates.section.dart';
import 'package:Ombro_Plus/components/protocol.header.dart';
import 'package:Ombro_Plus/components/protocol.notes.section.dart';
import 'package:Ombro_Plus/components/protocol.patient.info.dart';
import 'package:Ombro_Plus/components/section.title.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProtocolDetailsPage extends StatelessWidget {
  final String protocolId;
  const ProtocolDetailsPage({super.key, required this.protocolId});

  Future<void> _showEditProtocolModal(
    BuildContext context,
    Map<String, dynamic> initialData,
    String protocolId,
  ) async {
    final _nameController = TextEditingController(text: initialData['nome']);
    final _notesController = TextEditingController(text: initialData['notas']);

    bool _isSaving = false;
    await showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (stfContext, stfSetState) {
            void _saveChanges() async {
              if (_nameController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('O nome do protocolo é obrigatório.')),
                );
                return;
              }
              stfSetState() => _isSaving = true;
              final updatedData = {
                'nome': _nameController.text.trim(),
                'notas': _notesController.text.trim(),
              };

              try {
                await FirebaseFirestore.instance
                    .collection('protocolos')
                    .doc(protocolId)
                    .update(updatedData);

                Navigator.pop(stfContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Protocolo atualizado com sucesso!')),
                );
              } catch (_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Erro ao salvar alterações')),
                );
              } finally {
                stfSetState() => _isSaving = false;
              }
            }

            return AlertDialog(
              backgroundColor: Color(0xFFF4F7F6),
              title: Text(
                'Editar Protocolo',
                style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Nome do Protocolo',
                      ),
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _notesController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: 'Anotações/Instruções',
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: _isSaving ? null : () => Navigator.pop(stfContext),
                  child: Text(
                    'Cancelar',
                    style: GoogleFonts.montserrat(
                      color: Color(0xFF0E382C),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: _isSaving ? null : _saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF0E382C),
                  ),
                  child: _isSaving
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'Salvar',
                          style: GoogleFonts.montserrat(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showStatusManagerModal(
    BuildContext context,
    String currentStatus,
    String protocolId,
  ) async {
    await showModalBottomSheet(
      context: context,
      builder: (BuildContext modalContext) {
        return Container(
          color: Color(0xFFF4F7F6),
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Gerenciar Status do Protocolo',
                style: GoogleFonts.montserrat(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0E382C),
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Status Atual: $currentStatus',
                style: GoogleFonts.openSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 24),
              ListTile(
                leading: Icon(Icons.check_circle_outline, color: Colors.green),
                title: Text(
                  'Finalizar Protocolo',
                  style: GoogleFonts.montserrat(fontWeight: FontWeight.w500),
                ),
                subtitle: Text(
                  'Mudar status para "Finalizado" (Recomendado ao término).',
                ),
                onTap: () {
                  Navigator.pop(modalContext);
                  _updateProtocolStatus(context, protocolId, 'finalized');
                },
              ),
              Divider(height: 1),
            ],
          ),
        );
      },
    );
  }

  Future<void> _updateProtocolStatus(
    BuildContext context,
    String protocolId,
    String newStatus,
  ) async {
    try {
      await FirebaseFirestore.instance
          .collection('protocolos')
          .doc(protocolId)
          .update({'status': newStatus});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Color(0xFF0E382C),
          content: Text(
            'Status do protocolo alterado para ${newStatus == 'finalized' ? 'Finalizado' : 'Ativo'} com sucesso!',
          ),
        ),
      );
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao atualizar status do protocolo.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('protocolos')
          .doc(protocolId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF0E382C)),
          );
        }

        if (snapshot.hasError) {
          return Center(child: Text('Erro ao carregar dados.'));
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Center(child: Text('Protocolo não encontrado.'));
        }
        final data = snapshot.data!.data() as Map<String, dynamic>;

        final String protocolName = data['nome'] ?? 'Sem nome';
        final String patientId = data['pacienteId'];
        final String notes = data['notas'] ?? 'Nenhuma anotação fornecida';
        final String status = data['status'] == 'active'
            ? 'Ativo'
            : 'Finalizado';
        final DateTime startDate =
            (data['dataInicio'] as Timestamp?)?.toDate() ?? DateTime.now();
        final DateTime? endDate = (data['dataFim'] as Timestamp?)?.toDate();
        final schedule = data['schedule'] as Map<String, dynamic>? ?? {};
        final initialDataForEdit = {'nome': protocolName, 'notas': notes};

        return Scaffold(
          backgroundColor: Color(0xFFF4F7F6),
          appBar: AppBar(
            backgroundColor: Color(0xFF0E382C),
            title: Text(
              'Detalhes do Protocolo',
              style: GoogleFonts.montserrat(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            iconTheme: IconThemeData(color: Colors.white, size: 24),
            elevation: 0.4,
            centerTitle: true,
            actions: [
              IconButton(
                onPressed: () {
                  _showEditProtocolModal(
                    context,
                    initialDataForEdit,
                    protocolId,
                  );
                },
                tooltip: 'Editar Protocolo',
                icon: Icon(Icons.edit_note_outlined, color: Colors.white),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProtocolHeader(name: protocolName, status: status),
                SizedBox(height: 16),
                ProtocolPatientIfo(patientId: patientId),
                SizedBox(height: 24),
                ProtocolDatesSection(endDate: endDate, startDate: startDate),
                SizedBox(height: 24),
                ProtocolNotesSection(notes: notes),
                SizedBox(height: 24),
                _buildScheduleSummary(
                  context,
                  schedule,
                  patientId,
                  startDate,
                  endDate,
                ),
                SizedBox(height: 100),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              _showStatusManagerModal(context, status, protocolId);
            },
            backgroundColor: Color(0xFF0E382C),
            label: Text(
              'Gerenciar Status',
              style: GoogleFonts.montserrat(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            icon: Icon(Icons.settings, color: Colors.white),
          ),
        );
      },
    );
  }

  Widget _buildScheduleSummary(
    BuildContext context,
    Map<String, dynamic> schedule,
    String patientId,
    DateTime startDate,
    DateTime? endDate,
  ) {
    final int scheduleDays = schedule.keys.length;
    final bool hasSchedule = scheduleDays > 0;
    Map<String, List<Map<String, dynamic>>> currentSchedule = {};
    schedule.forEach((key, value) {
      if (value is List) {
        currentSchedule[key] = value
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }
    });
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(title: 'Cronograma de Exercícios'),
        SizedBox(height: 8),
        InfoCard(
          title: 'Dias Agendados',
          content: hasSchedule
              ? '$scheduleDays dias com exercícios'
              : 'Cronograma vazio',
          icon: Icons.calendar_month_outlined,
        ),
        SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/protocol-schedule-editor',
                arguments: {
                  'protocolId': protocolId,
                  'patientId': patientId,
                  'startDate': startDate.toIso8601String(),
                  'endDate': endDate?.toIso8601String(),
                  'currentSchedule': currentSchedule,
                },
              );
            },
            icon: Icon(Icons.edit_calendar_outlined, color: Colors.white),
            label: Text(
              'Editar Cronograma',
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF0E382C),
              minimumSize: Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadiusGeometry.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
