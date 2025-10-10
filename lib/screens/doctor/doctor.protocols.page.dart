import 'package:Ombro_Plus/components/app.logo.dart';
import 'package:Ombro_Plus/components/doctor.navbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DoctorProtocolsPage extends StatefulWidget {
  const DoctorProtocolsPage({super.key});

  @override
  State<DoctorProtocolsPage> createState() => _DoctorProtocolsPageState();
}

class _DoctorProtocolsPageState extends State<DoctorProtocolsPage> {
  final int _selectedIndex = 2;
  final String? specialistId = FirebaseAuth.instance.currentUser?.uid;

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
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('protocolos')
                          .where('especialistaId', isEqualTo: specialistId)
                          .orderBy('criadoEm', descending: true)
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
                          print(snapshot.error);
                          return Center(
                            child: Text('Erro ao carregar protocolos.'),
                          );
                        }
                        final protocolsDocs = snapshot.data?.docs ?? [];
                        if (protocolsDocs.isEmpty) {
                          return Center(
                            child: Text(
                              'Nenhum protocolo criado ainda. Crie um novo!',
                              style: GoogleFonts.openSans(
                                color: Colors.black54,
                              ),
                            ),
                          );
                        }
                        return ListView.separated(
                          itemCount: protocolsDocs.length,
                          separatorBuilder: (_, __) => SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final protocolData =
                                protocolsDocs[index].data()
                                    as Map<String, dynamic>;
                            final protocolId = protocolsDocs[index].id;
                            return FutureBuilder<DocumentSnapshot>(
                              future: FirebaseFirestore.instance
                                  .collection('pacientes')
                                  .doc(protocolData['pacienteId'])
                                  .get(),
                              builder: (context, patientSnapshot) {
                                String patientName = 'Carregando Paciente';
                                if (patientSnapshot.hasData &&
                                    patientSnapshot.data!.exists) {
                                  patientName =
                                      patientSnapshot.data!['nome'] ??
                                      'Paciente sem nome';
                                } else if (patientSnapshot.hasError) {
                                  patientName = 'Erro ao carregar nome';
                                }
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
                                      protocolData['nome'] ??
                                          'Protocolo sem nome',
                                      style: GoogleFonts.montserrat(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    subtitle: Text(
                                      'Paciente: $patientName',
                                      style: GoogleFonts.openSans(fontSize: 13),
                                    ),
                                    onTap: () {
                                      Navigator.pushNamed(
                                        context,
                                        '/protocol-details',
                                        arguments: {'protocoloId': protocolId},
                                      );
                                    },
                                    trailing: Icon(
                                      Icons.chevron_right,
                                      color: Colors.grey,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
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
