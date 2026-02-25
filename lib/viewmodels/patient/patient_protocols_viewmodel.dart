import 'package:Ombro_Plus/models/protocol_model.dart';
import 'package:Ombro_Plus/repositories/protocol_repository.dart';
import 'package:flutter/material.dart';

class PatientProtocolsViewModel extends ChangeNotifier {
  final ProtocolRepository repository;

  PatientProtocolsViewModel({required this.repository});

  List<ProtocolModel> _protocols = [];
  bool _isLoading = false;
  String? _error;

  List<ProtocolModel> get protocols => _protocols;
  ProtocolModel? get activeProtocol =>
      _protocols.isNotEmpty ? _protocols.first : null;
  bool get isLoading => _isLoading;
  String? get error => _error;

  double getProgressValue(ProtocolModel protocol) {
    if (protocol.totalSessoesEstimadas == 0) {
      return 0.0;
    }
    return (protocol.sessoesConcluidas / protocol.totalSessoesEstimadas).clamp(
      0.0,
      1.0,
    );
  }

  String getProgressPercentage(ProtocolModel protocol) {
    final val = getProgressValue(protocol);
    return '${(val * 100).round()}%';
  }

  ProtocolSession? getNextSession(ProtocolModel protocol) {
    if (protocol.sessoes.isEmpty) {
      return null;
    }
    final nextIndex = protocol.sessoesConcluidas;
    if (nextIndex >= protocol.sessoes.length) {
      return null; // Todas as sessões concluídas
    }
    return protocol.sessoes[nextIndex];
  }

  Future<void> loadActiveProtocol(String patientId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await repository.fetchActiveProtocolByPatient(patientId);
      _protocols = result != null ? [result] : [];
    } catch (e) {
      _error = 'erro ao carregar protocolo: $e';
      _protocols = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clear() {
    _protocols = [];
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}
