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
  bool _isAdmin = false;
  bool _isCheckingAdmin = true;

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

  @override
  void initState() {
    super.initState();
    _checkAdminStatus();
  }

  Future<void> _checkAdminStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _isAdmin = false;
        _isCheckingAdmin = false;
      });
      return;
    }
    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('especialistas')
          .doc(user.uid)
          .get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data();
        if (data?['isAdmin'] == true) {
          setState(() {
            _isAdmin = true;
          });
        }
      }
    } catch (e) {
      print("Erro ao verificar status de administrador: $e");
      setState(() {
        _isAdmin = false;
      });
    } finally {
      setState(() {
        _isCheckingAdmin = false;
      });
    }
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
    if (_isCheckingAdmin) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF0E382C)),
        ),
      );
    }
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
                                Navigator.pushNamed(context, '/patient-list'),
                            child: Text(
                              'Pacientes',
                              style: TextStyle(color: Color(0xFF0E382C)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 60),
                    //TODO: Trocar essa parte
                    Text(
                      'Principais Notícias de Hoje',
                      style: GoogleFonts.montserrat(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 18),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _isAdmin
          ? FloatingActionButton(
              onPressed: () =>
                  Navigator.pushNamed(context, '/specialist-register'),
              backgroundColor: Color(0xFF0E382C),
              tooltip: 'Adicionar Especialista',
              child: Icon(Icons.person_add, color: Colors.white),
            )
          : null,
      bottomNavigationBar: DoctorNavbar(
        currentIndex: _selectedIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}
