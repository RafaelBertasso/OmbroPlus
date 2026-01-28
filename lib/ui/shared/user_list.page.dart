import 'package:Ombro_Plus/ui/doctor/doctor_patients/doctor_list.page.dart';
import 'package:Ombro_Plus/ui/doctor/doctor_patients/patient_list.page.dart';
import 'package:Ombro_Plus/viewmodels/doctor/doctor_list.viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });
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
        backgroundColor: Color(0xFF0E382C),
        title: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Color(0xFFA9DBC2),
          indicatorColor: Colors.white,
          dividerColor: Colors.transparent,
          tabs: [
            Tab(text: 'Pacientes'),
            Tab(text: 'Especialistas'),
          ],
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back, color: Colors.white),
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
          if (_tabController.index == 0) {
            Navigator.pushNamed(context, '/patient-invite');
          } else {
            Navigator.pushNamed(context, '/specialist-register').then((_) {
              if (mounted) {
                context.read<DoctorListViewModel>().fetchSpecialists();
              }
            });
          }
        },
      ),
    );
  }
}
