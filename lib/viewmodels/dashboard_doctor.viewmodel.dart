import 'package:Ombro_Plus/models/dashboard.data.dart';
import 'package:Ombro_Plus/repositories/dashboard.repository.dart';
import 'package:flutter/material.dart';

class DashboardDoctorViewModel extends ChangeNotifier {
  final DashboardRepository _repository;

  DashboardData? _dashboardData;
  List<Map<String, String>> _patients = [];

  bool _isLoadingData = false;
  bool _isLoadingPatients = false;

  DashboardData? get dashboardData => _dashboardData;
  List<Map<String, String>> get patients => _patients;
  bool get isLoadingData => _isLoadingData;
  bool get isLoadingPatients => _isLoadingPatients;

  DashboardDoctorViewModel({required DashboardRepository repository})
    : _repository = repository;

  Future<void> loadPatientData(String patientId, String specialistId) async {
    _isLoadingData = true;
    notifyListeners();

    _dashboardData = await _repository.fetchActiveProtocolData(
      patientId,
      specialistId: specialistId,
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
