import 'dart:convert';

import 'package:Ombro_Plus/components/app.logo.dart';
import 'package:Ombro_Plus/components/navbar.dart';
import 'package:Ombro_Plus/viewmodels/shared/chat_list_viewmodel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class DoctorMainChatPage extends StatefulWidget {
  const DoctorMainChatPage({super.key});

  @override
  State<DoctorMainChatPage> createState() => _DoctorMainChatPageState();
}

class _DoctorMainChatPageState extends State<DoctorMainChatPage> {
  final int _selectedIndex = 3;

  void _onTabTapped(int index) {
    if (index == _selectedIndex) return;
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/doctor-home');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/doctor-dashboard');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/doctor-protocols');
        break;
      case 4:
        Navigator.pushReplacementNamed(context, '/doctor-profile');
        break;
    }
  }

  Widget _buildChatAvatar(
    ChatListViewmodel vm,
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
      body: Column(
        children: [
          const AppLogo(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Consumer<ChatListViewmodel>(
                builder: (context, viewModel, child) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Chats',
                        style: GoogleFonts.montserrat(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Campo de Busca
                      TextField(
                        onChanged: viewModel.setSearchText,
                        decoration: InputDecoration(
                          hintText: 'Pesquisar conversas',
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
                      const SizedBox(height: 18),

                      // Lista de Chats
                      Expanded(
                        child: StreamBuilder<QuerySnapshot>(
                          stream: viewModel.getChatsStream('specialistId'),
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
                                child: Text('Erro ao carregar conversas'),
                              );
                            }

                            final activeChats = snapshot.data?.docs ?? [];

                            // Dentro do StreamBuilder, após filteredChats
                            final filteredChats = activeChats.where((doc) {
                              final chatData =
                                  doc.data() as Map<String, dynamic>;
                              final name = (chatData['patientName'] ?? '')
                                  .toString()
                                  .toLowerCase();
                              final lastMessage =
                                  chatData['lastMessage'] ?? ''; // ✅ ADICIONAR

                              // ✅ Só mostra chats que já têm mensagem E que correspondem à busca
                              return lastMessage.isNotEmpty &&
                                  name.contains(
                                    viewModel.searchText.toLowerCase(),
                                  );
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
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                final chatRoom = filteredChats[index];
                                final chatData =
                                    chatRoom.data() as Map<String, dynamic>;

                                final patientName =
                                    chatData['patientName'] ?? 'Paciente';

                                // --- CORREÇÃO HÍBRIDA (IMPORTANTE) ---
                                String patientId = '';

                                // 1. Tenta pegar via participants (Jeito Novo)
                                final participants = List<dynamic>.from(
                                  chatData['participants'] ?? [],
                                );
                                if (participants.isNotEmpty) {
                                  try {
                                    patientId = participants
                                        .firstWhere(
                                          (id) => id != currentSpecialistId,
                                          orElse: () => '',
                                        )
                                        .toString();
                                  } catch (_) {}
                                }

                                // 2. Se falhar, usa o "Jeito Antigo" (Manipulação de String do RoomID)
                                // Isso garante compatibilidade total com o código legado.
                                if (patientId.isEmpty &&
                                    currentSpecialistId != null) {
                                  patientId = chatRoom.id
                                      .replaceAll('_', '')
                                      .replaceAll(currentSpecialistId, '');
                                }
                                // ------------------------------------

                                final lastMessage =
                                    chatData['lastMessage'] ??
                                    'Inicie a conversa';
                                final timestamp =
                                    (chatData['lastMessageTimestamp'] ??
                                            chatData['lastMessageTime'])
                                        as Timestamp?;
                                final timeString = timestamp != null
                                    ? DateFormat(
                                        'HH:mm',
                                      ).format(timestamp.toDate())
                                    : '';

                                final unreadCounts =
                                    chatData['unreadCount']
                                        as Map<String, dynamic>?;
                                final unreadCount =
                                    unreadCounts?[currentSpecialistId]
                                        as int? ??
                                    0;
                                final showBadge = unreadCount > 0;

                                return Card(
                                  color: Colors.white,
                                  elevation: 1,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: ListTile(
                                    leading: FutureBuilder<String?>(
                                      future: viewModel.getPatientProfileImage(
                                        patientId,
                                      ),
                                      builder: (context, imageSnapshot) {
                                        return Stack(
                                          children: [
                                            CircleAvatar(
                                              backgroundColor: const Color(
                                                0xFF0E382C,
                                              ),
                                              child: _buildChatAvatar(
                                                viewModel,
                                                patientName,
                                                imageSnapshot.data,
                                              ),
                                            ),
                                            if (showBadge)
                                              Positioned(
                                                right: 0,
                                                bottom: 0,
                                                child: Container(
                                                  padding: const EdgeInsets.all(
                                                    4,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.red,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          10,
                                                        ),
                                                    border: Border.all(
                                                      color: Colors.white,
                                                      width: 1.5,
                                                    ),
                                                  ),
                                                  constraints:
                                                      const BoxConstraints(
                                                        minWidth: 18,
                                                        minHeight: 18,
                                                      ),
                                                  child: Center(
                                                    child: Text(
                                                      unreadCount.toString(),
                                                      style:
                                                          GoogleFonts.openSans(
                                                            color: Colors.white,
                                                            fontSize: 10,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                          ],
                                        );
                                      },
                                    ),
                                    title: Text(
                                      patientName,
                                      style: GoogleFonts.montserrat(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    subtitle: Text(
                                      lastMessage,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.openSans(
                                        color: Colors.black54,
                                        fontSize: 13,
                                      ),
                                    ),
                                    trailing: Text(
                                      timeString,
                                      style: GoogleFonts.openSans(
                                        color: Colors.black54,
                                        fontSize: 11,
                                      ),
                                    ),
                                    onTap: () {
                                      if (patientId.isEmpty) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Erro: ID do paciente não encontrado.',
                                            ),
                                          ),
                                        );
                                        return;
                                      }
                                      Navigator.pushNamed(
                                        context,
                                        '/chat-detail',
                                        arguments: {
                                          'roomId': chatRoom.id,
                                          'name': patientName,
                                          'id': patientId,
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
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/doctor-new-chat'),
        backgroundColor: const Color(0xFF0E382C),
        child: const Icon(Icons.chat, color: Colors.white),
      ),
      bottomNavigationBar: Navbar(
        currentIndex: _selectedIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}
