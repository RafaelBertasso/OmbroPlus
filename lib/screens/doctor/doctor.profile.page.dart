import 'package:Ombro_Plus/components/app.logo.dart';
import 'package:Ombro_Plus/components/doctor.navbar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DoctorProfilePage extends StatelessWidget {
  const DoctorProfilePage({super.key});
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
                Text(
                  'Nome',
                  style: GoogleFonts.montserrat(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Email',
                  style: GoogleFonts.openSans(
                    fontSize: 15,
                    color: Colors.black45,
                  ),
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
                      //implementar lógica de logout com firebase auth
                      Navigator.pushReplacementNamed(context, '/login');
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
