import 'package:Ombro_Plus/models/protocol_model.dart';
import 'package:Ombro_Plus/repositories/protocol_repository.dart';
import 'package:flutter/material.dart';

class ProtocolScheduleViewerViewModel extends ChangeNotifier {
  final ProtocolRepository _repository;

  ProtocolModel? _protocol;
  bool _isLoading = true;

  ProtocolModel? get protocol => _protocol;
  bool get isLoading => _isLoading;

  List<ProtocolSession> get sessions => _protocol?.sessoes ?? [];

  Map<int, List<ProtocolSession>> get sessionsByWeek {
    final Map<int, List<ProtocolSession>> map = {};
    for (var session in sessions) {
      map.putIfAbsent(session.semana, () => []).add(session);
    }
    return map;
  }

  List<int> get sortedWeeks {
    final keys = sessionsByWeek.keys.toList();
    keys.sort();
    return keys;
  }

  ProtocolScheduleViewerViewModel({required ProtocolRepository repository})
    : _repository = repository;

  Future<void> loadSchedule(String protocolId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _protocol = await _repository.getProtocolById(protocolId);
    } catch (e) {
      print("{PROT_SCHEDULE_VM} Erro ao carregar cronograma: $e");
    }

    _isLoading = false;
    notifyListeners();
  }
}
