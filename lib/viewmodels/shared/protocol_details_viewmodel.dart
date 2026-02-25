import 'package:Ombro_Plus/models/protocol_model.dart';
import 'package:Ombro_Plus/repositories/protocol_repository.dart';
import 'package:flutter/material.dart';

class ProtocolDetailsViewModel extends ChangeNotifier {
  final ProtocolRepository _repository;

  ProtocolModel? _protocol;
  Map<String, dynamic>? _patientData;
  bool _isLoading = true;
  String? _error;

  // Substituímos os exercícios soltos pelas SESSÕES concluídas
  Set<String> _completedSessionIds = {};

  ProtocolDetailsViewModel({required ProtocolRepository repository})
    : _repository = repository;

  ProtocolModel? get protocol => _protocol;
  Map<String, dynamic>? get patientData => _patientData;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Set<String> get completedSessionIds => _completedSessionIds;

  // Usado pelo Médico
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

  // Usado pelo Paciente na Visão Geral
  Future<void> loadProtocolData(String protocolId, String patientId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _protocol = await _repository.getProtocolById(protocolId);

      if (_protocol != null) {
        // Agora buscamos as sessões finalizadas para pintar os checks na tela
        _completedSessionIds = await _repository.fetchCompletedSessionIds(
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

  Future<void> updateCollaborators(List<String> newCollaborators) async {
    if (_protocol == null || _protocol!.id == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      await _repository.updateProtocolCollaborators(
        _protocol!.id!,
        newCollaborators,
      );
      _protocol = _protocol!.copyWith(
        especialistasColaboradores: newCollaborators,
      );
    } catch (e) {
      _error = 'Erro ao atualizar colaboradores: $e';
      print(_error);
    }

    _isLoading = false;
    notifyListeners();
  }
}
