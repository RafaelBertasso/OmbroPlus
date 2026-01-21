import 'package:Ombro_Plus/models/protocol.model.dart';
import 'package:Ombro_Plus/repositories/protocol.repository.dart';
import 'package:flutter/material.dart';

class ProtocolDetailsViewModel extends ChangeNotifier {
  final ProtocolRepository _repository;

  ProtocolModel? _protocol;
  Map<String, dynamic>? _patientData;
  bool _isLoading = true;

  ProtocolDetailsViewModel({required ProtocolRepository repository})
    : _repository = repository;

  ProtocolModel? get protocol => _protocol;
  Map<String, dynamic>? get patientData => _patientData;
  bool get isLoading => _isLoading;

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
      // Força o status para 'finalized'
      await _repository.updateProtocolStatus(_protocol!.id!, 'finalized');

      // Atualiza o objeto localmente
      _protocol = _protocol!.copyWith(status: 'finalized');
    } catch (e) {
      print("Erro ao finalizar: $e");
    }

    _isLoading = false;
    notifyListeners();
  }
}
