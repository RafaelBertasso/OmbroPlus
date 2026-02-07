import 'package:Ombro_Plus/repositories/auth_repository.dart';
import 'package:Ombro_Plus/repositories/dashboard_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DoctorHomeViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;
  final DashboardRepository _dashboardRepository;

  String _doctorName = '...';
  String get doctorName => _doctorName;

  DoctorHomeViewModel({
    required AuthRepository authRepository,
    required DashboardRepository dashboardRepository,
  }) : _authRepository = authRepository,
       _dashboardRepository = dashboardRepository;

  Future<void> loadDoctorName() async {
    final user = _authRepository.currentUser;
    if (user != null) {
      _doctorName = await _authRepository.getUserName(user.uid, 'doctor');
      notifyListeners();
    }
  }

  Stream<QuerySnapshot> get activityFeedStream =>
      _dashboardRepository.getActivityFeedStream();
}
