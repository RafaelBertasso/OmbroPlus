// patient_protocol_details_page.dart

import 'package:Ombro_Plus/components/info.card.dart';
import 'package:Ombro_Plus/components/protocol.dates.section.dart';
import 'package:Ombro_Plus/components/protocol.header.dart';
import 'package:Ombro_Plus/components/protocol.notes.section.dart';
import 'package:Ombro_Plus/components/section.title.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

// Esta página deve ser acessada via rota, passando o protocolId como argumento.
class PatientProtocolDetailsPage extends StatelessWidget {
  const PatientProtocolDetailsPage({super.key});

  // WIDGET HELPER: Exibição da Agenda Diária (Recriado aqui para ser independente)
  Widget _buildDailySchedule(Map<String, dynamic> schedule, String dateKey) {
    final dailyExercises = schedule[dateKey];
    if (dailyExercises == null || dailyExercises.isEmpty) {
      return const Center(child: Text('Nenhum exercício neste dia.'));
    }

    final exercisesList = (dailyExercises as List<dynamic>);

    return Column(
      children: exercisesList
          .map(
            (ex) => ListTile(
              leading: const Icon(
                Icons.fitness_center,
                color: Color(0xFF0E382C),
              ),
              title: Text(
                ex['title'] ?? 'Exercício Sem Nome',
                style: GoogleFonts.openSans(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                '${ex['series']} séries x ${ex['repeticoes']} repetições',
              ),
              // Nenhuma funcionalidade de log/conclusão está aqui, é pura consulta.
            ),
          )
          .toList(),
    );
  }

  // WIDGET HELPER: Seção de Visualização da Agenda (Substitui o _buildScheduleSummary)
  Widget _buildPatientScheduleViewer(
    BuildContext context,
    Map<String, dynamic> schedule,
    String protocolId,
    DateTime startDate,
    DateTime? endDate,
  ) {
    final int scheduleDays = schedule.keys.length;
    final bool hasSchedule = scheduleDays > 0;

    // Obtém e ordena as chaves de data
    final sortedDateKeys = schedule.keys.toList()
      ..sort((a, b) => a.compareTo(b));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(title: 'Cronograma de Exercícios'),
        const SizedBox(height: 8),

        InfoCard(
          title: 'Dias Agendados',
          content: hasSchedule
              ? '$scheduleDays dias com exercícios'
              : 'Cronograma vazio',
          icon: Icons.calendar_month_outlined,
        ),
        const SizedBox(height: 16),

        Text(
          'Agenda de Exercícios',
          style: GoogleFonts.montserrat(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Divider(color: Color(0xFF0E382C)),
        const SizedBox(height: 12),

        // Lista de Expansion Tiles por Data
        Column(
          children: sortedDateKeys.map((dateKey) {
            DateTime? date;
            try {
              date = DateTime.parse(dateKey);
            } catch (_) {}

            final displayDate = date != null
                ? DateFormat('dd/MM/yyyy').format(date)
                : dateKey;

            return Card(
              color: Color(0xFFF4F7F6),
              margin: const EdgeInsets.only(bottom: 8),
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(horizontal: 16),
                title: Text(
                  'Dia: $displayDate',
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0, bottom: 8),
                    child: _buildDailySchedule(schedule, dateKey),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // 1. Extrai o ID dos argumentos da rota
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final String protocolId = args['protocoloId'];

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('protocolos')
          .doc(protocolId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFF0E382C)),
            ),
          );
        }

        if (snapshot.hasError) {
          return const Scaffold(
            body: Center(child: Text('Erro ao carregar dados.')),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Scaffold(
            body: Center(child: Text('Protocolo não encontrado.')),
          );
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;

        final String protocolName = data['nome'] ?? 'Sem nome';
        final String notes = data['notas'] ?? 'Nenhuma anotação fornecida';

        // Status apenas para informação visual, não editável.
        final String status = data['status'] == 'active'
            ? 'Ativo'
            : 'Finalizado';

        final DateTime startDate =
            (data['dataInicio'] as Timestamp?)?.toDate() ?? DateTime.now();
        final DateTime? endDate = (data['dataFim'] as Timestamp?)?.toDate();
        final schedule = data['schedule'] as Map<String, dynamic>? ?? {};

        return Scaffold(
          backgroundColor: const Color(0xFFF4F7F6),
          appBar: AppBar(
            backgroundColor: const Color(0xFF0E382C),
            title: Text(
              'Detalhes do Protocolo',
              style: GoogleFonts.montserrat(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            iconTheme: const IconThemeData(color: Colors.white, size: 24),
            elevation: 0.4,
            centerTitle: true,
            // REMOVIDO: O array de 'actions' que continha o botão de edição.
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. CABEÇALHO (Nome e Status)
                ProtocolHeader(name: protocolName, status: status),
                const SizedBox(height: 16),

                // 2. INFORMAÇÕES DO PACIENTE (Removido, pois o paciente está vendo o próprio protocolo)
                // Se o componente ProtocolPatientIfo existir, não é necessário para o paciente.
                // Mas a remoção não afeta o layout.

                // 3. DATAS DE INÍCIO/FIM
                ProtocolDatesSection(endDate: endDate, startDate: startDate),
                const SizedBox(height: 24),

                // 4. ANOTAÇÕES
                ProtocolNotesSection(notes: notes),
                const SizedBox(height: 24),

                _buildPatientScheduleViewer(
                  context,
                  schedule,
                  protocolId,
                  startDate,
                  endDate,
                ),

                const SizedBox(height: 50),
              ],
            ),
          ),
        );
      },
    );
  }
}
