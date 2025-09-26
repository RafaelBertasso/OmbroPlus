import 'package:Ombro_Plus/screens/doctor/doctor.list.page.dart';
import 'package:Ombro_Plus/screens/doctor/patient.list.page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UserListPage extends StatefulWidget {
  const UserListPage({super.key});

  @override
  State<UserListPage> createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF4F7F6),
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back, color: Colors.white),
        ),
        backgroundColor: Color(0xFF0E382C),
        elevation: 0.4,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.black, size: 26),
        title: Text(
          'Usuários',
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Color.fromARGB(255, 169, 219, 194),
          indicatorColor: Colors.white,
          tabs: [
            Tab(text: 'Pacientes'),
            Tab(text: 'Especialistas'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [PatientListPage(), DoctorListPage()],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFF0E382C),
        child: Icon(Icons.add, color: Colors.white),
        onPressed: () {
          final route = _tabController.index == 0
              ? '/patient-register'
              : '/specialist-register';
          Navigator.pushNamed(context, route);
        },
      ),
    );
  }
}
