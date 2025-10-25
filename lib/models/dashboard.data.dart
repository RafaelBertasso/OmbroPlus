class DashboardData {
  final Map<String, dynamic>? protocolData;
  final int totalSessions;
  final int sessoesConcluidas;
  final Map<int, double>? weeklyAdherence;

  DashboardData({
    this.protocolData,
    this.totalSessions = 0,
    this.sessoesConcluidas = 0,
    this.weeklyAdherence,
  });
}
