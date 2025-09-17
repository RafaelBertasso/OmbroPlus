import 'package:Ombro_Plus/components/app.logo.dart';
import 'package:Ombro_Plus/components/doctor.navbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DoctorProfilePage extends StatelessWidget {
  DoctorProfilePage({super.key});
  final _auth = FirebaseAuth.instance;
  final user = FirebaseAuth.instance.currentUser;
  final int _selectedIndex = 4;
  void _onTabTapped(BuildContext context, int index) {
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
      case 3:
        Navigator.pushReplacementNamed(context, '/doctor-main-chat');
        break;
      default:
        break;
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

  Future<String> getUserEmail() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return '';
    final doc = await FirebaseFirestore.instance
        .collection('especialistas')
        .doc(user.uid)
        .get();
    return doc.data()?['email'] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      body: Column(
        children: [
          AppLogo(),
          Container(
            padding: EdgeInsets.only(top: 50, bottom: 15),
            alignment: Alignment.center,
            child: Column(
              children: [
                CircleAvatar(
                  radius: 46,
                  backgroundColor: Color(0xFF0E382C),
                  child: Icon(Icons.person, color: Colors.white, size: 54),
                ),
                SizedBox(height: 8),
                FutureBuilder(
                  future: getUserName(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Text(
                        '',
                        style: GoogleFonts.montserrat(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      );
                    }
                    final nome = snapshot.data ?? 'Médico';
                    return Text(
                      nome,
                      style: GoogleFonts.montserrat(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    );
                  },
                ),
                SizedBox(height: 4),
                FutureBuilder(
                  future: getUserEmail(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Text(
                        '',
                        style: GoogleFonts.openSans(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      );
                    }
                    final email = snapshot.data ?? '';
                    return Text(
                      email,
                      style: GoogleFonts.openSans(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: 18),
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 16),
              children: [
                Card(
                  color: Color(0xFFF4F7F6),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: ListTile(
                    leading: Icon(
                      Icons.account_circle,
                      color: Color(0xFF0E382C),
                      size: 30,
                    ),
                    title: Text(
                      'Minha Conta',
                      style: GoogleFonts.openSans(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: 18,
                      color: Colors.grey[400],
                    ),
                    onTap: () {},
                  ),
                ),
                SizedBox(height: 10),
                Card(
                  color: Color(0xFFF4F7F6),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: ListTile(
                    leading: Icon(
                      Icons.notifications_active_outlined,
                      color: Color(0xFF0E382C),
                      size: 30,
                    ),
                    title: Text(
                      'Notificações',
                      style: GoogleFonts.openSans(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: 18,
                      color: Colors.grey[400],
                    ),
                    onTap: () {},
                  ),
                ),
                SizedBox(height: 30),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _auth.signOut().then((_) {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/login',
                          (route) => false,
                        );
                      });
                    },
                    icon: Icon(Icons.logout, color: Colors.white),
                    label: Text(
                      'Sair',
                      style: GoogleFonts.openSans(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 17,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF0E382C),
                      minimumSize: Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
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
