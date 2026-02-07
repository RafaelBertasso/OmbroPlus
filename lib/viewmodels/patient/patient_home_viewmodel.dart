import 'package:Ombro_Plus/models/daily_exercise_data.dart';
import 'package:Ombro_Plus/models/dashboard_data.dart';
import 'package:Ombro_Plus/repositories/auth_repository.dart';
import 'package:Ombro_Plus/repositories/dashboard_repository.dart';
import 'package:Ombro_Plus/repositories/protocol_repository.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PatientHomeViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;
  final DashboardRepository _dashboardRepository;
  final ProtocolRepository _protocolRepository;

  DashboardData? _dashboardData;
  DailyExerciseData? _dailyExerciseData;

  bool _isLoading = true;
  String? _error;

  DashboardData? get dashboardData => _dashboardData;
  DailyExerciseData? get dailyExerciseData => _dailyExerciseData;
  bool get isLoading => _isLoading;
  String? get error => _error;

  PatientHomeViewModel({
    required AuthRepository authRepo,
    required DashboardRepository dashRepo,
    required ProtocolRepository protoRepo,
  }) : _authRepository = authRepo,
       _dashboardRepository = dashRepo,
       _protocolRepository = protoRepo;

  Future<void> loadHomeData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final userId = _authRepository.currentUser?.uid;
      if (userId == null) throw Exception("Usuário não logado");

      _dashboardData = await _dashboardRepository.fetchActiveProtocolData(
        userId,
      );

      if (_dashboardData?.protocol != null) {
        _dailyExerciseData = await _filterExercisesForToday(
          _dashboardData!.protocol,
          userId,
        );
      } else {
        _dailyExerciseData = null;
      }
    } catch (e) {
      _error = e.toString();
      print("{HOME_VIEWMODEL}: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<DailyExerciseData?> _filterExercisesForToday(
    protocol,
    String userId,
  ) async {
    final todayKey = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final schedule = protocol.schedule;

    if (schedule == null || !schedule.containsKey(todayKey)) {
      return null;
    }
    final List<Map<String, dynamic>> dailyExercises =
        List<Map<String, dynamic>>.from(schedule[todayKey] as List);

    final completedIds = await _protocolRepository.fetchCompletedExercisesToday(
      protocol.id!,
      userId,
    );
    return DailyExerciseData(
      protocolId: protocol.id!,
      exercises: dailyExercises,
      completedExerciseIds: completedIds,
    );
  }
}
