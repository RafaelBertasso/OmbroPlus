import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DoctorListPage extends StatefulWidget {
  const DoctorListPage({super.key});

  @override
  State<DoctorListPage> createState() => _DoctorListPageState();
}

class _DoctorListPageState extends State<DoctorListPage> {
  String _search = '';

  Widget _buildLeadingAvatar(DocumentSnapshot specialist) {
    final name =
        (specialist.data() as Map<String, dynamic>?)?['nome'] as String? ?? '';
    final profileImageUrl =
        (specialist.data() as Map<String, dynamic>?)?['profileImage']
            as String?;

    if (profileImageUrl != null && profileImageUrl.isNotEmpty) {
      try {
        final Uint8List bytes = base64Decode(profileImageUrl);
        return CircleAvatar(
          radius: 25,
          backgroundColor: Color(0xFF0E382C),
          backgroundImage: MemoryImage(bytes),
        );
      } catch (e) {
        print('Erro ao decodificar Base64 para $name: $e');
      }
    }
    final initials = name.length >= 2
        ? name.substring(0, 2).toUpperCase()
        : name;

    return CircleAvatar(
      radius: 25,
      backgroundColor: Color(0xFF0E382C),
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
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar especialista',
                prefixIcon: const Icon(Icons.search, color: Colors.black),
                filled: true,
                fillColor: const Color(0xFFF4F7F6),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 0,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) => setState(() {
                _search = value;
              }),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('especialistas')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF0E382C)),
                  );
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Erro ao carregar especialistas',
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        color: Colors.grey[700],
                      ),
                    ),
                  );
                }
                final docs = snapshot.data?.docs ?? [];
                final filtered = docs.where((doc) {
                  final nome = (doc['nome'] ?? '').toString().toLowerCase();
                  return nome.contains(_search.toLowerCase());
                }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Text(
                      'Nenhum especialista encontrado',
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.only(top: 10),
                  itemBuilder: (context, index) {
                    final specialist = filtered[index];
                    return ListTile(
                      leading: _buildLeadingAvatar(specialist),

                      title: Text(
                        specialist['nome'] ?? '',
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/specialist-details',
                          arguments: {
                            'name': specialist['nome'],
                            'id': specialist.id,
                          },
                        );
                      },
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 2,
                      ),
                    );
                  },
                  separatorBuilder: (_, __) => const SizedBox(height: 4),
                  itemCount: filtered.length,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
