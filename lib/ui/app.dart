import 'package:Ombro_Plus/repositories/auth.repository.dart';
import 'package:Ombro_Plus/repositories/protocol.repository.dart';
import 'package:Ombro_Plus/ui/doctor/profile/settings.page.dart';
import 'package:Ombro_Plus/ui/patient/profile/patient_settings.page.dart';
import 'package:Ombro_Plus/viewmodels/doctor/add_exercise.viewmodel.dart';
import 'package:Ombro_Plus/viewmodels/doctor/doctor_edit_profile.viewmodel.dart';
import 'package:Ombro_Plus/viewmodels/doctor/doctor_profile.viewmodel.dart';
import 'package:Ombro_Plus/viewmodels/doctor/new_exercise.viewmodel.dart';
import 'package:Ombro_Plus/viewmodels/doctor/protocol_schedule.viewmodel.dart';
import 'package:Ombro_Plus/viewmodels/patient/patient_edit_profile.viewmodel.dart';
import 'package:Ombro_Plus/viewmodels/patient/patient_profile.viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:Ombro_Plus/viewmodels/auth/auth.viewmodel.dart';
import 'package:Ombro_Plus/ui/auth/login_page.dart';

import 'package:Ombro_Plus/ui/auth/doctor_register.page.dart';
import 'package:Ombro_Plus/screens/doctor/doctor.chat.page.dart';
import 'package:Ombro_Plus/ui/doctor/profile/doctor_edit_profile.page.dart';
import 'package:Ombro_Plus/ui/doctor/doctor_patients/doctor_list.page.dart';
import 'package:Ombro_Plus/screens/doctor/doctor.main.chat.page.dart';
import 'package:Ombro_Plus/screens/doctor/doctor.new.chat.dart';
import 'package:Ombro_Plus/ui/doctor/profile/doctor_profile.page.dart';
import 'package:Ombro_Plus/ui/doctor/protocol/doctor_protocols.page.dart';
import 'package:Ombro_Plus/ui/doctor/protocol/new_exercise.page.dart';
import 'package:Ombro_Plus/ui/doctor/protocol/new_protocol.page.dart';

import 'package:Ombro_Plus/ui/doctor/doctor_patients/patient_detail.page.dart';
import 'package:Ombro_Plus/ui/doctor/doctor_patients/patient_list.page.dart';
import 'package:Ombro_Plus/ui/doctor/doctor_patients/patient_invite.page.dart';
import 'package:Ombro_Plus/ui/doctor/protocol/protocol_details.page.dart';
import 'package:Ombro_Plus/ui/doctor/protocol/protocol_exercise_adder.page.dart';
import 'package:Ombro_Plus/ui/doctor/protocol/protocol_schedule_editor.page.dart';
import 'package:Ombro_Plus/ui/doctor/protocol/protocol_schedule_viewer.page.dart';
import 'package:Ombro_Plus/ui/auth/patient_register.page.dart';
import 'package:Ombro_Plus/ui/patient/home/details_exercise.page.dart';
import 'package:Ombro_Plus/screens/patient/patient.chat.page.dart';
import 'package:Ombro_Plus/screens/patient/patient.clinical.form.page.dart';
import 'package:Ombro_Plus/ui/patient/dashboard/patient_dashboard.page.dart';
import 'package:Ombro_Plus/ui/patient/profile/patient_edit_profile.page.dart';
import 'package:Ombro_Plus/ui/patient/home/patient_home.page.dart';
import 'package:Ombro_Plus/screens/patient/patient.main.chat.page.dart';
import 'package:Ombro_Plus/ui/patient/profile/patient_profile.page.dart';
import 'package:Ombro_Plus/ui/patient/protocols/patient_protocol_details.page.dart';
import 'package:Ombro_Plus/ui/patient/protocols/patient_protocol_list.page.dart';
import 'package:Ombro_Plus/ui/shared/terms_of_use.page.dart';
import 'package:Ombro_Plus/ui/shared/user_list.page.dart';
import 'package:Ombro_Plus/ui/doctor/dashboard/doctor_dashboard.page.dart';
import 'package:Ombro_Plus/ui/doctor/home/doctor_home.page.dart';
import 'package:Ombro_Plus/ui/auth/forgot_password.page.dart';

