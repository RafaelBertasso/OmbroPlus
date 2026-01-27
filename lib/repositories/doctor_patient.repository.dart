import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

class DoctorPatientRepository {
  final FirebaseFirestore _firestore;

  DoctorPatientRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> getPatientsBySpecialist(
    String specialistId,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('pacientes')
          .where('especialistaId', isEqualTo: specialistId)
          .orderBy('nome')
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      throw Exception("Erro ao buscar pacientes: $e");
    }
  }

  Future<Map<String, dynamic>?> getPatientDetails(String patientId) async {
    try {
      final doc = await _firestore.collection('pacientes').doc(patientId).get();
      if (doc.exists) {
        final data = doc.data()!;
        data['id'] = doc.id;
        return data;
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
}
