import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:Ombro_Plus/viewmodels/auth.viewmodel.dart';
import 'package:Ombro_Plus/ui/auth/login.page.dart';

import 'package:Ombro_Plus/screens/doctor.register.page.dart';
import 'package:Ombro_Plus/screens/doctor/doctor.chat.page.dart';
import 'package:Ombro_Plus/screens/doctor/doctor.edit.profile.page.dart';
import 'package:Ombro_Plus/screens/doctor/doctor.list.page.dart';
import 'package:Ombro_Plus/screens/doctor/doctor.main.chat.page.dart';
import 'package:Ombro_Plus/screens/doctor/doctor.new.chat.dart';
import 'package:Ombro_Plus/screens/doctor/doctor.profile.page.dart';
import 'package:Ombro_Plus/ui/doctor/protocol/doctor_protocols.page.dart';
import 'package:Ombro_Plus/screens/doctor/new.exercise.page.dart';
import 'package:Ombro_Plus/ui/doctor/protocol/new_protocol.page.dart';

import 'package:Ombro_Plus/screens/doctor/patient.detail.page.dart';
import 'package:Ombro_Plus/screens/doctor/patient.list.page.dart';
import 'package:Ombro_Plus/screens/doctor/patient.invite.page.dart';
import 'package:Ombro_Plus/screens/doctor/patient.log.page.dart';
import 'package:Ombro_Plus/ui/doctor/protocol/protocol_details.page.dart';
import 'package:Ombro_Plus/screens/doctor/protocol.exercise.adder.page.dart';
import 'package:Ombro_Plus/screens/doctor/protocol.schedule.editor.page.dart';
import 'package:Ombro_Plus/ui/doctor/protocol/protocol_schedule_viewer.page.dart';
import 'package:Ombro_Plus/screens/patient.register.page.dart';
import 'package:Ombro_Plus/screens/patient/details.exercise.page.dart';
import 'package:Ombro_Plus/screens/patient/patient.chat.page.dart';
import 'package:Ombro_Plus/screens/patient/patient.clinical.form.page.dart';
import 'package:Ombro_Plus/ui/patient/dashboard/patient_dashboard.page.dart';
import 'package:Ombro_Plus/screens/patient/patient.edit.profile.page.dart';
import 'package:Ombro_Plus/ui/patient/home/patient_home.page.dart';
import 'package:Ombro_Plus/screens/patient/patient.main.chat.page.dart';
import 'package:Ombro_Plus/screens/patient/patient.profile.page.dart';
import 'package:Ombro_Plus/screens/patient/patient.protocol.details.page.dart';
import 'package:Ombro_Plus/screens/patient/patient.protocol.page.dart';
import 'package:Ombro_Plus/screens/terms.of.use.page.dart';
import 'package:Ombro_Plus/screens/user.list.page.dart';
import 'package:Ombro_Plus/ui/doctor/dashboard/doctor_dashboard.page.dart';
import 'package:Ombro_Plus/ui/doctor/home/doctor.home.page.dart';
import 'package:Ombro_Plus/screens/forgot.password.page.dart';

