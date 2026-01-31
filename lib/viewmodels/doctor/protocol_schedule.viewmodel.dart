import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ProtocolScheduleViewModel extends ChangeNotifier {
  DateTime _selectedDate = DateTime.now();
  List<DateTime> _protocolDays = [];
  Map<String, List<Map<String, dynamic>>> _schedule = {};
  bool _isLoading = false;

  DateTime get selectedDate => _selectedDate;
  List<DateTime> get protocolDays => _protocolDays;
  Map<String, List<Map<String, dynamic>>> get schedule => _schedule;
  bool get isLoading => _isLoading;

  void initialize(
    DateTime start,
    DateTime end,
    Map<String, dynamic>? initialSchedule,
  ) {
    _isLoading = true;
    notifyListeners();

    _protocolDays = _generateDays(start, end);

    final now = DateTime.now();
    _selectedDate = _protocolDays.firstWhere(
      (day) => day.isAfter(now.subtract(const Duration(days: 1))),
      orElse: () => _protocolDays.first,
    );

    if (initialSchedule != null) {
      _schedule = _castSchedule(initialSchedule);
    }

    _isLoading = false;
    notifyListeners();
  }

  void selectDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  void addExercises(Map<String, dynamic> result) {
    final List<String> daysIso = (result['diasIso'] as List).cast<String>();

    final exerciseDetails = {
      'exercicioId': result['exercicioId'],
      'title': result['exercicioNome'],
      'subtitle': '${result['series']} séries x ${result['repeticoes']} reps',
      'series': result['series'],
      'repeticoes': result['repeticoes'],
    };

    for (var dayIso in daysIso) {
      final day = DateTime.parse(dayIso);
      final dateKey = DateFormat('yyyy-MM-dd').format(day);

      _schedule.putIfAbsent(dateKey, () => []).add(Map.from(exerciseDetails));
    }
    notifyListeners();
  }

  void removeExercise(String dateKey, int index) {
    if (_schedule.containsKey(dateKey) && _schedule[dateKey]!.length > index) {
      _schedule[dateKey]!.removeAt(index);
      if (_schedule[dateKey]!.isEmpty) {
        _schedule.remove(dateKey);
      }
      notifyListeners();
    }
  }

  List<DateTime> _generateDays(DateTime start, DateTime end) {
    final days = <DateTime>[];
    final diff = end.difference(start).inDays;
    for (int i = 0; i <= diff; i++) {
      days.add(start.add(Duration(days: i)));
    }
    return days;
  }

  Map<String, List<Map<String, dynamic>>> _castSchedule(
    Map<String, dynamic> raw,
  ) {
    final Map<String, List<Map<String, dynamic>>> result = {};
    raw.forEach((key, value) {
      if (value is List) {
        try {
          result[key] = value.map((e) => Map<String, dynamic>.from(e)).toList();
        } catch (e) {
          print("Erro ao converter dia $key: $e");
        }
      }
    });
    return result;
  }
}
