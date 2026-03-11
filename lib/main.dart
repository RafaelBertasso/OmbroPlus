import 'package:Ombro_Plus/firebase_options.dart';
import 'package:Ombro_Plus/repositories/auth_repository.dart';
import 'package:Ombro_Plus/repositories/chat_repository.dart';
import 'package:Ombro_Plus/repositories/dashboard_repository.dart';
import 'package:Ombro_Plus/repositories/doctor_repository.dart';
import 'package:Ombro_Plus/repositories/doctor_patient_repository.dart';
import 'package:Ombro_Plus/repositories/protocol_repository.dart';
import 'package:Ombro_Plus/ui/app.dart';
import 'package:Ombro_Plus/viewmodels/auth/auth_viewmodel.dart';
import 'package:Ombro_Plus/viewmodels/auth/doctor_register_viewmodel.dart';
import 'package:Ombro_Plus/viewmodels/doctor/dashboard_doctor_viewmodel.dart';
import 'package:Ombro_Plus/viewmodels/doctor/doctor_list_viewmodel.dart';
import 'package:Ombro_Plus/viewmodels/doctor/doctor_patients_viewmodel.dart';
import 'package:Ombro_Plus/viewmodels/doctor/patient_details_viewmodel.dart';
import 'package:Ombro_Plus/viewmodels/doctor/specialist_selection_viewmodel.dart';
import 'package:Ombro_Plus/viewmodels/patient/dashboard_patient_viewmodel.dart';
import 'package:Ombro_Plus/viewmodels/doctor/doctor_home_viewmodel.dart';
import 'package:Ombro_Plus/viewmodels/doctor/doctor_protocols_viewmodel.dart';
import 'package:Ombro_Plus/viewmodels/doctor/new_protocol_viewmodel.dart';
import 'package:Ombro_Plus/viewmodels/patient/exercise_details_viewmodel.dart';
import 'package:Ombro_Plus/viewmodels/patient/patient_home_viewmodel.dart';
import 'package:Ombro_Plus/viewmodels/patient/patient_protocols_viewmodel.dart';
import 'package:Ombro_Plus/viewmodels/shared/patient_selection_viewmodel.dart';
import 'package:Ombro_Plus/viewmodels/shared/protocol_details_viewmodel.dart';
import 'package:Ombro_Plus/viewmodels/shared/protocol_schedule_viewer_viewmodel.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  await initializeDateFormatting('pt_BR', null);

  runApp(
    MultiProvider(
      providers: [
        Provider<AuthRepository>(create: (_) => AuthRepository()),

        Provider<ProtocolRepository>(create: (_) => ProtocolRepository()),

        Provider<DashboardRepository>(create: (_) => DashboardRepository()),

        Provider<DoctorListRepository>(create: (_) => DoctorListRepository()),

        Provider<DoctorPatientRepository>(
          create: (_) => DoctorPatientRepository(),
        ),
        Provider<ChatRepository>(create: (_) => ChatRepository()),

        ChangeNotifierProvider<AuthViewModel>(
          create: (context) =>
              AuthViewModel(repository: context.read<AuthRepository>()),
        ),

        ChangeNotifierProvider<NewProtocolViewModel>(
          create: (context) => NewProtocolViewModel(
            repository: context.read<ProtocolRepository>(),
          ),
        ),

        ChangeNotifierProvider<DashboardDoctorViewModel>(
          create: (context) => DashboardDoctorViewModel(
            repository: context.read<DashboardRepository>(),
          ),
        ),

        ChangeNotifierProvider<DashboardPatientViewModel>(
          create: (context) => DashboardPatientViewModel(
            repository: context.read<DashboardRepository>(),
          ),
        ),

        ChangeNotifierProvider<DoctorHomeViewModel>(
          create: (context) => DoctorHomeViewModel(
            authRepository: context.read<AuthRepository>(),
            dashboardRepository: context.read<DashboardRepository>(),
          ),
        ),

        ChangeNotifierProvider<PatientHomeViewModel>(
          create: (context) => PatientHomeViewModel(
            authRepo: context.read<AuthRepository>(),
            protoRepo: context.read<ProtocolRepository>(),
          ),
        ),

        ChangeNotifierProvider<DoctorProtocolsViewModel>(
          create: (context) => DoctorProtocolsViewModel(
            repository: context.read<ProtocolRepository>(),
          ),
        ),

        ChangeNotifierProvider<ProtocolDetailsViewModel>(
          create: (context) => ProtocolDetailsViewModel(
            repository: context.read<ProtocolRepository>(),
          ),
        ),

        ChangeNotifierProvider<ProtocolScheduleViewerViewModel>(
          create: (context) => ProtocolScheduleViewerViewModel(
            repository: context.read<ProtocolRepository>(),
          ),
        ),

        ChangeNotifierProvider<PatientProtocolsViewModel>(
          create: (context) => PatientProtocolsViewModel(
            repository: context.read<ProtocolRepository>(),
          ),
        ),

        ChangeNotifierProvider<ExerciseDetailsViewModel>(
          create: (context) => ExerciseDetailsViewModel(
            repository: context.read<ProtocolRepository>(),
          ),
        ),

        ChangeNotifierProvider<DoctorPatientsViewModel>(
          create: (context) => DoctorPatientsViewModel(
            repository: context.read<DoctorPatientRepository>(),
            authRepository: context.read<AuthRepository>(),
          ),
        ),

        ChangeNotifierProvider<PatientDetailsViewModel>(
          create: (context) => PatientDetailsViewModel(
            patientRepository: context.read<DoctorPatientRepository>(),
            protocolRepository: context.read<ProtocolRepository>(),
          ),
        ),

        ChangeNotifierProvider<DoctorRegisterViewModel>(
          create: (context) => DoctorRegisterViewModel(
            authRepository: context.read<AuthRepository>(),
          ),
        ),

        ChangeNotifierProvider<DoctorListViewModel>(
          create: (context) => DoctorListViewModel(
            repository: context.read<DoctorListRepository>(),
          ),
        ),
        ChangeNotifierProvider<SpecialistSelectionViewmodel>(
          create: (context) => SpecialistSelectionViewmodel(
            repository: context.read<DoctorListRepository>(),
          ),
        ),

        ChangeNotifierProvider<PatientSelectionViewmodel>(
          create: (context) => PatientSelectionViewmodel(),
        ),
      ],
      child: App(),
    ),
  );
}
