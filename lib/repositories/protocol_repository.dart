import 'package:Ombro_Plus/models/exercise_model.dart';
import 'package:Ombro_Plus/models/protocol_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProtocolRepository {
  final FirebaseFirestore _firestore;
  ProtocolRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> createProtocol(
    ProtocolModel protocol,
    String patientName,
  ) async {
    final batch = _firestore.batch();

    final protocolRef = _firestore.collection('protocolos').doc();

    final data = protocol.toMap();
    batch.set(protocolRef, data);

    final patientRef = _firestore
        .collection('pacientes')
        .doc(protocol.pacienteId);
    batch.update(patientRef, {'protocoloAtivoId': protocolRef.id});

    final activityRef = _firestore.collection('activity_feed').doc();
    batch.set(activityRef, {
      'type': 'PROTOCOL_CREATED',
      'patientName': patientName,
      'message': 'Protocolo ${protocol.nome} criado para $patientName.',
      'timestamp': FieldValue.serverTimestamp(),
      'patientId': protocol.pacienteId,
    });
    await batch.commit();
  }

  Future<bool> markSessionCompleted(
    String protocolId,
    String patientId,
    String patientName,
  ) async {
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
      return false;
    }

    try {
      final bool transactionResult = await _firestore.runTransaction((
        transaction,
      ) async {
        final protocolDoc = await transaction.get(protocolRef);
        if (!protocolDoc.exists) throw Exception('Protocolo não encontrado');

        final data = protocolDoc.data()!;
        final completed = (data['sessoesConcluidas'] as int? ?? 0) + 1;
        final total = data['totalSessoesEstimadas'] as int? ?? 0;
        final currentStatus = data['status'] as String? ?? 'active';

        final newLogRef = logCollection.doc();
        transaction.set(newLogRef, {
          'protocoloId': protocolId,
          'pacienteId': patientId,
          'data': todayKey,
          'timestamp': FieldValue.serverTimestamp(),
          'sessaoFinalizada': true,
        });

        if (currentStatus == 'active') {
          transaction.update(protocolRef, {'sessoesConcluidas': completed});

          if (completed >= total && total > 0) {
            transaction.update(protocolRef, {'status': 'finished'});
            return true;
          }
        }
        return false;
      });

      if (transactionResult) {
        await _logActivity(
          type: 'PROTOCOL_FINISHED',
          patientId: patientId,
          patientName: patientName,
          message: '$patientName concluiu o protocolo.',
        );
      }
      return true;
    } catch (e) {
      print('{PROTOCOL.REPOSITORY} Erro na transação de sessão: $e');
      return false;
    }
  }

  Future<Set<String>> fetchCompletedExercisesToday(
    String protocolId,
    String patientId,
  ) async {
    final todayKey = _getTodayKey();
    try {
      final snapshot = await _firestore
          .collection('logs_exercicios')
          .where('protocoloId', isEqualTo: protocolId)
          .where('pacienteId', isEqualTo: patientId)
          .where('data', isEqualTo: todayKey)
          .where('concluido', isEqualTo: true)
          .get();

      return snapshot.docs
          .map((doc) => doc.data()['exercicioId'] as String)
          .toSet();
    } catch (e) {
      return {};
    }
  }

  Future<void> logExerciseCompletion(
    String protocolId,
    String patientId,
    String exerciseId,
    bool complete,
  ) async {
    if (!complete) return;

    final todayKey = _getTodayKey();
    final logCollection = _firestore.collection('logs_exercicios');

    final existing = await logCollection
        .where('protocoloId', isEqualTo: protocolId)
        .where('pacienteId', isEqualTo: patientId)
        .where('exercicioId', isEqualTo: exerciseId)
        .where('data', isEqualTo: todayKey)
        .limit(1)
        .get();

    if (existing.docs.isEmpty) {
      await logCollection.add({
        'protocoloId': protocolId,
        'pacienteId': patientId,
        'exercicioId': exerciseId,
        'data': todayKey,
        'concluido': true,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
  }

  String _getTodayKey() {
    final now = DateTime.now();
    return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }

  Future<void> _logActivity({
    required String type,
    required String patientId,
    required String patientName,
    required String message,
  }) async {
    await _firestore.collection('activity_feed').add({
      'type': type,
      'patientId': patientId,
      'patientName': patientName,
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<List<ProtocolModel>> fetchProtocolsBySpecialist(
    String specialistId,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('protocolos')
          .where('especialistaId', isEqualTo: specialistId)
          .orderBy('criadoEm', descending: true)
          .get();

      List<ProtocolModel> loadedProtocols = [];

      for (var doc in snapshot.docs) {
        ProtocolModel protocol = ProtocolModel.fromMap(doc.data(), doc.id);

        if (protocol.pacienteName == 'Paciente' &&
            protocol.pacienteId.isNotEmpty) {
          try {
            final patientDoc = await _firestore
                .collection('pacientes')
                .doc(protocol.pacienteId)
                .get();

            if (patientDoc.exists) {
              final realName =
                  patientDoc.data()?['nome'] as String? ?? 'Paciente';
              protocol = protocol.copyWith(pacienteName: realName);
              doc.reference.update({'pacienteName': realName});
            }
          } catch (e) {
            print("Erro ao recuperar nome do paciente antigo: $e");
          }
        }
        loadedProtocols.add(protocol);
      }
      return loadedProtocols;
    } catch (e) {
      print("{PROTOCOL_REPOSITORY} Erro ao buscar protocolos: $e");
      return [];
    }
  }

  Future<void> deleteProtocol(String protocolId) async {
    try {
      await _firestore.collection('protocolos').doc(protocolId).delete();
    } catch (e) {
      throw Exception('Erro ao excluir protocolo: $e');
    }
  }

  Future<ProtocolModel?> getProtocolById(String protocolId) async {
    try {
      final doc = await _firestore
          .collection('protocolos')
          .doc(protocolId)
          .get();
      if (doc.exists) {
        return ProtocolModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      print("{PROTOCOL_REPOSITORY} Erro ao buscar protocolo: $e");
      return null;
    }
  }

  Future<Map<String, dynamic>?> getPatientData(String patientId) async {
    try {
      final doc = await _firestore.collection('pacientes').doc(patientId).get();
      return doc.data();
    } catch (e) {
      return null;
    }
  }

  Future<void> updateProtocolStatus(String protocolId, String newValue) async {
    try {
      await _firestore.collection('protocolos').doc(protocolId).update(({
        'status': newValue,
      }));
    } catch (e) {
      throw Exception('Erro ao atualizar status: $e');
    }
  }

  Future<ProtocolModel?> fetchActiveProtocolByPatient(String patientId) async {
    try {
      final snapshot = await _firestore
          .collection('protocolos')
          .where('pacienteId', isEqualTo: patientId)
          .where('status', isEqualTo: 'active')
          .limit(1)
          .get();
      if (snapshot.docs.isEmpty) return null;

      final doc = snapshot.docs.first;
      return ProtocolModel.fromMap(doc.data(), doc.id);
    } catch (e) {
      print("{PROTOCOL_REPOSITORY} Erro ao buscar protocolo ativo: $e");
      return null;
    }
  }

  Future<Map<String, dynamic>?> getExerciseById(String id) async {
    try {
      final doc = await _firestore.collection('exercicios').doc(id).get();
      return doc.data();
    } catch (e) {
      print("{PROTOCOL_REPO} Erro ao pegar exercício: $e");
      return null;
    }
  }

  Future<List<ExerciseModel>> getAllExercisses() async {
    try {
      final snapshot = await _firestore
          .collection('exercicios')
          .orderBy('nome')
          .get();
      return snapshot.docs
          .map((doc) => ExerciseModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print("Erro ao buscar exercícios: $e");
      return [];
    }
  }

  Future<void> createExercise({
    required String nome,
    required String descricao,
    String? youtubeId,
  }) async {
    try {
      await _firestore.collection('exercicios').add({
        'nome': nome,
        'descricao': descricao,
        'youtubeId': youtubeId,
        'criadoEm': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Erro ao salvar exercício: $e');
    }
  }
}
