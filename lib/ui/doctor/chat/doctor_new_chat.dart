import 'dart:convert';
import 'package:Ombro_Plus/viewmodels/doctor/new_chat_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PatientSelectionForChatPage extends StatelessWidget {
  const PatientSelectionForChatPage({super.key});

  Widget _buildChatAvatar(
    NewChatViewModel vm,
    String patientName,
    String? imageBase64,
  ) {
    if (imageBase64 != null && imageBase64.isNotEmpty) {
      try {
        final bytes = base64Decode(imageBase64);
        return ClipOval(
          child: Image.memory(bytes, width: 40, height: 40, fit: BoxFit.cover),
        );
      } catch (e) {}
    }
    return Text(
      vm.getInitialLetter(patientName),
      style: GoogleFonts.montserrat(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentSpecialistId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4F7F6),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          'Novo Chat',
          style: GoogleFonts.montserrat(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
      ),
      body: currentSpecialistId == null
          ? const Center(child: Text("Usuário não autenticado."))
          : Consumer<NewChatViewModel>(
              builder: (context, viewModel, child) {
                if (viewModel.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF0E382C)),
                  );
                }

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: TextField(
                        onChanged: viewModel.setSearchText,
                        decoration: InputDecoration(
                          hintText: 'Pesquisar meus pacientes',
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Color(0xFF0E382C),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: viewModel.getPatientsStream(
                          currentSpecialistId,
                        ),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFF0E382C),
                              ),
                            );
                          }
                          if (snapshot.hasError) {
                            return const Center(
                              child: Text('Erro ao carregar pacientes'),
                            );
                          }

                          final allPatients = snapshot.data?.docs ?? [];
                          final filteredPatients = allPatients.where((doc) {
                            final name = (doc['nome'] ?? '')
                                .toString()
                                .toLowerCase();
                            return name.contains(
                              viewModel.searchText.toLowerCase(),
                            );
                          }).toList();

                          if (filteredPatients.isEmpty) {
                            return Center(
                              child: Text(
                                viewModel.searchText.isEmpty
                                    ? 'Você não possui pacientes vinculados.'
                                    : 'Nenhum paciente encontrado',
                                style: GoogleFonts.openSans(
                                  color: Colors.black54,
                                ),
                              ),
                            );
                          }

                          return ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: filteredPatients.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final patient = filteredPatients[index];
                              final patientName =
                                  patient['nome'] ?? 'Paciente Sem Nome';
                              final patientId = patient.id;
                              final profileImageBase64 =
                                  (patient.data()
                                          as Map<
                                            String,
                                            dynamic
                                          >)['profileImage']
                                      as String? ??
                                  '';

                              return Card(
                                color: Colors.white,
                                elevation: 1,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    radius: 20,
                                    backgroundColor: const Color(0xFF0E382C),
                                    child: _buildChatAvatar(
                                      viewModel,
                                      patientName,
                                      profileImageBase64,
                                    ),
                                  ),
                                  title: Text(
                                    patientName,
                                    style: GoogleFonts.montserrat(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  trailing: const Icon(
                                    Icons.chat_bubble_outline,
                                    color: Color(0xFF0E382C),
                                  ),
                                  onTap: () => viewModel.startChat(
                                    context,
                                    patientId,
                                    patientName,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}
