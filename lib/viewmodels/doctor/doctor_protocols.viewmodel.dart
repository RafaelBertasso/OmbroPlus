import 'package:Ombro_Plus/models/protocol.model.dart';
import 'package:Ombro_Plus/repositories/protocol.repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DoctorProtocolsViewModel extends ChangeNotifier {
  final ProtocolRepository _repository;

  List<ProtocolModel> _allProtocols = [];
  String _currentFilter = 'all';
  bool _isLoading = false;

  DoctorProtocolsViewModel({required ProtocolRepository repository})
    : _repository = repository;

  bool get isLoading => _isLoading;
  String get currentFilter => _currentFilter;

  List<ProtocolModel> get protocols {
    if (_currentFilter == 'all') return _allProtocols;
    return _allProtocols.where((p) => p.status == _currentFilter).toList();
  }

  Future<void> loadProtocols() async {
    _isLoading = true;
    notifyListeners();

    final specialistId = FirebaseAuth.instance.currentUser?.uid;
    if (specialistId != null) {
      _allProtocols = await _repository.fetchProtocolsBySpecialist(
        specialistId,
      );
    }

    _isLoading = false;
    notifyListeners();
  }

  void setFilter(String filter) {
    _currentFilter = filter;
    notifyListeners();
  }

  Future<bool> deleteProtocol(String protocolId) async {
    try {
      await _repository.deleteProtocol(protocolId);

      _allProtocols.removeWhere((p) => p.id == protocolId);
      notifyListeners();
      return true;
    } catch (e) {
      print("{DOCTOR_PROTOCOLS_VM} Erro ao deletar: $e");
      return false;
    }
  }
}
