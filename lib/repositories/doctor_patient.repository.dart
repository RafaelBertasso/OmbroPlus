import 'dart:math';

import 'package:Ombro_Plus/models/patient.model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DoctorPatientRepository {
  final FirebaseFirestore _firestore;

  DoctorPatientRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<List<PatientModel>> getPatientsBySpecialist(
    String specialistId,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('pacientes')
          .where('especialistaId', isEqualTo: specialistId)
          .orderBy('nome')
          .get();

      return snapshot.docs
          .map((doc) => PatientModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print("Erro repo listagem: $e");
      try {
        final snapshot = await _firestore
            .collection('pacientes')
            .where('especialistaId', isEqualTo: specialistId)
            .get();
        return snapshot.docs
            .map((doc) => PatientModel.fromMap(doc.data(), doc.id))
            .toList();
      } catch (e2) {
        throw Exception("Erro ao buscar pacientes: $e2");
      }
    }
  }

  Future<PatientModel?> getPatientDetails(String patientId) async {
    try {
      final doc = await _firestore.collection('pacientes').doc(patientId).get();
      if (doc.exists) {
        return PatientModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      print("{DOCTOR_PATIENT_REPO} Erro ao buscar detalhes do paciente: $e");
      return null;
    }
  }

  Future<bool> linkPatientByEmail(
    String specialistId,
    String patientEmail,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection('pacientes')
          .where('email', isEqualTo: patientEmail)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return false;
      }

      final patientDoc = querySnapshot.docs.first;
      await patientDoc.reference.update({
        'especialistaId': specialistId,
        'vinculadoEm': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      throw Exception('Erro ao vincular paciente: $e');
    }
  }

  String _generateRandomCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890';
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(
        6,
        (_) => chars.codeUnitAt(random.nextInt(chars.length)),
      ),
    );
  }

  Future<String> getOrGenerateInviteCode(String specialistId) async {
    try {
      final specialistRef = _firestore
          .collection('especialistas')
          .doc(specialistId);
      final publicCodeRef = _firestore.collection('invite_codes_public');

      final specialistDoc = await specialistRef.get();
      String? currentCode = specialistDoc.data()?['invite_code'] as String?;

      String finalCode = currentCode ?? _generateRandomCode();

      final publicDoc = await publicCodeRef.doc(finalCode).get();

      if (!publicDoc.exists) {
        await specialistRef.set({
          'invite_code': finalCode,
        }, SetOptions(merge: true));

        await publicCodeRef.doc(finalCode).set({
          'specialistId': specialistId,
          'criadoEm': FieldValue.serverTimestamp(),
        });
      }
      return finalCode;
    } catch (e) {
      throw Exception("Erro ao gerenciar código de convite: $e");
    }
  }

  Future<List<Map<String, dynamic>>> getPatientExerciseLogs(
    String patientId, {
    String? protocolId,
  }) async {
    try {
      Query query = await _firestore
          .collection('logs_exercicios')
          .where('pacienteId', isEqualTo: patientId);

      if (protocolId != null) {
        query = query.where('protocoloId', isEqualTo: protocolId);
      }
      final snapshot = await query.orderBy('timestamp', descending: true).get();

      return snapshot.docs
          .map((d) => d.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      print("Erro ao buscar logs: $e");
      return [];
    }
  }
}
