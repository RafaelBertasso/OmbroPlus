import 'dart:convert';

import 'package:Ombro_Plus/components/app.logo.dart';
import 'package:Ombro_Plus/components/patient.navbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class SpecialistDetails {
  final String name;
  final String? profileImageBase64;
  SpecialistDetails(this.name, this.profileImageBase64);
}

class PatientMainChatPage extends StatefulWidget {
  const PatientMainChatPage({super.key});

  @override
  State<PatientMainChatPage> createState() => _PatientMainChatPageState();
}

class _PatientMainChatPageState extends State<PatientMainChatPage> {
  final int _selectedIndex = 3;
  String? _currentPatientId;
  String searchText = '';

  @override
  void initState() {
    super.initState();
    _currentPatientId = FirebaseAuth.instance.currentUser?.uid;
  }

  void _onTabTapped(int index) {
    if (index == _selectedIndex) return;
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/patient-home');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/patient-dashboard');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/patient-protocols');
        break;
      case 4:
        Navigator.pushReplacementNamed(context, '/patient-profile');
        break;
      default:
        break;
    }
  }

  Future<String?> _fetchPatientProfileImage(String specialistId) async {
    if (specialistId.isEmpty) return null;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('especialistas')
          .doc(specialistId)
          .get();

      return doc.data()?['profileImage'] as String?;
    } catch (e) {
      print('Erro ao buscar foto do paciente $specialistId: $e');
      return null;
    }
  }

  Future<SpecialistDetails> _fetchSpecialistDetails(String specialistId) async {
    if (specialistId.isEmpty) {
      return SpecialistDetails('Especialista Desconhecido', null);
    }
    try {
      final doc = await FirebaseFirestore.instance
          .collection('especialistas')
          .doc(specialistId)
          .get();
      final name = doc.data()?['nome'] ?? 'Especialista';
      final image = doc.data()?['profileImage'] as String;

      return SpecialistDetails(name, image);
    } catch (e) {
      print('Erro ao buscar especialista $specialistId: $e');
      return SpecialistDetails('Especialista (Erro)', null);
    }
  }

  String _getInitialLetter(String? name) {
    if (name == null || name.isEmpty) {
      return '?';
    }
    return name.trim().split(' ').first[0].toUpperCase();
  }

  Widget _buildChatAvatar(String specialistName, String? imageBase64) {
    if (imageBase64 != null && imageBase64.isNotEmpty) {
      try {
        final bytes = base64Decode(imageBase64);
        return ClipOval(
          child: Image.memory(bytes, width: 40, height: 40, fit: BoxFit.cover),
        );
      } catch (e) {}
    }

    final initialLetter = _getInitialLetter(specialistName);
    return Text(
      initialLetter,
      style: GoogleFonts.montserrat(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentPatientId = _currentPatientId;
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      body: Column(
        children: [
          AppLogo(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Chats',
                    style: GoogleFonts.montserrat(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Pesquisar conversas',
                      prefixIcon: Icon(Icons.search, color: Color(0xFF0E382C)),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 0,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (text) {
                      setState(() {
                        searchText = text;
                      });
                    },
                  ),
                  SizedBox(height: 18),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: currentPatientId == null
                          ? null
                          : FirebaseFirestore.instance
                                .collection('chats')
                                .where(
                                  'participants',
                                  arrayContains: currentPatientId,
                                )
                                .orderBy(
                                  'lastMessageTimestamp',
                                  descending: true,
                                )
                                .snapshots(),
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
                          print(
                            'Erro ao carregar conversas: ${snapshot.error}',
                          );
                          return const Center(
                            child: Text('Erro ao carregar conversas'),
                          );
                        }
                        final activeChats = snapshot.data?.docs ?? [];
                        final filteredChats = activeChats.where((doc) {
                          final name = (doc['patientName'] ?? '')
                              .toString()
                              .toLowerCase();
                          final query = searchText.toLowerCase();
                          return name.contains(query);
                        }).toList();
                        if (filteredChats.isEmpty) {
                          return Center(
                            child: Text(
                              'Nenhuma conversa encontrada',
                              style: GoogleFonts.openSans(
                                color: Colors.black54,
                              ),
                            ),
                          );
                        }
                        return ListView.separated(
                          itemCount: filteredChats.length,
                          separatorBuilder: (_, __) => SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final chatRoom = filteredChats[index];
                            final chatData =
                                chatRoom.data() as Map<String, dynamic>;

                            final participants =
                                chatData['participants'] as List<dynamic>?;
                            final specialistId =
                                participants?.firstWhere(
                                      (id) => id != currentPatientId,
                                      orElse: () => null,
                                    )
                                    as String?;
                            final lastMessage =
                                chatData['lastMessage'] ?? 'Inicie a conversa';
                            final timestamp =
                                chatData['lastMessageTimestamp'] as Timestamp?;
                            final timeString = timestamp != null
                                ? DateFormat('HH:mm').format(timestamp.toDate())
                                : '';
                            final Future<SpecialistDetails> detailsFuture =
                                specialistId == null || specialistId.isEmpty
                                ? Future.value(
                                    SpecialistDetails(
                                      'Usuário não encontrado',
                                      null,
                                    ),
                                  )
                                : _fetchSpecialistDetails(specialistId);
                            return Card(
                              color: const Color(0xFFF4F7F6),
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: FutureBuilder<SpecialistDetails>(
                                future: detailsFuture,
                                builder: (context, snapshot) {
                                  final specialistDetails = snapshot.data;
                                  final displaySpecialistName =
                                      specialistDetails?.name ??
                                      chatData['specialistName'] ??
                                      chatData['patientName'] ??
                                      'Especialista';
                                  final displayImageBase64 =
                                      specialistDetails?.profileImageBase64;
                                  if (!snapshot.hasData &&
                                      snapshot.connectionState !=
                                          ConnectionState.done) {
                                    return ListTile(
                                      leading: CircleAvatar(
                                        radius: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      ),
                                      title: Text(
                                        'Carregando...',
                                        style: TextStyle(color: Colors.black54),
                                      ),
                                    );
                                  }
                                  return ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: Color(0xFF0E382C),
                                      child: _buildChatAvatar(
                                        displaySpecialistName,
                                        specialistDetails?.profileImageBase64,
                                      ),
                                    ),
                                    title: Text(
                                      displaySpecialistName,
                                      style: GoogleFonts.montserrat(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black,
                                      ),
                                    ),
                                    subtitle: Text(
                                      lastMessage,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.openSans(
                                        color: Colors.black54,
                                        fontSize: 14,
                                      ),
                                    ),
                                    trailing: Text(
                                      timeString,
                                      style: GoogleFonts.openSans(
                                        color: Colors.black54,
                                        fontSize: 12,
                                      ),
                                    ),
                                    onTap: () {
                                      Navigator.pushNamed(
                                        context,
                                        '/patient-chat',
                                        arguments: {
                                          'roomId': chatRoom.id,
                                          'name': displaySpecialistName,
                                          'id': specialistId,
                                        },
                                      );
                                    },
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
            ),
          ),
        ],
      ),
      bottomNavigationBar: PatientNavbar(
        currentIndex: _selectedIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}
