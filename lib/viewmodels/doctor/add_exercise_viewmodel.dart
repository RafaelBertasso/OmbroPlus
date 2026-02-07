import 'package:Ombro_Plus/models/exercise_model.dart';
import 'package:Ombro_Plus/repositories/protocol_repository.dart';
import 'package:flutter/material.dart';

class AddExerciseViewModel extends ChangeNotifier {
  final ProtocolRepository repository;

  AddExerciseViewModel({required this.repository});

  List<ExerciseModel> _allExercises = [];
  ExerciseModel? _selectedExercise;

  String _series = '';
  String _repetitions = '';
  final Map<String, bool> _selectedDays = {};

  bool _isLoading = false;
  String? _error;

  List<ExerciseModel> get allExercises => _allExercises;
  ExerciseModel? get selectedExercise => _selectedExercise;
  Map<String, bool> get selectedDays => _selectedDays;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> initialize(List<String> protocolDays) async {
    _isLoading = true;
    notifyListeners();

    try {
      _allExercises = await repository.getAllExercisses();

      for (var day in protocolDays) {
        _selectedDays[day] = false;
      }
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

  void toggleDay(String dayIso, bool? value) {
    if (dayIso.isNotEmpty) {
      _selectedDays[dayIso] = value ?? false;
      notifyListeners();
    }
  }

  void toggleSelectAll() {
    final allSelected = _selectedDays.values.every((v) => v);
    final newState = !allSelected;
    _selectedDays.updateAll((key, value) => newState);
    notifyListeners();
  }

  Map<String, dynamic>? saveEntry(String series, String reps) {
    if (_selectedExercise == null) return null;
    if (series.isEmpty || reps.isEmpty) return null;

    final daysToSchedule = _selectedDays.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();

    if (daysToSchedule.isEmpty) return null;

    return {
      'exercicioId': _selectedExercise!.id,
      'exercicioNome': _selectedExercise!.nome,
      'series': int.tryParse(series) ?? 0,
      'repeticoes': int.tryParse(reps) ?? 0,
      'diasIso': daysToSchedule,
      'youtubeId': _selectedExercise!.youtubeId,
    };
  }

  Future<void> refreshExercises() async {
    _allExercises = await repository.getAllExercisses();
    notifyListeners();
  }
}
