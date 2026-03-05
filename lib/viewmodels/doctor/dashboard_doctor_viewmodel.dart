import 'package:Ombro_Plus/models/dashboard_data.dart';
import 'package:Ombro_Plus/repositories/dashboard_repository.dart';
import 'package:flutter/material.dart';

class DashboardDoctorViewModel extends ChangeNotifier {
  final DashboardRepository _repository;

  DashboardData? _dashboardData;
  List<Map<String, String>> _patients = [];

  // Novas variáveis para o controle de protocolos
  List<Map<String, String>> _activeProtocols = [];
  String? _selectedProtocolId;

  bool _isLoadingData = false;
  bool _isLoadingPatients = false;

  DashboardData? get dashboardData => _dashboardData;
  List<Map<String, String>> get patients => _patients;
  List<Map<String, String>> get activeProtocols => _activeProtocols;
  String? get selectedProtocolId => _selectedProtocolId;

  bool get isLoadingData => _isLoadingData;
  bool get isLoadingPatients => _isLoadingPatients;

  DashboardDoctorViewModel({required DashboardRepository repository})
    : _repository = repository;

  Future<void> loadPatientData(String patientId, String specialistId) async {
    _isLoadingData = true;
    _selectedProtocolId = null;
    _activeProtocols = [];
    notifyListeners();

    // 1. Busca os protocolos ativos DESTE paciente associados a ESTE médico
    _activeProtocols = await _repository.fetchActiveProtocolsList(
      patientId,
      specialistId: specialistId,
    );

    // 2. Se existir, auto-seleciona o primeiro
    if (_activeProtocols.isNotEmpty) {
      _selectedProtocolId = _activeProtocols.first['id'];
      _dashboardData = await _repository.fetchActiveProtocolData(
        patientId,
        specialistId: specialistId,
        protocolId: _selectedProtocolId,
      );
    } else {
      _dashboardData = null;
    }

    _isLoadingData = false;
    notifyListeners();
  }

  Future<void> selectProtocol(
    String patientId,
    String specialistId,
    String protocolId,
  ) async {
    if (_selectedProtocolId == protocolId) return;

    _isLoadingData = true;
    _selectedProtocolId = protocolId;
    notifyListeners();

    _dashboardData = await _repository.fetchActiveProtocolData(
      patientId,
      specialistId: specialistId,
      protocolId: protocolId,
    );

    _isLoadingData = false;
    notifyListeners();
  }

  Future<void> loadMyPatients(String specialistId) async {
    _isLoadingPatients = true;
    notifyListeners();

    _patients = await _repository.fetchSpecialistPatients(specialistId);

    _isLoadingPatients = false;
    notifyListeners();
  }
}
