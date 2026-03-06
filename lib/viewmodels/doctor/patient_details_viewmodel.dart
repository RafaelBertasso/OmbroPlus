import 'package:Ombro_Plus/models/patient_model.dart';
import 'package:Ombro_Plus/models/protocol_model.dart';
import 'package:Ombro_Plus/repositories/doctor_patient_repository.dart';
import 'package:Ombro_Plus/repositories/protocol_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PatientDetailsViewModel extends ChangeNotifier {
  final DoctorPatientRepository patientRepository;
  final ProtocolRepository protocolRepository;

  PatientDetailsViewModel({
    required this.patientRepository,
    required this.protocolRepository,
  });

  PatientModel? _patient;
  List<ProtocolModel> _activeProtocols = [];
  List<DateTime> _completedSessionDays = [];

  bool _isLoading = true;
  String? _error;

  PatientModel? get patient => _patient;
  List<ProtocolModel> get activeProtocols => _activeProtocols;
  List<DateTime> get completedSessionDays => _completedSessionDays;
  bool get isLoading => _isLoading;
  String? get error => _error;

  String get patientInitials {
    if (_patient == null) return "?";
    final parts = _patient!.nome.trim().split(' ');
    if (parts.isEmpty) return "";
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  Future<void> loadPatientData(String patientId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _patient = await patientRepository.getPatientDetails(patientId);

      if (_patient == null) {
        _error = 'Paciente não encontrado';
        return;
      }

      _activeProtocols = await protocolRepository.fetchActiveProtocolsByPatient(
        patientId,
      );

      List<Map<String, dynamic>> logs = [];

      for (var protocol in _activeProtocols) {
        final protocolLogs = await patientRepository.getPatientExerciseLogs(
          patientId,
          protocolId: protocol.id,
        );
        logs.addAll(protocolLogs);
      }

      final Set<DateTime> uniqueDays = {};
      for (var log in logs) {
        final timestamp = log['timestamp'] as Timestamp?;
        if (timestamp != null) {
          final date = timestamp.toDate();
          uniqueDays.add(DateTime(date.year, date.month, date.day));
        }
      }
      _completedSessionDays = uniqueDays.toList();
    } catch (e) {
      _error = "Erro ao carregar detalhes: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
