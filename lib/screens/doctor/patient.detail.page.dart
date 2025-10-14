import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPatientData();
    });
  }

  // Função que busca os dados do paciente (nome, foto e diagnóstico)
  Future<void> _loadPatientData() async {
    // 1. Obter argumentos da rota
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

    try {
      final doc = await FirebaseFirestore.instance
          .collection('pacientes')
          .doc(id)
          .get();

      if (doc.exists) {
        final data = doc.data();
        if (mounted) {
          setState(() {
            _patientData = data;
            _patientName = data?['nome'] ?? name;
            _profileImageBase64 = data?['profileImage'];
            _patientId = id;
            _mainDiagnosis =
                data?['diagnosticoPrincipal'] ?? 'Ficha não preenchida';
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _patientName = name;
            _patientId = id;
          });
        }
      }
    } catch (e) {
      print("Erro ao carregar dados do paciente: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
          _patientName = name;
          _patientId = id;
        });
      }
    }
  }

  // Helper para obter as iniciais
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

  // Helper para construir o avatar dinâmico
  Widget _buildAvatar() {
    if (_profileImageBase64 != null) {
      try {
        final bytes = base64Decode(_profileImageBase64!);
        return ClipOval(
          child: Image.memory(bytes, width: 76, height: 76, fit: BoxFit.cover),
        );
      } catch (_) {
        // Fallback: Se o Base64 falhar, usa as iniciais
      }
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

          // --- ESTÁGIO ATUAL ---
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
              color: const Color(0xFFF4F7F6),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 16),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // O CONTEÚDO AQUI DEVE SER LIGADO À COLEÇÃO DE PROTOCOLOS ATIVOS
                // ATÉ LÁ, MANTENHA O CONTEÚDO ESTÁTICO OU BUSQUE O PROTOCOLO ATIVO.
              ],
            ),
          ),

          // --- ACESSOS ---
          const SizedBox(height: 24),
          Text(
            'Acessos',
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.bold,
              fontSize: 17,
            ),
          ),
          const SizedBox(height: 9),
          // Conteúdo Acessos
          Container(
            // ...
          ),
          const SizedBox(height: 10),
          // Botão Ver todos os acessos
          // ...

          // --- EXERCÍCIOS FEITOS ---
          const SizedBox(height: 26),
          Text(
            'Exercícios Feitos',
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.bold,
              fontSize: 17,
            ),
          ),
          const SizedBox(height: 10),

          // Conteúdo Exercícios Feitos
          // ...
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
