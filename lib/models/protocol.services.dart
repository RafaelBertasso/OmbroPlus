import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ProtocolServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static String _getTodayKey() {
    return DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  Future<bool> markSessionCompleted(String protocolId, String patientId) async {
    final todayKey = _getTodayKey();
    final logCollection = _firestore.collection('logs_exercicios');
    final protocolRef = _firestore.collection('protocolos').doc(protocolId);

    final existingLog = await logCollection
        .where('protocoloId', isEqualTo: protocolId)
        .where('pacienteId', isEqualTo: patientId)
        .where('data', isEqualTo: todayKey)
        .where('sessaoFinalizada', isEqualTo: true)
        .limit(1)
        .get();

    if (existingLog.docs.isNotEmpty) {
      print('Sessão para $todayKey já foi marcada como concluída.');
      return false;
    }

    return await _firestore
        .runTransaction((transaction) async {
          transaction.set(logCollection.doc(), {
            'protocoloId': protocolId,
            'pacienteId': patientId,
            'data': todayKey,
            'timestamp': FieldValue.serverTimestamp(),
            'sessaoFinalizada': true,
          });

          transaction.update(protocolRef, {
            'sessoesConcluidas': FieldValue.increment(1),
          });

          return true;
        })
        .then((_) {
          print('Sessão concluída e contador incrementado com sucesso.');
          return true;
        })
        .catchError((error) {
          print('Erro na transação de conclusão da sessão: $error');
          return false;
        });
  }

  Future<Set<String>> fetchCompletedExercisesToday(
    String protocolId,
    String userId,
  ) async {
    final todayKey = _getTodayKey();

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('logs_exercicios')
          .where('protocoloId', isEqualTo: protocolId)
          .where('pacienteId', isEqualTo: userId)
          .where('data', isEqualTo: todayKey)
          .get();

      return snapshot.docs
          .map((doc) => doc.data()['exercicioId'] as String)
          .toSet();
    } catch (e) {
      print('Erro ao buscar logs do exercício: $e');
      return {};
    }
  }

  Future<void> logExerciseCompletion(
    String protocolId,
    String userId,
    String exerciseId,
    bool complete,
  ) async {
    final todayKey = _getTodayKey();
    final logCollection = _firestore.collection('logs_exercicios');

    final existingLog = await logCollection
        .where('protocoloId', isEqualTo: protocolId)
        .where('pacienteId', isEqualTo: userId)
        .where('exercicioId', isEqualTo: exerciseId)
        .where('data', isEqualTo: todayKey)
        .where('concluido', isEqualTo: true)
        .limit(1)
        .get();

    if (complete && existingLog.docs.isEmpty) {
      await logCollection.add({
        'protocoloId': protocolId,
        'pacienteId': userId,
        'exercicioId': exerciseId,
        'data': todayKey,
        'concluido': true,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
  }
}
