import 'package:Ombro_Plus/components/app.logo.dart';
import 'package:Ombro_Plus/components/patient.navbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

const Map<String, String> dayNames = {
  'Mon': 'SEG',
  'Tue': 'TER',
  'Wed': 'QUA',
  'Thu': 'QUI',
  'Fri': 'SEX',
  'Sat': 'SÁB',
  'Sun': 'DOM',
};

class PatientProtocolPage extends StatefulWidget {
  const PatientProtocolPage({super.key});

  @override
  State<PatientProtocolPage> createState() => _PatientProtocolPageState();
}

class _PatientProtocolPageState extends State<PatientProtocolPage> {
  final int _selectedIndex = 2;
  final String? _currentUserId = FirebaseAuth.instance.currentUser?.uid;
  Future<Map<String, dynamic>?>? _protocolFuture;
  Map<int, String> customDayNames = {
    7: 'DOM',
    1: 'SEG',
    2: 'TER',
    3: 'QUA',
    4: 'QUI',
    5: 'SEX',
    6: 'SÁB',
  };
  List<int> displayOrder = [7, 1, 2, 3, 4, 5, 6];

  void _onTabTapped(BuildContext context, int index) {
    if (index == _selectedIndex) return;
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/patient-home');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/patient-dashboard');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/patient-main-chat');
        break;
      case 4:
        Navigator.pushReplacementNamed(context, '/patient-profile');
        break;
      default:
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    _protocolFuture = _fetchProtocolData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _protocolFuture ??= _fetchProtocolData();
  }

  Future<Map<String, dynamic>?> _fetchProtocolData() async {
    final uid = _currentUserId;
    if (uid == null) return null;

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('protocolos')
          .where('pacienteId', isEqualTo: uid)
          .where('status', isEqualTo: 'active')
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        return null;
      }

      final doc = snapshot.docs.first;
      final data = doc.data();

      final totalSessions = data['totalSessoesEstimadas'] as int? ?? 0;
      final sessoesConcluidas = data['sessoesConcluidas'] as int? ?? 0;

      return {
        'protocoloId': doc.id,
        'data': data,
        'totalSessoes': totalSessions,
        'sessoesConcluidas': sessoesConcluidas,
      };
    } catch (e) {
      print('Erro ao carregar protocolo ativo: $e');
      return null;
    }
  }

  Widget _buildScheduleDisplay(Map<String, dynamic>? rawSchedule) {
    if (rawSchedule == null || rawSchedule.isEmpty) {
      return const Text(
        "Agenda não definida.",
        style: TextStyle(color: Colors.grey),
      );
    }

    final scheduleMap = (rawSchedule as Map<dynamic, dynamic>).map(
      (k, v) => MapEntry(k.toString(), v),
    );

    Set<int> daysWithExercises = {};

    scheduleMap.keys.forEach((dateString) {
      try {
        final date = DateTime.parse(dateString);
        daysWithExercises.add(date.weekday);
      } catch (_) {
        try {
          final parts = dateString.split('/');
          if (parts.length == 3) {
            final date = DateTime(
              int.parse(parts[2]),
              int.parse(parts[1]),
              int.parse(parts[0]),
            );
            daysWithExercises.add(date.weekday);
          }
        } catch (_) {}
      }
    });

    final List<Padding> dayWidgets = displayOrder.map((weekday) {
      final dayCode = customDayNames[weekday] ?? '?';
      final isActive = daysWithExercises.contains(weekday);

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF0E382C) : Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              dayNames[dayCode] ?? dayCode.substring(0, 3),
              style: GoogleFonts.montserrat(
                color: isActive ? Colors.white : Colors.black87,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );
    }).toList();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: dayWidgets,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      body: Column(
        children: [
          AppLogo(),
          Expanded(
            child: FutureBuilder<Map<String, dynamic>?>(
              future: _protocolFuture,
              builder: (context, snapshot) {
                // Trata Loading e Erro/Vazio
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF0E382C)),
                  );
                }

                final fullData = snapshot.data;

                if (!snapshot.hasData || fullData == null) {
                  return Center(
                    child: Text(
                      'Nenhum protocolo ativo no momento.',
                      style: GoogleFonts.montserrat(
                        fontSize: 18,
                        color: Colors.black54,
                      ),
                    ),
                  );
                }

                // Extração dos dados
                final protocolId = fullData['protocoloId'] as String;
                final protocolData = fullData['data'] as Map<String, dynamic>;

                final int totalSessions = fullData['totalSessoes'] as int;
                final int sessoesConcluidas =
                    fullData['sessoesConcluidas'] as int;

                final protocolName =
                    protocolData['nome'] as String? ?? 'Protocolo';
                final notes =
                    protocolData['notas'] as String? ??
                    'Nenhuma nota ou descrição breve.';
                final dataInicio = (protocolData['dataInicio'] as Timestamp?)
                    ?.toDate();
                final dataFim = (protocolData['dataFim'] as Timestamp?)
                    ?.toDate();
                final schedule =
                    protocolData['schedule'] as Map<String, dynamic>?;

                final notesDisplay = notes.length > 70
                    ? '${notes.substring(0, 70)}...'
                    : notes;

                final progressValue = totalSessions > 0
                    ? (sessoesConcluidas / totalSessions).clamp(0.0, 1.0)
                    : 0.0;
                final daysTotal = (dataFim != null && dataInicio != null)
                    ? dataFim.difference(dataInicio).inDays + 1
                    : 1;
                final daysElapsed = (dataInicio != null)
                    ? DateTime.now().difference(dataInicio).inDays
                    : 0;

                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 8,
                      top: 10,
                      right: 18,
                      bottom: 10,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Meu Protocolo Atual',
                            style: GoogleFonts.montserrat(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF333333),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),

                        // --- 1. CARD DO PROTOCOLO ATIVO ---
                        Container(
                          padding: const EdgeInsets.all(16),
                          margin: const EdgeInsets.only(bottom: 16, left: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      protocolName,
                                      style: GoogleFonts.montserrat(
                                        color: Colors.black,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      notesDisplay,
                                      style: GoogleFonts.montserrat(
                                        color: Colors.grey[700],
                                        fontSize: 14,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    SizedBox(
                                      width: 120,
                                      height: 32,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Navigator.pushNamed(
                                            context,
                                            '/patient-protocol-details',
                                            arguments: {
                                              'protocoloId': protocolId,
                                            },
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(
                                            0xFF0E382C,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              24,
                                            ),
                                          ),
                                          padding: EdgeInsets.zero,
                                        ),
                                        child: Text(
                                          'Ver Detalhes',
                                          style: GoogleFonts.montserrat(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 8),
                              ClipRRect(
                                borderRadius: BorderRadiusGeometry.circular(12),
                                child: Image.asset(
                                  'assets/images/shoulder.png',
                                  height: 90,
                                  width: 90,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ],
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.only(
                            left: 8.0,
                            top: 16,
                            bottom: 24,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Duração do Tratamento',
                                style: GoogleFonts.montserrat(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Icon(
                                    Icons.calendar_month,
                                    color: Color(0xFF0E382C),
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Início: ${dataInicio != null ? DateFormat('dd/MM/yyyy').format(dataInicio) : 'Não definido'}',
                                    style: GoogleFonts.openSans(fontSize: 14),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.event_available,
                                    color: Color(0xFF0E382C),
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Fim: ${dataFim != null ? DateFormat('dd/MM/yyyy').format(dataFim) : 'Não definido'}',
                                    style: GoogleFonts.openSans(fontSize: 14),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'Agenda Semanal:',
                                style: GoogleFonts.montserrat(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              _buildScheduleDisplay(
                                schedule,
                              ), // Widget da Agenda
                            ],
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Progresso',
                                style: GoogleFonts.montserrat(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 12),
                              Text(
                                'Progressão baseada nas sessões concluídas do protocolo.',
                                style: GoogleFonts.montserrat(
                                  fontSize: 14,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: LinearProgressIndicator(
                                  value: progressValue.toDouble(),
                                  minHeight: 8,
                                  backgroundColor: Colors.grey[300],
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                        Color(0xFF0E382C),
                                      ),
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                '${(progressValue * 100).round()}% ($sessoesConcluidas de $totalSessions sessões concluídas).',
                                style: GoogleFonts.montserrat(
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: PatientNavbar(
        currentIndex: _selectedIndex,
        onTap: (index) => _onTabTapped(context, index),
      ),
    );
  }
}
