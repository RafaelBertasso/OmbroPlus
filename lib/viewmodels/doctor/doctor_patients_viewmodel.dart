import 'package:Ombro_Plus/models/patient_model.dart';
import 'package:Ombro_Plus/repositories/auth_repository.dart';
import 'package:Ombro_Plus/repositories/doctor_patient_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';

class DoctorPatientsViewModel extends ChangeNotifier {
  final DoctorPatientRepository repository;
  final AuthRepository authRepository;
  final FirebaseFirestore _firestore;

  DoctorPatientsViewModel({
    required this.repository,
    required this.authRepository,
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  List<PatientModel> _patients = [];
  List<PatientModel> _filteredPatients = [];
  bool _isLoading = false;
  String? _error;
  String? _inviteCode;

  List<PatientModel> get patients => _filteredPatients;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get inviteCode => _inviteCode;

  Future<void> fetchPatients(String specialistId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final rawPatients = await repository.getPatientsBySpecialist(
        specialistId,
      );

      // Busca o status de evolução de cada paciente em paralelo
      final patientsWithStatus = await Future.wait(
        rawPatients.map((p) => _enrichWithEvolutionStatus(p, specialistId)),
      );

      _patients = patientsWithStatus;
      _filteredPatients = _patients;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Calcula o status de evolução com base no protocolo ativo do paciente.
  ///
  /// Lógica:
  /// - Sem protocolo ativo → semProtocolo (cinza)
  /// - sessoesConcluidas >= sessoesEsperadasAteHoje → emDia (verde)
  /// - sessoesConcluidas <  sessoesEsperadasAteHoje → atrasado (vermelho)
  ///
  /// "Sessões esperadas até hoje" é calculado proporcionalmente:
  ///   floor((diasDecorridos / duracaoTotalDias) * totalSessoesEstimadas)
  Future<PatientModel> _enrichWithEvolutionStatus(
    PatientModel patient,
    String specialistId,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('protocolos')
          .where('pacienteId', isEqualTo: patient.id)
          .where('especialistaId', isEqualTo: specialistId)
          .where('status', isEqualTo: 'active')
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        return patient.copyWithStatus(EvolutionStatus.semProtocolo);
      }

      final data = snapshot.docs.first.data();

      final dataInicio = data['dataInicio'] is Timestamp
          ? (data['dataInicio'] as Timestamp).toDate()
          : null;
      final dataFim = data['dataFim'] is Timestamp
          ? (data['dataFim'] as Timestamp).toDate()
          : null;
      final totalSessoes =
          (data['totalSessoesEstimadas'] as num?)?.toInt() ?? 0;
      final sessoesConcluidas =
          (data['sessoesConcluidas'] as num?)?.toInt() ?? 0;

      if (dataInicio == null || dataFim == null || totalSessoes == 0) {
        return patient.copyWithStatus(EvolutionStatus.semProtocolo);
      }

      final hoje = DateTime.now();
      final duracaoTotal = dataFim.difference(dataInicio).inDays;
      final diasDecorridos = hoje
          .difference(dataInicio)
          .inDays
          .clamp(0, duracaoTotal);

      // Proporção de sessões que deveriam ter sido feitas até hoje
      final sessoesEsperadas = duracaoTotal > 0
          ? (diasDecorridos / duracaoTotal * totalSessoes).floor()
          : 0;

      final status = sessoesConcluidas >= sessoesEsperadas
          ? EvolutionStatus.emDia
          : EvolutionStatus.atrasado;

      return patient.copyWithStatus(status);
    } catch (e) {
      // Em caso de erro na busca, retorna sem status definido
      return patient.copyWithStatus(EvolutionStatus.semProtocolo);
    }
  }

  Future<void> loadInviteCode() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) throw Exception("Especialista não logado.");

      _inviteCode = await repository.getOrGenerateInviteCode(currentUser.uid);
    } catch (e) {
      _error = e.toString();
      _inviteCode = "ERRO";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void searchPatients(String query) {
    if (query.isEmpty) {
      _filteredPatients = _patients;
    } else {
      _filteredPatients = _patients.where((p) {
        final name = p.nome.toLowerCase();
        final email = p.email.toLowerCase();
        return name.contains(query.toLowerCase()) ||
            email.contains(query.toLowerCase());
      }).toList();
    }
    notifyListeners();
  }

  Future<bool> invitePatient(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) throw Exception('Médico não logado.');

      final success = await repository.linkPatientByEmail(
        currentUser.uid,
        email,
      );

      if (success) {
        await fetchPatients(currentUser.uid);
        return true;
      } else {
        _error = "Paciente com este e-mail não encontrado no sistema.";
        return false;
      }
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createNewPatientAccount({
    required String email,
    required String password,
    required String nome,
    required String phone,
    required String birthDate,
    required int age,
    required String sex,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) throw Exception('Médico não logado.');

      await authRepository.registerPatientByDoctor(
        email: email,
        password: password,
        nome: nome,
        phone: phone,
        birthDate: birthDate,
        age: age,
        sex: sex,
        specialistId: currentUser.uid,
      );

      await fetchPatients(currentUser.uid);
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
