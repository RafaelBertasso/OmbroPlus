import 'dart:convert';

import 'package:Ombro_Plus/models/patient_model.dart';
import 'package:Ombro_Plus/viewmodels/doctor/doctor_patients_viewmodel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class PatientListPage extends StatefulWidget {
  const PatientListPage({super.key});

  @override
  State<PatientListPage> createState() => _PatientListPageState();
}

class _PatientListPageState extends State<PatientListPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        context.read<DoctorPatientsViewModel>().fetchPatients(userId);
      }
    });
  }

  String _getInitials(String? name) {
    if (name == null || name.isEmpty) {
      return '?';
    }
    return name.trim().split(' ').first[0].toUpperCase();
  }

  Widget _buildPatientAvatar(String? name, String? imageData) {
    if (imageData != null && imageData.isNotEmpty) {
      if (imageData.startsWith('http')) {
        return CircleAvatar(
          backgroundColor: const Color(0xFF0E382C),
          backgroundImage: NetworkImage(imageData),
        );
      } else {
        try {
          final bytes = base64Decode(imageData);
          return CircleAvatar(
            backgroundColor: const Color(0xFF0E382C),
            backgroundImage: MemoryImage(bytes),
          );
        } catch (_) {}
      }
    }

    return CircleAvatar(
      backgroundColor: const Color(0xFF0E382C),
      child: Text(
        (name != null && name.isNotEmpty) ? name[0].toUpperCase() : '?',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// Retorna o badge colorido de status de evolução.
  Widget _buildEvolutionBadge(EvolutionStatus status) {
    final Color color;
    final String label;
    final IconData icon;

    switch (status) {
      case EvolutionStatus.emDia:
        color = const Color(0xFF2E7D32); // verde escuro
        label = 'Em dia';
        icon = Icons.check_circle_outline;
        break;
      case EvolutionStatus.atrasado:
        color = const Color(0xFFC62828); // vermelho escuro
        label = 'Atrasado';
        icon = Icons.warning_amber_outlined;
        break;
      case EvolutionStatus.semProtocolo:
        color = const Color(0xFF757575); // cinza
        label = 'Sem protocolo';
        icon = Icons.remove_circle_outline;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.openSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: (value) =>
                  context.read<DoctorPatientsViewModel>().searchPatients(value),
              decoration: InputDecoration(
                hintText: 'Buscar paciente...',
                prefixIcon: const Icon(Icons.search, color: Colors.black),
                filled: true,
                fillColor: const Color(0xFFF4F7F6),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: Consumer<DoctorPatientsViewModel>(
              builder: (context, viewModel, child) {
                if (viewModel.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator.adaptive(),
                  );
                }

                if (viewModel.error != null) {
                  return Center(child: Text('Erro: ${viewModel.error}'));
                }

                if (viewModel.patients.isEmpty) {
                  return Center(
                    child: Text(
                      _searchController.text.isEmpty
                          ? 'Nenhum paciente vinculado.'
                          : 'Nenhum paciente encontrado.',
                      style: GoogleFonts.openSans(color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: viewModel.patients.length,
                  itemBuilder: (context, index) {
                    final patient = viewModel.patients[index];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        leading: _buildPatientAvatar(
                          patient.nome,
                          patient.profileImage,
                        ),
                        title: Row(
                          children: [
                            Flexible(
                              child: Text(
                                patient.nome,
                                style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            _buildEvolutionBadge(patient.evolutionStatus),
                          ],
                        ),
                        subtitle: Text(
                          patient.email,
                          style: GoogleFonts.openSans(fontSize: 12),
                        ),
                        trailing: const Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Colors.grey,
                        ),
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/patient-detail',
                            arguments: {'patientId': patient.id},
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
