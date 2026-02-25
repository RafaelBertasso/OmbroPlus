import 'package:Ombro_Plus/models/protocol_model.dart';
import 'package:flutter/material.dart';

class ProtocolScheduleViewModel extends ChangeNotifier {
  List<ProtocolSession> _sessions = [];

  // Variável para armazenar o limite máximo de semanas
  int _maxWeeks = 999;

  List<ProtocolSession> get sessions => _sessions;
  int get maxWeeks => _maxWeeks; // Getter para a view consultar, se quiser

  Map<int, List<ProtocolSession>> get sessionsByWeek {
    final map = <int, List<ProtocolSession>>{};
    for (var session in _sessions) {
      if (!map.containsKey(session.semana)) {
        map[session.semana] = [];
      }
      map[session.semana]!.add(session);
    }
    return map;
  }

  // O init agora recebe o maxWeeks calculado lá na tela de NewProtocolPage
  void init(List<ProtocolSession> initialSessions, int maxWeeksLimit) {
    _maxWeeks = maxWeeksLimit;

    _sessions = initialSessions
        .map(
          (s) => ProtocolSession(
            id: s.id,
            semana: s.semana,
            name: s.name,
            exercises: s.exercises
                .map((e) => Map<String, dynamic>.from(e))
                .toList(),
          ),
        )
        .toList();
  }

  // Alterado para retornar bool.
  // Retorna true se adicionou, false se bateu no limite.
  bool addWeek() {
    final currentWeeks = sessionsByWeek.keys.toList();
    final nextWeek = currentWeeks.isEmpty
        ? 1
        : currentWeeks.reduce((a, b) => a > b ? a : b) + 1;

    // A trava de segurança!
    if (nextWeek > _maxWeeks) {
      return false; // Não deixa adicionar
    }

    _sessions.add(
      ProtocolSession(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        semana: nextWeek,
        name: 'Sessão 1',
        exercises: [],
      ),
    );

    notifyListeners();
    return true;
  }

  void addSessionToWeek(int week) {
    final sessionsInThisWeek = _sessions.where((s) => s.semana == week).length;
    _sessions.add(
      ProtocolSession(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        semana: week,
        name: 'Sessão ${sessionsInThisWeek + 1}',
        exercises: [],
      ),
    );
    notifyListeners();
  }

  void removeSession(String sessionId) {
    final index = _sessions.indexWhere((s) => s.id == sessionId);
    if (index == -1) return;

    final week = _sessions[index].semana;

    _sessions.removeAt(index);

    // Reordena o nome das sessões para não ficar "Sessão 1", "Sessão 3"...
    int sessionCounter = 1;
    for (int i = 0; i < _sessions.length; i++) {
      if (_sessions[i].semana == week) {
        final current = _sessions[i];

        if (current.name.startsWith('Sessão')) {
          _sessions[i] = ProtocolSession(
            id: current.id,
            semana: current.semana,
            name: 'Sessão $sessionCounter',
            exercises: current.exercises,
          );
        }
        sessionCounter++;
      }
    }

    notifyListeners();
  }

  void removeWeek(int week) {
    _sessions.removeWhere((s) => s.semana == week);

    // Se remover a semana 2, a semana 3 passa a ser a 2, a 4 passa a ser a 3...
    for (int i = 0; i < _sessions.length; i++) {
      if (_sessions[i].semana > week) {
        final current = _sessions[i];

        _sessions[i] = ProtocolSession(
          id: current.id,
          semana: current.semana - 1,
          name: current.name,
          exercises: current.exercises,
        );
      }
    }
    notifyListeners();
  }

  void renameSession(String sessionId, String newName) {
    final index = _sessions.indexWhere((s) => s.id == sessionId);
    if (index != -1) {
      final current = _sessions[index];
      _sessions[index] = ProtocolSession(
        id: current.id,
        semana: current.semana,
        name: newName,
        exercises: current.exercises,
      );
      notifyListeners();
    }
  }

  void addExerciseToSession(String sessionId, Map<String, dynamic> exercise) {
    final index = _sessions.indexWhere((s) => s.id == sessionId);
    if (index != -1) {
      final currentSession = _sessions[index];
      final newExercises = List<Map<String, dynamic>>.from(
        currentSession.exercises,
      )..add(exercise);

      _sessions[index] = ProtocolSession(
        id: currentSession.id,
        semana: currentSession.semana,
        name: currentSession.name,
        exercises: newExercises,
      );
      notifyListeners();
    }
  }

  void removeExerciseFromSession(String sessionId, int exerciseIndex) {
    final index = _sessions.indexWhere((s) => s.id == sessionId);
    if (index != -1) {
      final currentSession = _sessions[index];
      final newExercises = List<Map<String, dynamic>>.from(
        currentSession.exercises,
      );

      if (exerciseIndex >= 0 && exerciseIndex < newExercises.length) {
        newExercises.removeAt(exerciseIndex);
        _sessions[index] = ProtocolSession(
          id: currentSession.id,
          semana: currentSession.semana,
          name: currentSession.name,
          exercises: newExercises,
        );
        notifyListeners();
      }
    }
  }
}
