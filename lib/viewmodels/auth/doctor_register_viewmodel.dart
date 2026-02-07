import 'package:Ombro_Plus/repositories/auth_repository.dart';
import 'package:flutter/material.dart';

class DoctorRegisterViewModel extends ChangeNotifier {
  final AuthRepository authRepository;

  DoctorRegisterViewModel({required this.authRepository});

  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<bool> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    String? crefito,
    String? crm,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await authRepository.registerSpecialist(
        email: email,
        password: password,
        name: name,
        phone: phone,
        crefito: crefito,
        crm: crm,
      );
      return true;
    } catch (e) {
      if (e.toString().contains('email-already-in-use')) {
        _error = 'Este e-mail já está cadastrado.';
      } else if (e.toString().contains('weak-password')) {
        _error = 'A senha é muito fraca.';
      } else {
        _error = 'Erro ao cadastrar: $e';
      }
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
