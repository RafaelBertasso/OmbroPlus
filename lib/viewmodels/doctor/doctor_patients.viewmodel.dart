import 'package:Ombro_Plus/models/patient.model.dart';
import 'package:Ombro_Plus/repositories/doctor_patient.repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';

class DoctorPatientsViewModel extends ChangeNotifier {
  final DoctorPatientRepository repository;

  DoctorPatientsViewModel({required this.repository});

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
      _patients = await repository.getPatientsBySpecialist(specialistId);
      _filteredPatients = _patients;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
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
}
