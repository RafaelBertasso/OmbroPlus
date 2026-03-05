import 'package:Ombro_Plus/models/protocol_model.dart';
import 'package:Ombro_Plus/repositories/auth_repository.dart';
import 'package:Ombro_Plus/repositories/protocol_repository.dart';
import 'package:flutter/material.dart';

class WeeklySessionData {
  final String protocolId;
  final int currentWeek;
  final List<ProtocolSession> thisWeekSessions;
  final List<String> completedSessionIds;
  final ProtocolSession? nextSession;
  final bool hasCompletedSessionToday;

  WeeklySessionData({
    required this.protocolId,
    required this.currentWeek,
    required this.thisWeekSessions,
    required this.completedSessionIds,
    required this.hasCompletedSessionToday,
    this.nextSession,
  });
}

// Nova classe que agrupa tudo que a tela precisa para CADA protocolo
class ActiveProtocolSummary {
  final ProtocolModel protocol;
  final WeeklySessionData weeklyData;
  final int progressPercent;

  ActiveProtocolSummary({
    required this.protocol,
    required this.weeklyData,
    required this.progressPercent,
  });
}

class PatientHomeViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;
  final ProtocolRepository _protocolRepository;

  // Agora temos uma LISTA de protocolos
  List<ActiveProtocolSummary> _activeProtocols = [];
  bool _isLoading = true;
  String? _error;

  List<ActiveProtocolSummary> get activeProtocols => _activeProtocols;
  bool get isLoading => _isLoading;
  String? get error => _error;

  PatientHomeViewModel({
    required AuthRepository authRepo,
    required ProtocolRepository protoRepo,
  }) : _authRepository = authRepo,
       _protocolRepository = protoRepo;

  Future<void> loadHomeData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final userId = _authRepository.currentUser?.uid;
      if (userId == null) throw Exception("Usuário não logado");

      // 1. Busca TODOS os protocolos ativos do paciente
      final protocols = await _protocolRepository.fetchActiveProtocolsByPatient(
        userId,
      );

      final List<ActiveProtocolSummary> summaries = [];

      // 2. Para cada protocolo, calcula os dados da semana e o progresso
      for (var protocol in protocols) {
        final weeklyData = await _calculateWeeklySessions(protocol, userId);

        if (weeklyData != null) {
          final completed = protocol.sessoesConcluidas;
          final total = protocol.totalSessoesEstimadas;
          final progressPercent = total == 0
              ? 0
              : ((completed / total) * 100).round();

          summaries.add(
            ActiveProtocolSummary(
              protocol: protocol,
              weeklyData: weeklyData,
              progressPercent: progressPercent,
            ),
          );
        }
      }

      _activeProtocols = summaries;
    } catch (e) {
      _error = e.toString();
      print("{HOME_VIEWMODEL}: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<WeeklySessionData?> _calculateWeeklySessions(
    ProtocolModel protocol,
    String userId,
  ) async {
    if (protocol.dataInicio == null || protocol.id == null) return null;

    final now = DateTime.now();
    int currentWeek = 1;

    if (now.isAfter(protocol.dataInicio)) {
      final diffInDays = now.difference(protocol.dataInicio).inDays;
      currentWeek = (diffInDays ~/ 7) + 1;
    }

    final thisWeekSessions = protocol.sessoes
        .where((s) => s.semana == currentWeek)
        .toList();
    final completedIds = await _protocolRepository.fetchCompletedSessionIds(
      protocol.id!,
      userId,
    );
    final hasCompletedToday = await _protocolRepository
        .hasCompletedSessionToday(protocol.id!, userId);

    ProtocolSession? nextSession;
    for (var session in thisWeekSessions) {
      if (!completedIds.contains(session.id)) {
        nextSession = session;
        break;
      }
    }

    return WeeklySessionData(
      protocolId: protocol.id!,
      currentWeek: currentWeek,
      thisWeekSessions: thisWeekSessions,
      completedSessionIds: completedIds.toList(),
      nextSession: nextSession,
      hasCompletedSessionToday: hasCompletedToday,
    );
  }
}
