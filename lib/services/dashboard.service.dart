import 'package:Ombro_Plus/models/dashboard.data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class DashboardService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _getTodayKey() {
    return DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  Future<Map<int, double>> fetchWeeklyAdherence(String uid) async {
    if (uid == null) {
      return {};
    }

    final today = DateTime.now();
    final sevenDaysAgo = DateTime(
      today.year,
      today.month,
      today.day,
    ).subtract(const Duration(days: 6));

    final Map<int, double> adherenceByWeekday = {
      for (var i = 1; i <= 7; i++) i: 0.0,
    };

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('logs_exercicios')
          .where('pacienteId', isEqualTo: uid)
          .where('sessaoFinalizada', isEqualTo: true)
          .where(
            'timestamp',
            isGreaterThanOrEqualTo: Timestamp.fromDate(sevenDaysAgo),
          )
          .get();

      for (var doc in snapshot.docs) {
        final logData = doc.data();
        final timestamp = logData['timestamp'] as Timestamp;
        final date = timestamp.toDate();

        final weekday = date.weekday;

        adherenceByWeekday[weekday] = 1.0;
      }

      final Map<int, double> chartData = {};
      for (int i = 1; i <= 7; i++) {
        chartData[i - 1] = adherenceByWeekday[i]!;
      }

      return chartData;
    } catch (e) {
      print('Erro ao buscar adesão semanal: $e');
      return {for (var i = 0; i < 7; i++) i: 0.0};
    }
  }

  Future<DashboardData?> fetchDashboardData(String uid) async {
    if (uid == null) return null;

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('protocolos')
          .where('pacienteId', isEqualTo: uid)
          .where('status', isEqualTo: 'active')
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        return DashboardData();
      }
      final data = snapshot.docs.first.data();

      final totalSessions = data['totalSessoesEstimadas'] as int? ?? 0;
      final sessoesConcluidas = data['sessoesConcluidas'] as int? ?? 0;
      final weeklyAdherence = await fetchWeeklyAdherence(uid);
      return DashboardData(
        protocolData: data,
        totalSessions: totalSessions,
        sessoesConcluidas: sessoesConcluidas,
        weeklyAdherence: weeklyAdherence,
      );
    } catch (e) {
      print('DashboardService: Erro ao carregar dados do dashboard: $e');
      return DashboardData();
    }
  }
}
