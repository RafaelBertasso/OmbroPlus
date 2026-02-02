import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PatientEditProfileViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLoading = false;
  bool _isSaving = false;
  String? _error;

  String? _patientId;
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
      _patientId = passedId ?? _auth.currentUser?.uid;

      if (_patientId == null) {
        throw Exception("Usuário não indentificado.");
      }

      final doc = await _firestore
          .collection('pacientes')
          .doc(_patientId)
          .get();
      if (doc.exists) {
        _userData = doc.data();
      } else {
        throw Exception('Perfil não encontrado.');
      }
    } catch (e) {
      _error = e.toString().replaceAll("Exception: ", "");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> saveProfile({
    required String name,
    required String email,
    required String phone,
    required BuildContext context,
  }) async {
    _isSaving = true;
    _error = null;
    notifyListeners();

    try {
      if (_patientId == null) throw Exception("ID inválido");

      final currentUser = _auth.currentUser;
      final isEditingSelf = currentUser?.uid == _patientId;

      if (isEditingSelf && currentUser != null && currentUser.email != email) {
        try {
          await currentUser.verifyBeforeUpdateEmail(email);
          if (context.mounted) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (ctx) => AlertDialog(
                title: const Text('Verificação necessária'),
                content: const Text(
                  'Um link foi enviado para o novo e-mail. Acesse sua caixa de entrada e complete a alteração.',
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.pop(context, true);
                    },
                    child: const Text(
                      'OK',
                      style: TextStyle(color: Color(0xFF0E382C)),
                    ),
                  ),
                ],
              ),
            );
          }
          _isSaving = false;
          notifyListeners();
          return false;
        } catch (e) {
          throw Exception("Erro ao atualizar e-mail: $e");
        }
      }

      await _firestore.collection('pacientes').doc(_patientId).update({
        'email': email,
        'telefone': phone,
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
