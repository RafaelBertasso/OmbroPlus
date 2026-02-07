import 'dart:convert';
import 'dart:typed_data';

import 'package:Ombro_Plus/viewmodels/doctor/doctor_list_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class DoctorListPage extends StatefulWidget {
  const DoctorListPage({super.key});

  @override
  State<DoctorListPage> createState() => _DoctorListPageState();
}

class _DoctorListPageState extends State<DoctorListPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DoctorListViewModel>().fetchSpecialists();
    });
  }

  Widget _buildAvatar(String name, String? imageBase64) {
    if (imageBase64 != null && imageBase64.isNotEmpty) {
      try {
        final Uint8List bytes = base64Decode(imageBase64);
        return CircleAvatar(
          radius: 25,
          backgroundColor: const Color(0xFF0E382C),
          backgroundImage: MemoryImage(bytes),
        );
      } catch (e) {
        // Fallback se falhar decode
      }
    }

    final initials = name.length >= 2
        ? name.substring(0, 2).toUpperCase()
        : name.toUpperCase();

    return CircleAvatar(
      radius: 25,
      backgroundColor: const Color(0xFF0E382C),
      child: Text(
        initials,
        style: GoogleFonts.montserrat(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 18,
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
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar especialista',
                prefixIcon: const Icon(Icons.search, color: Colors.black),
                filled: true,
                fillColor: const Color(0xFFF4F7F6),
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) =>
                  context.read<DoctorListViewModel>().search(value),
            ),
          ),

          Expanded(
            child: Consumer<DoctorListViewModel>(
              builder: (context, viewModel, child) {
                if (viewModel.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator.adaptive(),
                  );
                }
                if (viewModel.error != null) {
                  return Center(child: Text('Erro: ${viewModel.error}'));
                }

                if (viewModel.specialists.isEmpty) {
                  return Center(
                    child: Text(
                      _searchController.text.isEmpty
                          ? 'Nenhum especialista encontrado.'
                          : 'Nenhum resultado para busca.',
                      style: GoogleFonts.montserrat(color: Colors.grey),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.only(top: 10),
                  separatorBuilder: (_, __) => const SizedBox(height: 4),
                  itemCount: viewModel.specialists.length,
                  itemBuilder: (context, index) {
                    final specialist = viewModel.specialists[index];

                    return ListTile(
                      leading: _buildAvatar(
                        specialist.nome,
                        specialist.profileImage,
                      ),

                      title: Text(
                        specialist.nome,
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        specialist.isAdmin ? 'Administrador' : 'Especialista',
                      ),
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/doctor-edit-profile',
                          arguments: {
                            'name': specialist.nome,
                            'id': specialist.id,
                          },
                        );
                      },
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 4,
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
