import 'package:Ombro_Plus/ui/doctor/doctor_patients/doctor_list_page.dart';
import 'package:Ombro_Plus/ui/doctor/doctor_patients/patient_list_page.dart';
import 'package:Ombro_Plus/viewmodels/doctor/doctor_list_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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

  void _showAddPatientOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFF4F7F6),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  top: 24,
                  right: 16,
                  bottom: 8,
                  left: 16,
                ),
                child: Text(
                  'Novo Paciente',
                  style: GoogleFonts.montserrat(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0E382C),
                  ),
                ),
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0E382C).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.person_add, color: Color(0xFF0E382C)),
                ),
                title: Text(
                  'Criar Conta para Paciente',
                  style: GoogleFonts.openSans(fontWeight: FontWeight.w700),
                ),
                subtitle: Text(
                  'Crie o perfil e defina uma senha de acesso.',
                  style: GoogleFonts.openSans(fontSize: 12),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(
                    context,
                    '/patient-register',
                    arguments: {'isDoctorCreating': true},
                  );
                },
              ),
              const Divider(indent: 70, height: 1),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0E382C).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.send, color: Color(0xFF0E382C)),
                ),
                title: Text(
                  'Enviar Convite',
                  style: GoogleFonts.openSans(fontWeight: FontWeight.w700),
                ),
                subtitle: Text('Vincule um paciente que já possui uma conta.'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/patient-invite');
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
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
            _showAddPatientOptions(context);
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
