import 'package:Ombro_Plus/firebase_options.dart';
import 'package:Ombro_Plus/repositories/auth.repository.dart';
import 'package:Ombro_Plus/repositories/dashboard.repository.dart';
import 'package:Ombro_Plus/repositories/doctor.repository.dart';
import 'package:Ombro_Plus/repositories/doctor_patient.repository.dart';
import 'package:Ombro_Plus/repositories/protocol.repository.dart';
import 'package:Ombro_Plus/ui/app.dart';
import 'package:Ombro_Plus/viewmodels/auth/auth.viewmodel.dart';
import 'package:Ombro_Plus/viewmodels/auth/doctor_register.viewmodel.dart';
import 'package:Ombro_Plus/viewmodels/doctor/dashboard_doctor.viewmodel.dart';
import 'package:Ombro_Plus/viewmodels/doctor/doctor_list.viewmodel.dart';
import 'package:Ombro_Plus/viewmodels/doctor/doctor_patients.viewmodel.dart';
import 'package:Ombro_Plus/viewmodels/doctor/patient_details.viewmodel.dart';
import 'package:Ombro_Plus/viewmodels/patient/dashboard_patient.viewmodel.dart';
import 'package:Ombro_Plus/viewmodels/doctor/doctor_home.viewmodel.dart';
import 'package:Ombro_Plus/viewmodels/doctor/doctor_protocols.viewmodel.dart';
import 'package:Ombro_Plus/viewmodels/doctor/new_protocol.viewmodel.dart';
import 'package:Ombro_Plus/viewmodels/patient/exercise_details.viewmodel.dart';
import 'package:Ombro_Plus/viewmodels/patient/patient_home.viewmodel.dart';
import 'package:Ombro_Plus/viewmodels/patient/patient_protocols.viewmodel.dart';
import 'package:Ombro_Plus/viewmodels/shared/protocol_details.viewmodel.dart';
import 'package:Ombro_Plus/viewmodels/shared/protocol_schedule_viewer.viewmodel.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

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
            dashRepo: context.read<DashboardRepository>(),
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
      ],
      child: App(),
    ),
  );
}
