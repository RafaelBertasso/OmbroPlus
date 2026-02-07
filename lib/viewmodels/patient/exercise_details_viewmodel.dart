import 'package:Ombro_Plus/repositories/protocol_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ExerciseDetailsViewModel extends ChangeNotifier {
  final ProtocolRepository repository;

  ExerciseDetailsViewModel({required this.repository});

  bool _isLoading = true;
  bool _isMarkingComplete = false;
  String? _error;

  Map<String, dynamic>? _exerciseData;
  bool _isCompletedToday = false;

  bool get isLoading => _isLoading;
  bool get isMarkingComplete => _isMarkingComplete;
  String? get error => _error;
  Map<String, dynamic>? get exerciseData => _exerciseData;
  bool get isCompletedToday => _isCompletedToday;

  Future<void> loadExerciseData(
    String exerciseId,
    String protocolId,
    String patientId,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await repository.getExerciseById(exerciseId);

      if (data == null) {
        _error = 'Exercício não encontrado';
      } else {
        _exerciseData = data;

        final completedSet = await repository.fetchCompletedExercisesToday(
          protocolId,
          patientId,
        );
        _isCompletedToday = completedSet.contains(exerciseId);
      }
    } catch (e) {
      _error = 'Erro ao carregar exercício: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> markAsComplete(
    String protocolId,
    String patientId,
    String exerciseId,
    List<dynamic> allDailyExercises,
  ) async {
    _isMarkingComplete = true;
    notifyListeners();

    try {
      await repository.logExerciseCompletion(
        protocolId,
        patientId,
        exerciseId,
        true,
      );
      _isCompletedToday = true;

      final completedSet = await repository.fetchCompletedExercisesToday(
        protocolId,
        patientId,
      );

      if (completedSet.length >= allDailyExercises.length) {
        String currentPatientName = 'Paciente';
        final user = FirebaseAuth.instance.currentUser;

        if (user?.displayName != null && user!.displayName!.isNotEmpty) {
          currentPatientName = user.displayName!;
        } else {
          final patientData = await repository.getPatientData(patientId);
          if (patientData != null) {
            currentPatientName = patientData['nome'] ?? 'Paciente';
          }
        }

        await repository.markSessionCompleted(
          protocolId,
          patientId,
          currentPatientName,
        );

        _isMarkingComplete = false;
        notifyListeners();
        return true;
      }

      _isMarkingComplete = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Erro ao finalizar sessão: $e';
      _isMarkingComplete = false;
      return false;
    }
  }
}
