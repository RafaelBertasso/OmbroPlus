import 'package:Ombro_Plus/models/dashboard_data.dart';
import 'package:Ombro_Plus/models/protocol_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardRepository {
  final FirebaseFirestore _firestore;

  DashboardRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<DashboardData?> fetchActiveProtocolData(
    String patientId, {
    String? specialistId,
  }) async {
    try {
      Query query = _firestore
          .collection('protocolos')
          .where('pacienteId', isEqualTo: patientId)
          .where('status', isEqualTo: 'active')
          .limit(1);
      if (specialistId != null) {
        query = query.where('especialistaId', isEqualTo: specialistId);
      }

      final snapshot = await query.get();

      if (snapshot.docs.isEmpty) return null;

      final dataMap = snapshot.docs.first.data() as Map<String, dynamic>;
      final docId = snapshot.docs.first.id;

      final protocolModel = ProtocolModel.fromMap(dataMap, docId);

      final weeklyAdherence = await _fetchWeeklyAdherence(patientId);

      return DashboardData(
        protocol: protocolModel,
        totalSessions: protocolModel.totalSessoesEstimadas,
        sessoesConcluidas: protocolModel.sessoesConcluidas,
        weeklyAdherence: weeklyAdherence,
      );
    } catch (e) {
      print('{DASHBOARD.REPOSITORY} Erro na busca de dados: $e');
      return null;
    }
  }

  Future<List<Map<String, String>>> fetchSpecialistPatients(
    String specialistId,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('protocolos')
          .where('especialistaId', isEqualTo: specialistId)
          .where('status', isEqualTo: 'active')
          .get();

      if (snapshot.docs.isEmpty) return [];

      final patientIds = snapshot.docs
          .map((doc) => doc.data()['pacienteId'] as String)
          .toSet()
          .toList();

      if (patientIds.isEmpty) return [];

      final List<Map<String, String>> patientList = [];

      for (String id in patientIds) {
        final userDoc = await _firestore.collection('pacientes').doc(id).get();
        if (userDoc.exists) {
          patientList.add({
            'id': id,
            'nome': userDoc.data()?['nome'] as String? ?? 'Desconhecido',
          });
        }
      }
      return patientList;
    } catch (e) {
      return [];
    }
  }

  Future<Map<int, double>> _fetchWeeklyAdherence(String patientId) async {
    final today = DateTime.now();
    final sevenDaysAgo = today.subtract(const Duration(days: 6));
    final startOfPeriod = DateTime(
      sevenDaysAgo.year,
      sevenDaysAgo.month,
      sevenDaysAgo.day,
    );

    try {
      final snapshot = await _firestore
          .collection('logs_exercicios')
          .where('pacienteId', isEqualTo: patientId)
          .where('sessaoFinalizada', isEqualTo: true)
          .where(
            'timestamp',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfPeriod),
          )
          .get();

      final Map<int, double> adherence = {for (var i = 1; i <= 7; i++) i: 0.0};

      for (var doc in snapshot.docs) {
        final ts = doc.data()['timestamp'] as Timestamp;
        final date = ts.toDate();
        adherence[date.weekday] = 1.0;
      }

      final Map<int, double> chartData = {};
      for (int i = 1; i <= 7; i++) {
        chartData[i - 1] = adherence[i]!;
      }
      return chartData;
    } catch (e) {
      return {};
    }
  }

  Stream<QuerySnapshot> getActivityFeedStream() {
    final DateTime sevenDaysAgo = DateTime.now().subtract(
      const Duration(days: 7),
    );
    final DateTime cutoffDate = DateTime(
      sevenDaysAgo.year,
      sevenDaysAgo.month,
      sevenDaysAgo.day,
    );
    final Timestamp cutoffTimestamp = Timestamp.fromDate(cutoffDate);

    return _firestore
        .collection('activity_feed')
        .where('timestamp', isGreaterThanOrEqualTo: cutoffTimestamp)
        .orderBy('timestamp', descending: true)
        .limit(10)
        .snapshots();
  }
}