class App extends StatelessWidget {
  const App({super.key});

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
        '/doctor-edit-profile': (context) => ChangeNotifierProvider(
          create: (context) => DoctorEditProfileViewModel(),
          child: const DoctorEditProfilePage(),
        ),
        '/protocol-schedule-editor': (context) => ChangeNotifierProvider(
          create: (_) => ProtocolScheduleViewModel(),
          child: const ProtocolScheduleEditorPage(),
        ),
        '/add-exercise-to-protocol': (context) => ChangeNotifierProvider(
          create: (context) => AddExerciseViewModel(
            repository: context.read<ProtocolRepository>(),
          ),
          child: const ProtocolExerciseAdderPage(),
        ),
        '/patient-invite': (context) => const PatientInvitePage(),
        '/forgot-password': (context) => const ForgotPasswordPage(),
        '/doctor-home': (context) => const DoctorHomePage(),

        // Dashboards Refatorados
        '/doctor-dashboard': (context) => const DoctorDashboardPage(),
        '/patient-dashboard': (context) => const PatientDashboardPage(),

        '/doctor-protocols': (context) => const DoctorProtocolsPage(),
        '/doctor-main-chat': (context) => const DoctorMainChatPage(),
        '/doctor-profile': (context) => ChangeNotifierProvider(
          create: (context) => DoctorProfileViewModel(
            authRepository: context.read<AuthRepository>(),
          ),
          child: const DoctorProfilePage(),
        ),
        '/chat-detail': (context) => const DoctorChatPage(),
        '/patient-list': (context) => const PatientListPage(),
        '/patient-detail': (context) => const PatientDetailPage(),
        '/new-protocol': (context) =>
            const NewProtocolPage(), // Tela refatorada
        '/new-exercise': (context) => ChangeNotifierProvider(
          create: (context) => NewExerciseViewModel(
            repository: context.read<ProtocolRepository>(),
          ),
          child: const NewExercisePage(),
        ),
        '/patient-home': (context) => const PatientHomePage(),
        '/patient-protocols': (context) => const PatientProtocolPage(),
        '/patient-main-chat': (context) => const PatientMainChatPage(),
        '/patient-profile': (context) => ChangeNotifierProvider(
          create: (context) => PatientProfileViewModel(
            authRepository: context.read<AuthRepository>(),
          ),
          child: const PatientProfilePage(),
        ),
        '/patient-chat': (context) => const PatientChatPage(),
        '/patient-clinical-form': (context) => const PatientClinicalFormPage(),
        '/doctor-new-chat': (context) => const PatientSelectionForChatPage(),
        '/patient-edit-profile': (context) => ChangeNotifierProvider(
          create: (context) => PatientEditProfileViewModel(),
          child: const PatientEditProfilePage(),
        ),
        '/exercise-details': (context) => const DetailsExercisePage(),
        '/terms-of-use': (context) => const TermsOfUsePage(),
        '/doctor-settings': (context) => ChangeNotifierProvider(
          create: (context) => DoctorProfileViewModel(
            authRepository: context.read<AuthRepository>(),
          ),
          child: const SettingsPage(),
        ),
        '/patient-settings': (context) => ChangeNotifierProvider(
          create: (context) => PatientProfileViewModel(
            authRepository: context.read<AuthRepository>(),
          ),
          child: const PatientSettingsPage(),
        ),
      },

      onGenerateRoute: (settings) {
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
          final arguments = settings.arguments as Map<String, dynamic>?;
          final String? protocolId = arguments?['protocoloId'] as String;
          if (protocolId != null) {
            return MaterialPageRoute(
              builder: (context) =>
                  PatientProtocolDetailsPage(protocolId: protocolId),
              settings: settings,
            );
          }
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
