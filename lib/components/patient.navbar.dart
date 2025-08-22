import 'package:flutter/material.dart';

class PatientNavbar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  const PatientNavbar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF0E382C),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SizedBox(
        height: 90,
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: onTap,
          backgroundColor: Colors.transparent,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 13,
          ),
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white,
          showUnselectedLabels: true,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home, color: Colors.white),
              label: 'Home',
              backgroundColor: Colors.white,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.analytics_rounded, color: Colors.white),
              label: 'Dashboard',
              backgroundColor: Colors.white,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.list_alt, color: Colors.white),
              label: 'Protocolos',
              backgroundColor: Colors.white,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.group, color: Colors.white),
              label: 'Chat',
              backgroundColor: Colors.white,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person, color: Colors.white),
              label: 'Perfil',
              backgroundColor: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
