import 'package:Ombro_Plus/repositories/protocol_repository.dart';
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
      _isMarkingComplete = false;
      notifyListeners();

      return true;
    } catch (e) {
      _error = 'Erro ao finalizar exercício: $e';
      _isMarkingComplete = false;
      notifyListeners();
      return false;
    }
  }
}
