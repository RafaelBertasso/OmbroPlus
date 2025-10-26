import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class PatientDetailPage extends StatefulWidget {
  const PatientDetailPage({super.key});

  @override
  State<PatientDetailPage> createState() => _PatientDetailPageState();
}

class _PatientDetailPageState extends State<PatientDetailPage> {
  String _patientName = 'Paciente';
  String _patientId = 'ID_NAO_ENCONTRADO';
  Map<String, dynamic>? _patientData;
  bool _isLoading = true;
  String? _profileImageBase64;
  String _mainDiagnosis = 'Carregando...';

  String? _activeProtocolName;
  Timestamp? _protocolStartDate;
  String? _activeProtocolDocId;

  List<DateTime> _completedSessionDays = [];
  bool _isAccessLogsLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPatientData();
    });
  }

  Future<void> _loadPatientData() async {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final id = args?['id'] as String? ?? 'ID_NAO_ENCONTRADO';
    final name = args?['name'] as String? ?? 'Paciente';

    if (id == 'ID_NAO_ENCONTRADO' && mounted) {
      setState(() {
        _patientName = name;
        _patientId = id;
        _isLoading = false;
      });
      return;
    }

    String? activeProtocolName;
    Timestamp? startDate;
    String? protocolDocId;
    Map<String, dynamic>? patientData;
    String? profileImageBase64;
    String mainDiagnosis = 'Ficha não preenchida';

    try {
      final doc = await FirebaseFirestore.instance
          .collection('pacientes')
          .doc(id)
          .get();

      if (doc.exists) {
        patientData = doc.data();
        profileImageBase64 = patientData?['profileImage'];
        mainDiagnosis =
            patientData?['diagnosticoPrincipal'] ?? 'Ficha não preenchida';
      }

      try {
        final protocolSnapshot = await FirebaseFirestore.instance
            .collection('protocolos')
            .where('pacienteId', isEqualTo: id)
            .where('status', isEqualTo: 'active')
            .limit(1)
            .get();

        if (protocolSnapshot.docs.isNotEmpty) {
          final protocolDoc = protocolSnapshot.docs.first;
          final protocolData = protocolDoc.data();

          activeProtocolName = protocolData['nome'] as String?;
          startDate = protocolData['dataInicio'] as Timestamp?;
          protocolDocId = protocolDoc.id;
        }
      } catch (e) {
        print("Erro (SECUNDÁRIO) ao carregar protocolo ativo: $e");
        activeProtocolName = 'Erro de permissão ou consulta';
      }

      if (mounted) {
        setState(() {
          _patientData = patientData;
          _patientName = patientData?['nome'] ?? name;
          _profileImageBase64 = profileImageBase64;
          _patientId = id;
          _mainDiagnosis = mainDiagnosis;

          _activeProtocolName = activeProtocolName;
          _protocolStartDate = startDate;
          _activeProtocolDocId = protocolDocId;
          _isLoading = false;
        });
      }

      if (id != 'ID_NAO_ENCONTRADO') {
        _loadAccessLogs(id);
      }
    } catch (e) {
      print("Erro (PRINCIPAL) ao carregar dados do paciente: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
          _patientName = name;
          _patientId = id;
        });
      }
    }
  }

  Future<void> _loadAccessLogs(String patientId) async {
    if (!mounted) return;

    try {
      final logsSnapshot = await FirebaseFirestore.instance
          .collection('logs_exercicios')
          .where('pacienteId', isEqualTo: patientId)
          .orderBy('timestamp', descending: true)
          .get();

      final Set<DateTime> uniqueDays = {};

      for (var doc in logsSnapshot.docs) {
        final data = doc.data();
        final timestamp = data['timestamp'] as Timestamp?;

        if (timestamp != null) {
          final date = DateTime(
            timestamp.toDate().year,
            timestamp.toDate().month,
            timestamp.toDate().day,
          );
          uniqueDays.add(date);
        }
      }
      if (mounted) {
        setState(() {
          _completedSessionDays = uniqueDays.toList();
          _isAccessLogsLoading = false;
        });
      }
    } catch (e) {
      print('PatientDetails: Erro ao carregar logs de acesso: $e');
      if (mounted) {
        setState(() {
          _isAccessLogsLoading = false;
        });
      }
    }
  }

  String get _getInitials {
    final parts = _patientName.trim().split(' ');
    String initials = '';
    if (parts.isNotEmpty) {
      initials += parts[0][0];
    }
    if (parts.length > 1) {
      initials += parts[1][0];
    }
    return initials.toUpperCase();
  }

  Widget _buildAvatar() {
    if (_profileImageBase64 != null) {
      try {
        final bytes = base64Decode(_profileImageBase64!);
        return ClipOval(
          child: Image.memory(bytes, width: 76, height: 76, fit: BoxFit.cover),
        );
      } catch (_) {}
    }

    return Text(
      _getInitials.isEmpty ? '?' : _getInitials,
      style: GoogleFonts.montserrat(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  Widget _buildAccessLogSection() {
    return Card(
      color: Color(0xFFF4F7F6),
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sessões Concluídas',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            _isAccessLogsLoading
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(12.0),
                      child: CircularProgressIndicator(
                        color: Color(0xFF0E382C),
                      ),
                    ),
                  )
                : _completedSessionDays.isEmpty
                ? const Text(
                    'Nenhuma sessão registrada ainda.',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  )
                : SizedBox(
                    height: 200,
                    child: ListView.builder(
                      itemCount: _completedSessionDays.length,
                      itemBuilder: (context, index) {
                        final date = _completedSessionDays[index];
                        final formatter = DateFormat(
                          'dd \'de\' MMMM \'de\' yyyy',
                          'pt_BR',
                        );

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.check_circle,
                                color: Color(0xFF0E382C),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                formatter.format(date),
                                style: GoogleFonts.openSans(fontSize: 16),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF4F7F6),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF0E382C)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0E382C),
        elevation: 0.4,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white, size: 26),
        title: Text(
          'Acompanhamento',
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 15, bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // AVATAR DO PACIENTE (FOTO OU INICIAIS)
                      CircleAvatar(
                        radius: 38,
                        backgroundColor: const Color(0xFF0E382C),
                        child: _buildAvatar(),
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _patientName,
                              style: GoogleFonts.montserrat(
                                fontSize: 21,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _mainDiagnosis, // Diagnóstico principal dinâmico
                              style: GoogleFonts.openSans(
                                fontSize: 16,
                                color: Colors.black54,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // BOTÃO EDITAR DADOS PESSOAIS
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(
                          163,
                          183,
                          183,
                          183,
                        ),
                        side: const BorderSide(
                          color: Color.fromARGB(255, 255, 255, 255),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      // LÓGICA DE RECARGA: await e _loadPatientData()
                      onPressed: () async {
                        final shouldReload = await Navigator.pushNamed(
                          context,
                          '/patient-edit-profile',
                          arguments: {'name': _patientName, 'id': _patientId},
                        );
                        if (shouldReload == true) {
                          _loadPatientData();
                        }
                      },
                      child: Text(
                        'Editar Dados Pessoais',
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // BOTÃO FICHA CLÍNICA
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0E382C),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      icon: const Icon(
                        Icons.description_outlined,
                        color: Colors.white,
                      ),
                      // LÓGICA DE RECARGA: await e _loadPatientData()
                      onPressed: () async {
                        final shouldReload = await Navigator.pushNamed(
                          context,
                          '/patient-clinical-form',
                          arguments: {'id': _patientId},
                        );
                        if (shouldReload == true) {
                          _loadPatientData();
                        }
                      },
                      label: Text(
                        'Ficha Clínica',
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 28),
          Text(
            'Estágio Atual',
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.bold,
              fontSize: 17,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: Color(0xFFF4F7F6),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            padding: EdgeInsets.symmetric(horizontal: 17, vertical: 16),
            child: _activeProtocolName == null
                ? Text(
                    'Nenhum protocolo ativo encontrado',
                    style: GoogleFonts.openSans(
                      fontSize: 15,
                      color: Colors.black54,
                    ),
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Color(0xFFF4F7F6),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: EdgeInsets.all(8),
                        child: Icon(Icons.list, color: Colors.black, size: 25),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _activeProtocolName!,
                              style: GoogleFonts.montserrat(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Ativo desde: ${_protocolStartDate != null ? DateFormat('dd/MM/yyyy').format(_protocolStartDate!.toDate()) : 'Data Desconhecida'}',
                              style: GoogleFonts.openSans(
                                fontSize: 15,
                                color: Colors.black54,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                if (_activeProtocolDocId != null) {
                                  Navigator.pushNamed(
                                    context,
                                    '/protocol-details',
                                    arguments: {
                                      'protocoloId': _activeProtocolDocId,
                                    },
                                  );
                                }
                              },
                              child: Text(
                                'Ver Cronograma',
                                style: GoogleFonts.openSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0E382C),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
          const SizedBox(height: 24),
          Text(
            'Acessos',
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.bold,
              fontSize: 17,
            ),
          ),
          const SizedBox(height: 9),
          _buildAccessLogSection(),
        ],
      ),
    );
  }
}
