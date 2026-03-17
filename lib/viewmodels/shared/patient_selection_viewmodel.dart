import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PatientSelectionViewmodel extends ChangeNotifier {
  String _searchText = '';

  String get searchText => _searchText;

  void updateSearch(String value) {
    _searchText = value.toLowerCase();
    notifyListeners();
  }

  Stream<QuerySnapshot> get patientsStream {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return Stream.empty();

    return FirebaseFirestore.instance
        .collection('pacientes')
        .where('especialistaId', isEqualTo: uid)
        .orderBy('nome')
        .snapshots();
  }

  List<QueryDocumentSnapshot> filterPatients(
    List<QueryDocumentSnapshot> allDocs,
  ) {
    if (_searchText.isEmpty) return allDocs;
    return allDocs
        .where(
          (doc) => doc['nome'].toString().toLowerCase().contains(_searchText),
        )
        .toList();
  }
}
