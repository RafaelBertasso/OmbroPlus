import 'package:Ombro_Plus/models/protocol_model.dart';

class DashboardData {
  final ProtocolModel? protocol;
  final int totalSessions;
  final int sessoesConcluidas;
  final Map<int, double>? weeklyAdherence;

  DashboardData({
    this.protocol,
    this.totalSessions = 0,
    this.sessoesConcluidas = 0,
    this.weeklyAdherence,
  });
}
