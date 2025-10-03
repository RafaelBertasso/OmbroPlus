import 'package:Ombro_Plus/components/Activity.item.dart';
import 'package:Ombro_Plus/components/doctor.navbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DoctorHomePage extends StatefulWidget {
  const DoctorHomePage({super.key});

  @override
  State<DoctorHomePage> createState() => _DoctorHomePageState();
}

class _DoctorHomePageState extends State<DoctorHomePage> {
  final int _selectedIndex = 0;
  final user = FirebaseAuth.instance.currentUser;
  String? _specialistId;

  void _onTabTapped(int index) {
    if (index == _selectedIndex) return;
    switch (index) {
      case 1:
        Navigator.pushReplacementNamed(context, '/doctor-dashboard');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/doctor-protocols');
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

  IconData _getIconForActivityType(String type) {
    switch (type) {
      case 'EXERCISE_COMPLETED':
        return Icons.check_circle_outline;
      case 'NEW_PATIENT':
        return Icons.person_add;
      case 'PAIN_ALERT':
        return Icons.warning_amber_rounded;
      case 'PROTOCOL_FINISHED':
        return Icons.star;
      case 'INACTIVITY': // 🟢 AÇÃO ADICIONAL
        return Icons.timer_off;
      default:
        return Icons.info_outline;
    }
  }

  Color _getColorForActivityType(String type) {
    switch (type) {
      case 'EXERCISE_COMPLETED':
        return Colors.green.shade700;
      case 'NEW_PATIENT':
        return const Color(0xFF0E382C);
      case 'PAIN_ALERT':
        return Colors.red.shade700;
      case 'PROTOCOL_FINISHED':
        return Colors.amber.shade800;
      case 'INACTIVITY': // 🟢 AÇÃO ADICIONAL
        return Colors.orange.shade700;
      default:
        return Colors.grey;
    }
  }

  @override
  void initState() {
    super.initState();
    _specialistId = user?.uid;
  }

  Future<String> getUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return '';
    final doc = await FirebaseFirestore.instance
        .collection('especialistas')
        .doc(user.uid)
        .get();
    return doc.data()?['nome'] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 18, bottom: 8),
            child: SizedBox(
              height: 100,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Center(
                    child: Image.asset(
                      'assets/images/logo-app.png',
                      width: 100,
                      height: 100,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsetsGeometry.symmetric(
                  horizontal: 18.0,
                  vertical: 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FutureBuilder(
                      future: getUserName(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Text(
                            'Bem vindo, ...',
                            style: GoogleFonts.montserrat(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          );
                        }
                        final nome = snapshot.data ?? 'Médico';
                        return Text(
                          'Bem vindo, $nome',
                          style: GoogleFonts.montserrat(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF0E382C),
                              minimumSize: Size(0, 48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadiusGeometry.circular(8),
                              ),
                            ),
                            onPressed: () =>
                                Navigator.pushNamed(context, '/new-protocol'),
                            child: Text(
                              'Nova sessão',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color.fromARGB(
                                112,
                                145,
                                228,
                                205,
                              ),
                              minimumSize: Size(0, 48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadiusGeometry.circular(8),
                              ),
                            ),
                            onPressed: () =>
                                Navigator.pushNamed(context, '/user-list'),
                            child: Text(
                              'Usuários',
                              style: TextStyle(color: Color(0xFF0E382C)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 60),
                    //TODO: Trocar essa parte
                    Text(
                      'Atividades Recentes',
                      style: GoogleFonts.montserrat(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 18),
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('activity_feed')
                          .orderBy('timestamp', descending: true)
                          .limit(6)
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
                          return Text(
                            'Erro ao carregar o feed de atividades',
                            style: TextStyle(color: Colors.red),
                          );
                        }
                        final documents = snapshot.data?.docs ?? [];
                        if (documents.isEmpty) {
                          return Text('Nenhuma atividade recente encontrada.');
                        }
                        return ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: documents.length,
                          itemBuilder: (context, index) {
                            final activity =
                                documents[index].data() as Map<String, dynamic>;
                            final type =
                                activity['type'] as String? ?? 'DEFAULT';
                            final iconData = _getIconForActivityType(type);
                            final iconColor = _getColorForActivityType(type);

                            return Padding(
                              padding: EdgeInsetsGeometry.only(bottom: 8),
                              child: ActivityItem(
                                title: activity['patientName'],
                                subtitle: activity['message'],
                                icon: iconData,
                                iconColor: iconColor,
                                onTap: () => Navigator.pushNamed(
                                  context,
                                  activity['relatedRoute'],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                    SizedBox(height: 30),
                  ],
                ),
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
