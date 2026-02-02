import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DoctorEditProfileViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLoading = false;
  bool _isSaving = false;
  String? _error;

  String? _specialistId;
  Map<String, dynamic>? _userData;

  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get error => _error;
  Map<String, dynamic>? get userData => _userData;

  Future<void> initialize(String? passedId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _specialistId = passedId ?? _auth.currentUser?.uid;

      if (_specialistId == null) {
        throw Exception("Usuário não identificado.");
      }

      final doc = await _firestore
          .collection('especialistas')
          .doc(_specialistId)
          .get();
      if (doc.exists) {
        _userData = doc.data();
      } else {
        throw Exception("Perfil não encontrado.");
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> saveProfile({
    required String email,
    required String phone,
    required String crefito,
    required String crm,
    required BuildContext context,
  }) async {
    _isSaving = true;
    _error = null;
    notifyListeners();

    try {
      if (_specialistId == null) throw Exception("ID inválido");

      final currentUser = _auth.currentUser;
      final isEditingSelf = currentUser?.uid == _specialistId;

      if (isEditingSelf && currentUser != null && currentUser.email != email) {
        try {
          await currentUser.verifyBeforeUpdateEmail(email);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'E-mail de verificação enviado! Confirme para alterar.',
                ),
              ),
            );
          }
        } catch (e) {
          throw Exception("Erro ao atualizar e-mail: $e");
        }
      }
      await _firestore.collection('especialistas').doc(_specialistId).update({
        'email': email,
        'telefone': phone,
        'crefito': crefito,
        'crm': crm,
      });

      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }
}
