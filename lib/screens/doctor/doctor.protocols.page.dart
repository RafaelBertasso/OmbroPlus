import 'package:Ombro_Plus/components/app.logo.dart';
import 'package:Ombro_Plus/components/doctor.navbar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DoctorProtocolsPage extends StatefulWidget {
  const DoctorProtocolsPage({super.key});

  @override
  State<DoctorProtocolsPage> createState() => _DoctorProtocolsPageState();
}

class _DoctorProtocolsPageState extends State<DoctorProtocolsPage> {
  final int _selectedIndex = 2;
  final List<Map<String, String>> protocols = [
    {'name': 'Protocolo 1', 'patient': 'Paciente A'},
    {'name': 'Protocolo 2', 'patient': 'Paciente B'},
    {'name': 'Protocolo 3', 'patient': 'Paciente C'},
    {'name': 'Protocolo 4', 'patient': 'Paciente D'},
  ];

  void _onTabTapped(BuildContext context, int index) {
    if (index == _selectedIndex) return;
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/doctor-home');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/doctor-dashboard');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/doctor-main-chat');
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
    return Scaffold(
      backgroundColor: Color(0xFFF4F7F6),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/new-protocol'),
        backgroundColor: Color(0xFF0E382C),
        tooltip: 'Adicionar Protocolo',
        child: Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          AppLogo(),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Protocolos',
                    style: GoogleFonts.montserrat(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  Expanded(
                    child: ListView.separated(
                      itemCount: protocols.length,
                      separatorBuilder: (_, __) => SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final protocol = protocols[index];
                        return Card(
                          color: Color(0xFFF4F7F6),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            leading: Icon(
                              Icons.description,
                              color: Colors.black,
                            ),
                            title: Text(
                              protocol['name'] ?? '',
                              style: GoogleFonts.montserrat(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            subtitle: Text(
                              'Paciente: ${protocol['patient'] ?? ''}',
                              style: GoogleFonts.openSans(fontSize: 13),
                            ),
                            onTap: () {},
                            trailing: Icon(
                              Icons.chevron_right,
                              color: Colors.grey,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: DoctorNavbar(
        currentIndex: _selectedIndex,
        onTap: (index) => _onTabTapped(context, index),
      ),
    );
  }
}
