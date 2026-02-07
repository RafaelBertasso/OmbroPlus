import 'package:Ombro_Plus/repositories/auth_repository.dart';
import 'package:Ombro_Plus/repositories/chat_repository.dart';
import 'package:Ombro_Plus/repositories/protocol_repository.dart';
import 'package:Ombro_Plus/ui/doctor/profile/settings_page.dart';
import 'package:Ombro_Plus/ui/patient/profile/patient_settings_page.dart';
import 'package:Ombro_Plus/viewmodels/doctor/add_exercise_viewmodel.dart';
import 'package:Ombro_Plus/viewmodels/doctor/doctor_edit_profile_viewmodel.dart';
import 'package:Ombro_Plus/viewmodels/doctor/doctor_profile_viewmodel.dart';
import 'package:Ombro_Plus/viewmodels/doctor/new_chat_viewmodel.dart';
import 'package:Ombro_Plus/viewmodels/doctor/new_exercise_viewmodel.dart';
import 'package:Ombro_Plus/viewmodels/doctor/protocol_schedule_viewmodel.dart';
import 'package:Ombro_Plus/viewmodels/patient/patient_edit_profile_viewmodel.dart';
import 'package:Ombro_Plus/viewmodels/patient/patient_profile_viewmodel.dart';
import 'package:Ombro_Plus/viewmodels/shared/chat_list_viewmodel.dart';
import 'package:Ombro_Plus/viewmodels/shared/chat_viewmodel.dart';
import 'package:Ombro_Plus/viewmodels/shared/patient_clinical_form_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:Ombro_Plus/viewmodels/auth/auth_viewmodel.dart';
import 'package:Ombro_Plus/ui/auth/login_page.dart';

import 'package:Ombro_Plus/ui/auth/doctor_register_page.dart';
import 'package:Ombro_Plus/ui/doctor/chat/doctor_chat_page.dart';
import 'package:Ombro_Plus/ui/doctor/profile/doctor_edit_profile_page.dart';
import 'package:Ombro_Plus/ui/doctor/doctor_patients/doctor_list_page.dart';
import 'package:Ombro_Plus/ui/doctor/chat/doctor_main_chat_page.dart';
import 'package:Ombro_Plus/ui/doctor/chat/doctor_new_chat.dart';
import 'package:Ombro_Plus/ui/doctor/profile/doctor_profile_page.dart';
import 'package:Ombro_Plus/ui/doctor/protocol/doctor_protocols_page.dart';
import 'package:Ombro_Plus/ui/doctor/protocol/new_exercise_page.dart';
import 'package:Ombro_Plus/ui/doctor/protocol/new_protocol_page.dart';

import 'package:Ombro_Plus/ui/doctor/doctor_patients/patient_detail_page.dart';
import 'package:Ombro_Plus/ui/doctor/doctor_patients/patient_list_page.dart';
import 'package:Ombro_Plus/ui/doctor/doctor_patients/patient_invite_page.dart';
import 'package:Ombro_Plus/ui/doctor/protocol/protocol_details_page.dart';
import 'package:Ombro_Plus/ui/doctor/protocol/protocol_exercise_adder_page.dart';
import 'package:Ombro_Plus/ui/doctor/protocol/protocol_schedule_editor_page.dart';
import 'package:Ombro_Plus/ui/doctor/protocol/protocol_schedule_viewer_page.dart';
import 'package:Ombro_Plus/ui/auth/patient_register_page.dart';
import 'package:Ombro_Plus/ui/patient/home/details_exercise_page.dart';
import 'package:Ombro_Plus/ui/patient/chat/patient_chat_page.dart';
import 'package:Ombro_Plus/ui/shared/patient_clinical_form_page.dart';
import 'package:Ombro_Plus/ui/patient/dashboard/patient_dashboard_page.dart';
import 'package:Ombro_Plus/ui/patient/profile/patient_edit_profile_page.dart';
import 'package:Ombro_Plus/ui/patient/home/patient_home_page.dart';
import 'package:Ombro_Plus/ui/patient/chat/patient_main_chat_page.dart';
import 'package:Ombro_Plus/ui/patient/profile/patient_profile_page.dart';
import 'package:Ombro_Plus/ui/patient/protocols/patient_protocol_details_page.dart';
import 'package:Ombro_Plus/ui/patient/protocols/patient_protocol_list_page.dart';
import 'package:Ombro_Plus/ui/shared/terms_of_use_page.dart';
import 'package:Ombro_Plus/ui/shared/user_list_page.dart';
import 'package:Ombro_Plus/ui/doctor/dashboard/doctor_dashboard_page.dart';
import 'package:Ombro_Plus/ui/doctor/home/doctor_home_page.dart';
import 'package:Ombro_Plus/ui/auth/forgot_password_page.dart';

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
        '/doctor-main-chat': (context) => ChangeNotifierProvider(
          create: (context) =>
              ChatListViewmodel(chatRepository: context.read<ChatRepository>()),
          child: const DoctorMainChatPage(),
        ),
        '/doctor-profile': (context) => ChangeNotifierProvider(
          create: (context) => DoctorProfileViewModel(
            authRepository: context.read<AuthRepository>(),
          ),
          child: const DoctorProfilePage(),
        ),
        '/chat-detail': (context) => ChangeNotifierProvider(
          create: (context) =>
              ChatViewModel(chatRepository: context.read<ChatRepository>()),
          child: const DoctorChatPage(),
        ),
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
        '/patient-main-chat': (context) => ChangeNotifierProvider(
          create: (context) =>
              ChatListViewmodel(chatRepository: context.read<ChatRepository>()),
          child: const PatientMainChatPage(),
        ),
        '/patient-profile': (context) => ChangeNotifierProvider(
          create: (context) => PatientProfileViewModel(
            authRepository: context.read<AuthRepository>(),
          ),
          child: const PatientProfilePage(),
        ),
        '/patient-chat': (context) => ChangeNotifierProvider(
          create: (context) =>
              ChatViewModel(chatRepository: context.read<ChatRepository>()),
          child: const PatientChatPage(),
        ),
        '/patient-clinical-form': (context) => ChangeNotifierProvider(
          create: (context) => PatientClinicalFormViewModel(),
          child: const PatientClinicalFormPage(),
        ),
        '/doctor-new-chat': (context) => ChangeNotifierProvider(
          create: (context) =>
              NewChatViewModel(chatRepository: context.read<ChatRepository>()),
          child: const PatientSelectionForChatPage(),
        ),
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
