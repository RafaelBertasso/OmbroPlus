import 'package:Ombro_Plus/models/exercise_model.dart';
import 'package:Ombro_Plus/repositories/protocol_repository.dart';
import 'package:flutter/material.dart';

class AddExerciseViewModel extends ChangeNotifier {
  final ProtocolRepository repository;

  AddExerciseViewModel({required this.repository});

  List<ExerciseModel> _allExercises = [];
  ExerciseModel? _selectedExercise;

  bool _isLoading = false;
  String? _error;

  List<ExerciseModel> get allExercises => _allExercises;
  ExerciseModel? get selectedExercise => _selectedExercise;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      _allExercises = await repository.getAllExercisses();
    } catch (e) {
      _error = 'Erro ao carregar exercícios: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectExercise(ExerciseModel? exercise) {
    _selectedExercise = exercise;
    notifyListeners();
  }

  Map<String, dynamic>? saveEntry(String series, String reps) {
    if (_selectedExercise == null) return null;
    if (series.isEmpty || reps.isEmpty) return null;

    // Retorna o objeto simplificado para a Sessão
    return {
      'exercicioId': _selectedExercise!.id,
      'title': _selectedExercise!
          .nome, // Mudado para 'title' para padronizar com a UI
      'exercicioNome': _selectedExercise!.nome, // Mantido por compatibilidade
      'series': int.tryParse(series) ?? 0,
      'repeticoes': int.tryParse(reps) ?? 0,
      'youtubeId': _selectedExercise!.youtubeId,
      'subtitle': '${series}x$reps', // Helper para visualização rápida
    };
  }

  Future<void> refreshExercises() async {
    _allExercises = await repository.getAllExercisses();
    notifyListeners();
  }
}
