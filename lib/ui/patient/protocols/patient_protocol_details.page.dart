import 'package:Ombro_Plus/components/info.card.dart';
import 'package:Ombro_Plus/components/protocol.dates.section.dart';
import 'package:Ombro_Plus/components/protocol.header.dart';
import 'package:Ombro_Plus/components/protocol.notes.section.dart';
import 'package:Ombro_Plus/components/section.title.dart';
import 'package:Ombro_Plus/viewmodels/shared/protocol_details.viewmodel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class PatientProtocolDetailsPage extends StatefulWidget {
  final String protocolId;
  const PatientProtocolDetailsPage({super.key, required this.protocolId});

  @override
  State<PatientProtocolDetailsPage> createState() =>
      _PatientProtocolDetailsPageState();
}

class _PatientProtocolDetailsPageState
    extends State<PatientProtocolDetailsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        context.read<ProtocolDetailsViewModel>().loadProtocolData(
          widget.protocolId,
          userId,
        );
      }
    });
  }

  Widget _buildDailySchedule(Map<String, dynamic> schedule, String dateKey) {
    final dailyExercises = schedule[dateKey];
    if (dailyExercises == null ||
        (dailyExercises is List && dailyExercises.isEmpty)) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: const Center(child: Text('Nenhum exercício neste dia.')),
      );
    }

    final exercisesList = (dailyExercises as List<dynamic>);

    return Column(
      children: exercisesList
          .map(
            (ex) => ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 4,
              ),
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF0E382C).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.fitness_center,
                  color: Color(0xFF0E382C),
                  size: 20,
                ),
              ),
              title: Text(
                ex['title'] ?? 'Exercício Sem Nome',
                style: GoogleFonts.openSans(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              subtitle: Text(
                '${ex['series']} séries x ${ex['repeticoes']} repetições',
                style: GoogleFonts.openSans(fontSize: 12),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildPatientScheduleViewer(
    BuildContext context,
    Map<String, dynamic> schedule,
  ) {
    final int scheduleDays = schedule.keys.length;
    final bool hasSchedule = scheduleDays > 0;

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
            color: const Color(0xFF333333),
          ),
        ),
        const Divider(color: Color(0xFF0E382C), thickness: 1),
        const SizedBox(height: 12),

        if (!hasSchedule)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text("Nenhum dia agendado para este protocolo."),
          ),

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
              margin: const EdgeInsets.only(bottom: 10),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadiusGeometry.circular(12),
                ),
                backgroundColor: Colors.white,
                collapsedBackgroundColor: Colors.white,
                iconColor: const Color(0xFF0E382C),
                collapsedIconColor: Colors.grey,
                title: Text(
                  'Dia: $displayDate',
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                children: [
                  Divider(height: 1),
                  _buildDailySchedule(schedule, dateKey),
                  const SizedBox(height: 8),
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
        elevation: 0,
        centerTitle: true,
      ),
      body: Consumer<ProtocolDetailsViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }

          if (viewModel.error != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  viewModel.error!,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(color: Colors.red),
                ),
              ),
            );
          }
          final protocol = viewModel.protocol;

          if (protocol == null) {
            return const Center(child: Text('Protocolo não encontrado.'));
          }

          final String status = protocol.status == 'active'
              ? 'Ativo'
              : 'Finalizado';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProtocolHeader(name: protocol.nome, status: status),
                const SizedBox(height: 16),

                ProtocolDatesSection(
                  endDate: protocol.dataFim,
                  startDate: protocol.dataInicio,
                ),
                const SizedBox(height: 24),

                ProtocolNotesSection(notes: protocol.notas),
                const SizedBox(height: 24),

                _buildPatientScheduleViewer(context, protocol.schedule),
                const SizedBox(height: 50),
              ],
            ),
          );
        },
      ),
    );
  }
}
