import 'dart:convert';

import 'package:Ombro_Plus/viewmodels/doctor/doctor_patients.viewmodel.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF4F7F6),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: (value) =>
                  context.read<DoctorPatientsViewModel>().searchPatients(value),
              decoration: InputDecoration(
                hintText: 'Buscar paciente...',
                prefixIcon: Icon(Icons.search, color: Colors.black),
                filled: true,
                fillColor: Color(0xFFF4F7F6),
                contentPadding: EdgeInsets.symmetric(
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
                    final String name = patient.nome;
                    final String email = patient.email;
                    final String? photoUrl = patient.profileImage;

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
                        title: Text(
                          patient.nome,
                          style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          email,
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
