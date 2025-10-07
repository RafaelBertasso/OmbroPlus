import 'package:Ombro_Plus/components/app.logo.dart';
import 'package:Ombro_Plus/components/doctor.navbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class DoctorMainChatPage extends StatefulWidget {
  const DoctorMainChatPage({super.key});

  @override
  State<DoctorMainChatPage> createState() => _DoctorMainChatPageState();
}

class _DoctorMainChatPageState extends State<DoctorMainChatPage> {
  final int _selectedIndex = 3;
  String? _specialistId;
  String searchText = '';

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
      default:
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    _specialistId = FirebaseAuth.instance.currentUser?.uid;
  }

  @override
  Widget build(BuildContext context) {
    final currentSpecialistId = _specialistId;
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
                      fontSize: 20,
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
                      fillColor: Color(0xFFF4F7F6),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
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
                      stream: currentSpecialistId == null
                          ? null
                          : FirebaseFirestore.instance
                                .collection('chats')
                                .where(
                                  'specialistId',
                                  isEqualTo: currentSpecialistId,
                                )
                                .orderBy(
                                  'lastMessageTimestamp',
                                  descending: true,
                                )
                                .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF0E382C),
                            ),
                          );
                        }
                        if (snapshot.hasError) {
                          print(
                            'Erro ao carregar conversas: ${snapshot.error}',
                          );
                          return Center(
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
                            final patientName =
                                chatData['patientName'] ?? 'Paciente';
                            final lastMessage =
                                chatData['lastMessage'] ?? 'Inicie a conversa';

                            final timestamp =
                                chatData['lastMessageTimestamp'] as Timestamp?;
                            final timeString = timestamp != null
                                ? DateFormat('HH:mm').format(timestamp.toDate())
                                : '';
                            final initialLetter = patientName.isNotEmpty
                                ? patientName[0].toUpperCase()
                                : '?';

                            return Card(
                              color: Color(0xFFF4F7F6),
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Color(0xFF0E382C),
                                  child: Text(
                                    initialLetter,
                                    style: GoogleFonts.montserrat(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  patientName,
                                  style: GoogleFonts.montserrat(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500,
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
                                    '/chat-detail',
                                    arguments: {
                                      'roomId': chatRoom.id,
                                      'name': patientName,
                                      'patientId': chatRoom.id
                                          .replaceAll('_', '')
                                          .replaceAll(currentSpecialistId!, ''),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/doctor-new-chat');
        },
        backgroundColor: Color(0xFF0E382C),
        child: Icon(Icons.chat, color: Colors.white),
      ),
      bottomNavigationBar: DoctorNavbar(
        currentIndex: _selectedIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}
