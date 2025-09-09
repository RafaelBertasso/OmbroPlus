import 'package:Ombro_Plus/components/app.logo.dart';
import 'package:Ombro_Plus/components/patient.navbar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PatientMainChatPage extends StatefulWidget {
  const PatientMainChatPage({super.key});

  @override
  State<PatientMainChatPage> createState() => _PatientMainChatPageState();
}

class _PatientMainChatPageState extends State<PatientMainChatPage> {
  final int _selectedIndex = 3;
  final List<Map<String, String>> chats = [
    {
      'name': 'Dra. Juliana',
      'lastMessage': 'Olá! Como está hoje?',
      'time': '10:30',
    },
    {
      'name': 'Cefis',
      'lastMessage': 'Sua próxima sessão é amanhã.',
      'time': '15:37',
    },
  ];

  String searchText = '';

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

  @override
  Widget build(BuildContext context) {
    final filteredChats = chats.where((chat) {
      final name = chat['name']!.toLowerCase();
      final query = searchText.toLowerCase();
      return name.contains(query);
    }).toList();
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
                    child: filteredChats.isEmpty
                        ? Center(
                            child: Text(
                              'Nenhuma conversa',
                              style: GoogleFonts.openSans(
                                color: Colors.black54,
                              ),
                            ),
                          )
                        : ListView.separated(
                            itemCount: filteredChats.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final chat = filteredChats[index];
                              return Card(
                                color: const Color(0xFFF4F7F6),
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Color(0xFF0E382C),
                                    child: Text(
                                      chat['name']![0],
                                      style: GoogleFonts.montserrat(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    chat['name'] ?? '',
                                    style: GoogleFonts.montserrat(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black,
                                    ),
                                  ),
                                  subtitle: Text(
                                    chat['lastMessage'] ?? '',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.openSans(
                                      color: Colors.black54,
                                      fontSize: 14,
                                    ),
                                  ),
                                  trailing: Text(
                                    chat['time'] ?? '',
                                    style: GoogleFonts.openSans(
                                      color: Colors.black54,
                                      fontSize: 12,
                                    ),
                                  ),
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      '/patient-chat',
                                      arguments: chat,
                                    );
                                  },
                                ),
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
