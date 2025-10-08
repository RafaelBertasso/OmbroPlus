import 'package:Ombro_Plus/screens/doctor.register.page.dart';
import 'package:Ombro_Plus/screens/doctor/doctor.chat.page.dart';
import 'package:Ombro_Plus/screens/doctor/doctor.edit.profile.page.dart';
import 'package:Ombro_Plus/screens/doctor/doctor.list.page.dart';
import 'package:Ombro_Plus/screens/doctor/doctor.main.chat.page.dart';
import 'package:Ombro_Plus/screens/doctor/doctor.new.chat.dart';
import 'package:Ombro_Plus/screens/doctor/doctor.profile.page.dart';
import 'package:Ombro_Plus/screens/doctor/doctor.protocols.page.dart';
import 'package:Ombro_Plus/screens/doctor/new.exercise.page.dart';
import 'package:Ombro_Plus/screens/doctor/new.protocol.page.dart';
import 'package:Ombro_Plus/screens/doctor/patient.detail.page.dart';
import 'package:Ombro_Plus/screens/doctor/patient.list.page.dart';
import 'package:Ombro_Plus/screens/doctor/patient.invite.page.dart';
import 'package:Ombro_Plus/screens/doctor/patient.log.page.dart';
import 'package:Ombro_Plus/screens/doctor/protocol.schedule.editor.page.dart';
import 'package:Ombro_Plus/screens/initial.page.dart';
import 'package:Ombro_Plus/screens/patient.register.page.dart';
import 'package:Ombro_Plus/screens/patient/patient.chat.page.dart';
import 'package:Ombro_Plus/screens/patient/patient.clinical.form.page.dart';
import 'package:Ombro_Plus/screens/patient/patient.dashboard.page.dart';
import 'package:Ombro_Plus/screens/patient/patient.home.page.dart';
import 'package:Ombro_Plus/screens/patient/patient.main.chat.page.dart';
import 'package:Ombro_Plus/screens/patient/patient.profile.page.dart';
import 'package:Ombro_Plus/screens/patient/patient.protocol.page.dart';
import 'package:Ombro_Plus/screens/user.list.page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:Ombro_Plus/screens/login.page.dart';
import 'package:Ombro_Plus/screens/doctor/doctor.dashboard.page.dart';
import 'package:Ombro_Plus/screens/doctor/doctor.home.page.dart';
import 'package:Ombro_Plus/screens/forgot.password.page.dart';

class OmbroPlus extends StatelessWidget {
  OmbroPlus({super.key});
  final _auth = FirebaseAuth.instance;

  final Map<String, WidgetBuilder> _simpleRoutes = {
    '/': (context) => InitialPage(),
    '/login': (context) => LoginPage(),
    '/patient-register': (context) => PatientRegisterPage(),
    '/specialist-register': (context) => DoctorRegisterPage(),
    '/doctor-list': (context) => DoctorListPage(),
    '/user-list': (context) => UserListPage(),
    '/doctor-edit-profile': (context) => DoctorEditProfilePage(),
    '/patient-invite': (context) => PatientInvitePage(),
    '/forgot-password': (context) => ForgotPasswordPage(),
    '/doctor-home': (context) => DoctorHomePage(),
    '/doctor-dashboard': (context) => DoctorDashboardPage(),
    '/doctor-protocols': (context) => DoctorProtocolsPage(),
    '/doctor-main-chat': (context) => DoctorMainChatPage(),
    '/doctor-profile': (context) => DoctorProfilePage(),
    '/chat-detail': (context) => DoctorChatPage(),
    '/patient-list': (context) => PatientListPage(),
    '/patient-detail': (context) => PatientDetailPage(),
    '/patient-log': (context) => PatientLogPage(),
    '/new-protocol': (context) => NewProtocolPage(),
    '/new-exercise': (context) => NewExercisePage(),
    '/patient-home': (context) => PatientHomePage(),
    '/patient-dashboard': (context) => PatientDashboardPage(),
    '/patient-protocols': (context) => PatientProtocolPage(),
    '/patient-main-chat': (context) => PatientMainChatPage(),
    '/patient-profile': (context) => PatientProfilePage(),
    '/patient-chat': (context) => PatientChatPage(),
    '/patient-clinical-form': (context) => PatientClinicalFormPage(),
    '/doctor-new-chat': (context) => PatientSelectionForChatPage(),
  };

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: _simpleRoutes,

      onGenerateRoute: (settings) {
        if (settings.name == '/protocol-schedule-editor') {
          final arguments = settings.arguments as Map<String, dynamic>?;

          final String? patientId = arguments?['patientId'] as String?;
          final String? startDateString = arguments?['startDate'] as String?;
          final String? endDateString = arguments?['endDate'] as String?;

          if (patientId != null &&
              startDateString != null &&
              endDateString != null) {
            try {
              final startDate = DateTime.parse(startDateString);
              final endDate = DateTime.parse(endDateString);

              return MaterialPageRoute(
                builder: (context) {
                  return ProtocolScheduleEditorPage(
                    patientId: patientId,
                    startDate: startDate,
                    endDate: endDate,
                  );
                },
                settings: settings,
              );
            } catch (e) {
              debugPrint(
                'Erro de parsing de data para ProtocolScheduleEditor: $e',
              );
            }
          }
          return MaterialPageRoute(
            builder: (_) => Scaffold(
              appBar: AppBar(title: const Text('Erro de Navegação')),
              body: const Center(
                child: Text(
                  'Não foi possível carregar o editor de cronograma. Argumentos ausentes ou inválidos.',
                ),
              ),
            ),
          );
        }

        return null;
      },

      initialRoute: _auth.currentUser == null ? '/login' : '/',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        inputDecorationTheme: InputDecorationTheme(
          labelStyle: const TextStyle(color: Color(0xFF0E382C)),
          focusedBorder: UnderlineInputBorder(
            borderSide: const BorderSide(color: Color(0xFF0E382C), width: 2),
          ),
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
        ),
      ),
    );
  }
}
