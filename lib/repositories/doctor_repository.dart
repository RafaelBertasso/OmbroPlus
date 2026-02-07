import 'package:Ombro_Plus/models/doctor_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DoctorListRepository {
  final FirebaseFirestore _firestore;

  DoctorListRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<List<DoctorModel>> getAllSpecialists() async {
    try {
      final snapshot = await _firestore
          .collection('especialistas')
          .orderBy('nome')
          .get();

      return snapshot.docs
          .map((doc) => DoctorModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar especialistas: $e');
    }
  }
}
