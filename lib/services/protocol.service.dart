import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ProtocolServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static String _getTodayKey() {
    return DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  Future<void> _logActivity({
    required String type,
    required String protocolName,
    required String patientId,
    required String patientName,
  }) async {
    String message;

    switch (type) {
      case 'PROTOCOL_FINISHED':
        message = '$patientName concluiu o protocolo: $protocolName.';
        break;
      case 'PROTOCOL_CREATED':
        message = 'Novo protocolo "$protocolName" iniciado para $patientName.';
        break;
      default:
        message = 'Atividade registrada para $patientName.';
    }
    await _firestore.collection('activity_feed').add({
      'type': type,
      'patientId': patientId,
      'patientName': patientName,
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
    });
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
      print('LOG SESSÃO: Sessão para $todayKey já marcada. Abortando.');
      return false;
    }

    bool protocolWasCompleted = false;
    try {
      final bool transactionResult = await _firestore.runTransaction((
        transaction,
      ) async {
        final protocolDoc = await transaction.get(protocolRef);
        if (!protocolDoc.exists) throw Exception('Protocolo não encontrado');

        final data = protocolDoc.data()!;
        final completed = (data['sessoesConcluidas'] as int? ?? 0) + 1;
        final total = data['totalSessoesEstimadas'] as int? ?? 0;

        print(
          'LOG SESSÃO TRANSAÇÃO: Leitura do protocolo concluída. Nova contagem: $completed / $total',
        );

        transaction.set(logCollection.doc(), {
          'protocoloId': protocolId,
          'pacienteId': patientId,
          'data': todayKey,
          'timestamp': FieldValue.serverTimestamp(),
          'sessaoFinalizada': true,
        });
        print(
          'LOG SESSÃO TRANSAÇÃO: Documento de sessão finalizada marcado para gravação.',
        );

        if (data['status'] == 'active') {
          transaction.update(protocolRef, {'sessoesConcluidas': completed});
          print(
            'LOG SESSÃO TRANSAÇÃO: Contador do protocolo marcado para atualização.',
          );
        }

        if (completed >= total && total > 0 && data['status'] == 'active') {
          transaction.update(protocolRef, {'status': 'finished'});
          print(
            'LOG SESSÃO TRANSAÇÃO: Status do protocolo marcado para FINALIZADO.',
          );
          return true;
        }
        return false;
      });

      protocolWasCompleted = transactionResult;
      print(
        'LOG SESSÃO: Transação concluída com SUCESSO. Protocolo finalizado? $protocolWasCompleted',
      );
    } catch (e) {
      print('ProtocolService: ERRO CRÍTICO NA TRANSAÇÃO: $e');
      return false;
    }

    if (protocolWasCompleted) {
      final finalProtocolDoc = await _firestore
          .collection('protocolos')
          .doc(protocolId)
          .get();
      final finalData = finalProtocolDoc.data();

      final protocolName = finalData?['nome'] as String? ?? 'Protocolo';
      final specialistId = finalData?['especialistaId'] as String?;

      final patientDoc = await _firestore
          .collection('pacientes')
          .doc(patientId)
          .get();
      final patientName =
          patientDoc.data()?['nome'] as String? ?? 'Paciente Desconhecido';

      if (specialistId != null) {
        await _logActivity(
          type: 'PROTOCOL_FINISHED',
          protocolName: protocolName,
          patientId: patientId,
          patientName: patientName,
        );
      }
    }

    print(
      'LOG SESSÃO: Processo markSessionCompleted concluído (Retornando TRUE).',
    );
    return true;
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
          .where('concluido', isEqualTo: true)
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
