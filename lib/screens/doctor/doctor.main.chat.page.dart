import 'package:Ombro_Plus/components/app.logo.dart';
import 'package:Ombro_Plus/components/doctor.navbar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DoctorMainChatPage extends StatefulWidget {
  const DoctorMainChatPage({super.key});

  @override
  State<DoctorMainChatPage> createState() => _DoctorMainChatPageState();
}

class _DoctorMainChatPageState extends State<DoctorMainChatPage> {
  final int _selectedIndex = 3;
  final List<Map<String, String>> chats = [
    {'name': 'Rodrigo Garro', 'lastMessage': 'Olá, doutor!', 'time': '10:30'},
    {
      'name': 'André Ramalho',
      'lastMessage': 'Estou me sentindo melhor.',
      'time': '15:37',
    },
    {
      'name': 'Cássio Ramos',
      'lastMessage': 'Preciso de uma consulta.',
      'time': '08:45',
    },
    {
      'name': 'Matheus Bidu',
      'lastMessage': 'Obrigado pelo atendimento.',
      'time': '12:15',
    },
    {
      'name': 'Gustavo Scarpa',
      'lastMessage': 'Quando é a próxima consulta?',
      'time': '09:00',
    },
    {
      'name': 'Rafael Sobis',
      'lastMessage': 'Estou com dúvidas sobre o tratamento.',
      'time': '14:20',
    },
    {
      'name': 'Bruno Rodrigues',
      'lastMessage': 'Agradeço pela ajuda.',
      'time': '11:05',
    },
    {
      'name': 'Lucas Lima',
      'lastMessage': 'Estou seguindo as orientações.',
      'time': '16:50',
    },
    {
      'name': 'Felipe Melo',
      'lastMessage': 'Como está meu progresso?',
      'time': '13:30',
    },
    {
      'name': 'Eduardo Vargas',
      'lastMessage': 'Obrigado pelo suporte.',
      'time': '17:15',
    },
  ];

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
                                      '/chat-detail',
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
      bottomNavigationBar: DoctorNavbar(
        currentIndex: _selectedIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}
