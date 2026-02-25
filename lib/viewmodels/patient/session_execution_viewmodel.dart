import 'package:Ombro_Plus/repositories/protocol_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SessionExecutionViewmodel extends ChangeNotifier {
  final ProtocolRepository _repository;

  bool _isLoading = false;
  bool _isSessionCompletedLocally = false;
  Set<String> _completedExerciseIds = {};

  bool get isLoading => _isLoading;
  bool get isSessionCompletedLocally => _isSessionCompletedLocally;
  Set<String> get completedExerciseIds => _completedExerciseIds;

  SessionExecutionViewmodel({required ProtocolRepository repository})
    : _repository = repository;

  Future<void> loadCompletedExercises(String protocolId) async {
    try {
      final patientId = FirebaseAuth.instance.currentUser?.uid;
      if (patientId != null) {
        _completedExerciseIds = await _repository.fetchCompletedExercisesToday(
          protocolId,
          patientId,
        );
        notifyListeners();
      }
    } catch (e) {
      print(
        '{SESSION_EXECUTION_VM} Erro ao carregar exercícios concluídos: $e',
      );
    }
  }

  bool canFinishSession(List<dynamic> sessionExercises) {
    if (sessionExercises.isEmpty) return false;

    for (var exercise in sessionExercises) {
      final id = exercise['exercicioId'] as String?;
      if (id == null || !_completedExerciseIds.contains(id)) {
        return false;
      }
    }
    return true;
  }

  Future<bool> finishSession({
    required String protocolId,
    required String sessionId,
    required String sessionName,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final patientId = FirebaseAuth.instance.currentUser?.uid;
      if (patientId == null) throw Exception('Usuário não logado.');

      final patientData = await _repository.getPatientData(patientId);
      final patientName = patientData?['nome'] ?? 'Paciente';

      final success = await _repository.markFlexibleSessionCompleted(
        protocolId: protocolId,
        patientId: patientId,
        patientName: patientName,
        sessionId: sessionId,
        sessionName: sessionName,
      );

      if (success) {
        _isSessionCompletedLocally = true;
      }

      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      print('{SESSION_EXECUTION_VM} Erro ao finalizar sessão: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
