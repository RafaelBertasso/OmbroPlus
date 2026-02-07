import 'dart:convert';

import 'package:Ombro_Plus/ui/shared/widgets/app_logo.dart';
import 'package:Ombro_Plus/components/navbar.dart';
import 'package:Ombro_Plus/viewmodels/shared/chat_list_viewmodel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class PatientMainChatPage extends StatefulWidget {
  const PatientMainChatPage({super.key});

  @override
  State<PatientMainChatPage> createState() => _PatientMainChatPageState();
}

class _PatientMainChatPageState extends State<PatientMainChatPage> {
  final int _selectedIndex = 3;

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
    }
  }

  Widget _buildChatAvatar(
    ChatListViewmodel vm,
    String specialistName,
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
      vm.getInitialLetter(specialistName),
      style: GoogleFonts.montserrat(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentPatientId = FirebaseAuth.instance.currentUser?.uid;

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
                          fontSize: 22,
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
                            vertical: 10,
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
                        child: currentPatientId == null
                            ? const Center(
                                child: Text('Usuário não autenticado'),
                              )
                            : StreamBuilder<QuerySnapshot>(
                                stream: viewModel.getPatientChatsStream(
                                  currentPatientId,
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
                                      child: Text('Erro ao carregar conversas'),
                                    );
                                  }

                                  final activeChats = snapshot.data?.docs ?? [];

                                  final filteredChats = activeChats.where((
                                    doc,
                                  ) {
                                    final chatData =
                                        doc.data() as Map<String, dynamic>;
                                    final specialistName =
                                        (chatData['specialistName'] ?? '')
                                            .toString()
                                            .toLowerCase();
                                    final lastMessage =
                                        chatData['lastMessage'] ?? '';

                                    // ✅ Só mostra chats com mensagem E que correspondem à busca
                                    return lastMessage.isNotEmpty &&
                                        specialistName.contains(
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
                                          chatRoom.data()
                                              as Map<String, dynamic>;

                                      // Pega o ID do especialista via participants
                                      final participants =
                                          chatData['participants']
                                              as List<dynamic>?;
                                      final specialistId =
                                          participants
                                              ?.firstWhere(
                                                (id) => id != currentPatientId,
                                                orElse: () => '',
                                              )
                                              .toString() ??
                                          '';

                                      final specialistName =
                                          chatData['specialistName'] ??
                                          'Especialista';

                                      final lastMessage =
                                          chatData['lastMessage'] ??
                                          'Inicie a conversa';

                                      final timestamp =
                                          chatData['lastMessageTimestamp']
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
                                          unreadCounts?[currentPatientId]
                                              as int? ??
                                          0;
                                      final showBadge = unreadCount > 0;

                                      return Card(
                                        color: Colors.white,
                                        elevation: 1,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: ListTile(
                                          leading: FutureBuilder<String?>(
                                            future: viewModel
                                                .getSpecialistProfileImage(
                                                  specialistId,
                                                ),
                                            builder: (context, imageSnapshot) {
                                              return Stack(
                                                children: [
                                                  CircleAvatar(
                                                    backgroundColor:
                                                        const Color(0xFF0E382C),
                                                    child: _buildChatAvatar(
                                                      viewModel,
                                                      specialistName,
                                                      imageSnapshot.data,
                                                    ),
                                                  ),
                                                  if (showBadge)
                                                    Positioned(
                                                      right: 0,
                                                      bottom: 0,
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets.all(
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
                                                            unreadCount
                                                                .toString(),
                                                            style:
                                                                GoogleFonts.openSans(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize: 10,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
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
                                            specialistName,
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
                                            if (specialistId.isEmpty) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'Erro: ID do especialista não encontrado.',
                                                  ),
                                                ),
                                              );
                                              return;
                                            }
                                            Navigator.pushNamed(
                                              context,
                                              '/patient-chat',
                                              arguments: {
                                                'roomId': chatRoom.id,
                                                'name': specialistName,
                                                'id': specialistId,
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
      bottomNavigationBar: Navbar(
        currentIndex: _selectedIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}
