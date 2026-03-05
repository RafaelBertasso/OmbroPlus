import 'package:Ombro_Plus/models/dashboard_data.dart';
import 'package:Ombro_Plus/repositories/dashboard_repository.dart';
import 'package:flutter/material.dart';

class DashboardPatientViewModel extends ChangeNotifier {
  final DashboardRepository _repository;

  DashboardData? _data;
  List<Map<String, String>> _protocols = [];
  String? _selectedProtocolId;
  bool _isLoading = true;

  DashboardData? get data => _data;
  List<Map<String, String>> get protocols => _protocols;
  String? get selectedProtocolId => _selectedProtocolId;
  bool get isLoading => _isLoading;

  DashboardPatientViewModel({required DashboardRepository repository})
    : _repository = repository;

  Future<void> loadData(String patientId) async {
    _isLoading = true;
    notifyListeners();

    _protocols = await _repository.fetchActiveProtocolsList(patientId);
    if (_protocols.isNotEmpty) {
      _selectedProtocolId = _protocols.first['id'];
      _data = await _repository.fetchActiveProtocolData(
        patientId,
        protocolId: _selectedProtocolId,
      );
    } else {
      _selectedProtocolId = null;
      _data = null;
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> selectProtocol(String patientId, String protocolId) async {
    if (_selectedProtocolId == protocolId) return;

    _isLoading = true;
    _selectedProtocolId = protocolId;
    notifyListeners();

    _data = await _repository.fetchActiveProtocolData(
      patientId,
      protocolId: protocolId,
    );
    _isLoading = false;
    notifyListeners();
  }
}
