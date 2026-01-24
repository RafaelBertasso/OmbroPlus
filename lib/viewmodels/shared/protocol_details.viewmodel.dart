import 'package:Ombro_Plus/models/protocol.model.dart';
import 'package:Ombro_Plus/repositories/protocol.repository.dart';
import 'package:flutter/material.dart';

class ProtocolDetailsViewModel extends ChangeNotifier {
  final ProtocolRepository _repository;

  ProtocolModel? _protocol;
  Map<String, dynamic>? _patientData;
  bool _isLoading = true;
  String? _error;

  Set<String> _completedExercises = {};

  ProtocolDetailsViewModel({required ProtocolRepository repository})
    : _repository = repository;

  ProtocolModel? get protocol => _protocol;
  Map<String, dynamic>? get patientData => _patientData;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Set<String> get completedExercises => _completedExercises;

  Future<void> loadProtocolDetails(String protocolId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _protocol = await _repository.getProtocolById(protocolId);

      if (_protocol != null && _protocol!.pacienteId.isNotEmpty) {
        _patientData = await _repository.getPatientData(_protocol!.pacienteId);
      }
    } catch (e) {
      print("{PROTOCOL_DETAILS_VM} Erro ao carregar detalhes: $e");
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> finalizeProtocol() async {
    if (_protocol == null || _protocol!.id == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      await _repository.updateProtocolStatus(_protocol!.id!, 'finalized');

      _protocol = _protocol!.copyWith(status: 'finalized');
    } catch (e) {
      print("Erro ao finalizar: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadProtocolData(String protocolId, String patientId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _protocol = await _repository.getProtocolById(protocolId);

      if (_protocol != null) {
        _completedExercises = await _repository.fetchCompletedExercisesToday(
          protocolId,
          patientId,
        );
      }
    } catch (e) {
      _error = 'Erro ao carregar detalhes: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleExercise(
    String exerciseId,
    String patientId,
    bool value,
  ) async {
    if (_protocol == null) return;

    if (value) {
      _completedExercises.add(exerciseId);
    } else {
      _completedExercises.remove(exerciseId);
    }
    notifyListeners();

    try {
      await _repository.logExerciseCompletion(
        _protocol!.id as String,
        patientId,
        exerciseId,
        value,
      );
    } catch (e) {
      if (value) {
        _completedExercises.remove(exerciseId);
      } else {
        _completedExercises.add(exerciseId);
      }
      _error = "Erro ao salvar progresso";
      notifyListeners();
    }
  }

  Future<bool> finishSession(String patientId, String patientName) async {
    if (_protocol == null) return false;
    _isLoading = true;
    notifyListeners();

    try {
      final success = await _repository.markSessionCompleted(
        _protocol!.id as String,
        patientId,
        patientName,
      );
      return success;
    } catch (e) {
      _error = "Erro ao finalizar sessão: $e";
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