class OmbroPlus extends StatelessWidget {
  const OmbroPlus({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ombro Plus',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        primaryColor: const Color(0xFF0E382C),
        useMaterial3: true,
        inputDecorationTheme: const InputDecorationTheme(
          labelStyle: TextStyle(color: Color(0xFF0E382C)),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF0E382C), width: 2),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
        ),
      ),

      home: const AuthWrapper(),

      routes: {
        '/login': (context) => const LoginPage(),
        '/patient-register': (context) => const PatientRegisterPage(),
        '/specialist-register': (context) => const DoctorRegisterPage(),
        '/doctor-list': (context) => const DoctorListPage(),
        '/user-list': (context) => const UserListPage(),
        '/doctor-edit-profile': (context) => const DoctorEditProfilePage(),
        '/patient-invite': (context) => const PatientInvitePage(),
        '/forgot-password': (context) => const ForgotPasswordPage(),
        '/doctor-home': (context) => const DoctorHomePage(),

        // Dashboards Refatorados
        '/doctor-dashboard': (context) => const DoctorDashboardPage(),
        '/patient-dashboard': (context) => const PatientDashboardPage(),

        '/doctor-protocols': (context) => const DoctorProtocolsPage(),
        '/doctor-main-chat': (context) => const DoctorMainChatPage(),
        '/doctor-profile': (context) => const DoctorProfilePage(),
        '/chat-detail': (context) => const DoctorChatPage(),
        '/patient-list': (context) => const PatientListPage(),
        '/patient-detail': (context) => const PatientDetailPage(),
        '/patient-log': (context) => PatientLogPage(),
        '/new-protocol': (context) =>
            const NewProtocolPage(), // Tela refatorada
        '/new-exercise': (context) => const NewExercisePage(),
        '/patient-home': (context) => const PatientHomePage(),
        '/patient-protocols': (context) => const PatientProtocolPage(),
        '/patient-main-chat': (context) => const PatientMainChatPage(),
        '/patient-profile': (context) => const PatientProfilePage(),
        '/patient-chat': (context) => const PatientChatPage(),
        '/patient-clinical-form': (context) => const PatientClinicalFormPage(),
        '/doctor-new-chat': (context) => const PatientSelectionForChatPage(),
        '/patient-edit-profile': (context) => const PatientEditProfilePage(),
        '/exercise-details': (context) => const DetailsExercisePage(),
        '/terms-of-use': (context) => const TermsOfUsePage(),
      },

      onGenerateRoute: (settings) {
        if (settings.name == '/protocol-schedule-editor') {
          final arguments = settings.arguments as Map<String, dynamic>?;
          final String? patientId = arguments?['patientId'] as String?;
          final String? startDateString = arguments?['startDate'] as String?;
          final String? endDateString = arguments?['endDate'] as String?;
          final currentSchedule =
              arguments?['currentSchedule']
                  as Map<String, List<Map<String, dynamic>>>?;

          if (patientId != null &&
              startDateString != null &&
              endDateString != null) {
            try {
              final startDate = DateTime.parse(startDateString);
              final endDate = DateTime.parse(endDateString);
              return MaterialPageRoute(
                builder: (context) => ProtocolScheduleEditorPage(
                  patientId: patientId,
                  startDate: startDate,
                  endDate: endDate,
                  currentSchedule: currentSchedule,
                ),
                settings: settings,
              );
            } catch (e) {
              debugPrint('Erro data schedule editor: $e');
            }
          }
        }

        if (settings.name == '/add-exercise-to-protocol') {
          final arguments = settings.arguments as Map<String, dynamic>?;
          final String? patientId = arguments?['patientId'] as String?;
          final List<String>? protocolDays = arguments?['protocolDays']
              ?.cast<String>();

          if (patientId != null && protocolDays != null) {
            return MaterialPageRoute(
              builder: (context) => ProtocolExerciseAdderPage(
                patientId: patientId,
                protocolDays: protocolDays,
              ),
              settings: settings,
            );
          }
        }

        if (settings.name == '/protocol-details') {
          final arguments = settings.arguments as Map<String, dynamic>?;
          final String? protocolId = arguments?['protocoloId'] as String?;

          if (protocolId != null) {
            return MaterialPageRoute(
              builder: (context) => ProtocolDetailsPage(protocolId: protocolId),
              settings: settings,
            );
          }
        }

        if (settings.name == '/patient-protocol-details') {
          return MaterialPageRoute(
            builder: (context) => const PatientProtocolDetailsPage(),
            settings: settings,
          );
        }

        if (settings.name == '/protocol-schedule-viewer') {
          final arguments = settings.arguments as Map<String, dynamic>?;
          final String? protocolId = arguments?['protocolId'] as String?;
          final String? startDateString = arguments?['startDate'] as String?;
          final String? endDateString = arguments?['endDate'] as String?;

          if (protocolId != null &&
              startDateString != null &&
              endDateString != null) {
            final startDate = DateTime.parse(startDateString);
            final endDate = DateTime.parse(endDateString);
            return MaterialPageRoute(
              builder: (context) => ProtocolScheduleViewerPage(
                protocolId: protocolId,
                startDate: startDate,
                endDate: endDate,
              ),
              settings: settings,
            );
          }
        }

        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Erro de Navegação')),
            body: Center(child: Text('Rota não encontrada: ${settings.name}')),
          ),
        );
      },
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, authViewModel, child) {
        if (authViewModel.user == null) {
          return const LoginPage();
        }

        switch (authViewModel.userType) {
          case UserType.doctor:
            return const DoctorHomePage();

          case UserType.patient:
            return const PatientHomePage();

          case UserType.unknown:
            return const Scaffold(
              backgroundColor: Color(0xFFF4F7F6),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Color(0xFF0E382C)),
                    SizedBox(height: 16),
                    Text(
                      "Carregando perfil...",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            );
        }
      },
    );
  }
}
