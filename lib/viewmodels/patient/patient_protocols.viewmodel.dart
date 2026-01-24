import 'package:Ombro_Plus/models/protocol.model.dart';
import 'package:Ombro_Plus/repositories/protocol.repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PatientProtocolsViewModel extends ChangeNotifier {
  final ProtocolRepository repository;

  PatientProtocolsViewModel({required this.repository});

  ProtocolModel? _activeProtocol;
  bool _isLoading = false;
  String? _error;

  ProtocolModel? get activeProtocol => _activeProtocol;
  bool get isLoading => _isLoading;
  String? get error => _error;

  double get progressValue {
    if (_activeProtocol == null ||
        _activeProtocol!.totalSessoesEstimadas == 0) {
      return 0.0;
    }
    return (_activeProtocol!.sessoesConcluidas /
            _activeProtocol!.totalSessoesEstimadas)
        .clamp(0.0, 1.0);
  }

  String get progressPercentage {
    return '${(progressValue * 100).round()}%';
  }

  Set<int> get scheduledWeekdays {
    if (_activeProtocol == null || _activeProtocol!.schedule.isEmpty) return {};

    Set<int> days = {};

    _activeProtocol!.schedule.keys.forEach((dateString) {
      try {
        final date = DateTime.parse(dateString);
        days.add(date.weekday);
      } catch (e) {
        try {
          final parts = dateString.split('/');
          if (parts.length == 3) {
            final date = DateTime(
              int.parse(parts[2]),
              int.parse(parts[1]),
              int.parse(parts[0]),
            );
            days.add(date.weekday);
          }
        } catch (_) {}
      }
    });
    return days;
  }

  Future<void> loadActiveProtocol(String patientId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final currentUser = FirebaseAuth.instance.currentUser;

    try {
      _activeProtocol = await repository.fetchActiveProtocolByPatient(
        patientId,
      );
    } catch (e) {
      _error = 'erro ao carregar protocolo: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clear() {
    _activeProtocol = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}
