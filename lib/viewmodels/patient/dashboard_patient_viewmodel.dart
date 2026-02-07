import 'package:Ombro_Plus/models/dashboard_data.dart';
import 'package:Ombro_Plus/repositories/dashboard_repository.dart';
import 'package:flutter/material.dart';

class DashboardPatientViewModel extends ChangeNotifier {
  final DashboardRepository _repository;

  DashboardData? _data;
  bool _isLoading = true;

  DashboardData? get data => _data;
  bool get isLoading => _isLoading;

  DashboardPatientViewModel({required DashboardRepository repository})
    : _repository = repository;

  Future<void> loadData(String patientId) async {
    _isLoading = true;
    notifyListeners();

    _data = await _repository.fetchActiveProtocolData(patientId);

    _isLoading = false;
    notifyListeners();
  }
}
