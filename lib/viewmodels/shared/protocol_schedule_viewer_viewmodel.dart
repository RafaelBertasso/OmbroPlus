import 'package:Ombro_Plus/models/protocol_model.dart';
import 'package:Ombro_Plus/repositories/protocol_repository.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ProtocolScheduleViewerViewModel extends ChangeNotifier {
  final ProtocolRepository _repository;

  ProtocolModel? _protocol;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = true;

  ProtocolModel? get protocol => _protocol;
  DateTime get selectedDate => _selectedDate;
  bool get isLoading => _isLoading;

  List<Map<String, dynamic>> get exercisesForSelectedDate {
    if (_protocol == null) return [];

    final dateKey = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final schedule = _protocol!.schedule;

    if (schedule.containsKey(dateKey)) {
      return schedule[dateKey]!;
    }
    return [];
  }

  ProtocolScheduleViewerViewModel({required ProtocolRepository repository})
    : _repository = repository;

  Future<void> loadSchedule(String protocolId, DateTime initialDate) async {
    _isLoading = true;
    _selectedDate = initialDate;
    notifyListeners();

    try {
      _protocol = await _repository.getProtocolById(protocolId);
    } catch (e) {
      print("{PROT_SCHEDULE_VM} Erro ao carregar cronograma: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  void selectDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }
}
