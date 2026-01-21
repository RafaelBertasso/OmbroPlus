import 'package:Ombro_Plus/repositories/auth.repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

enum UserType { doctor, patient, unknown }

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _repository;

  User? _user;
  UserType _userType = UserType.unknown;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  UserType get userType => _userType;
  bool get isLoading => _isLoading;
  String? get error => _error;

  AuthViewModel({required AuthRepository repository})
    : _repository = repository {
    _repository.authStateChanges.listen((user) {
      _user = user;
      if (user != null) {
        _fetchUserType(user.uid);
      } else {
        _userType = UserType.unknown;
      }
      notifyListeners();
    });
  }

  Future<UserType?> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = await _repository.login(email, password);
      if (user != null) {
        await _fetchUserType(user.uid);
        _isLoading = false;
        notifyListeners();
        return _userType;
      }
    } catch (e) {
      _error = 'Email ou senha inválidos.';
    }
    _isLoading = false;
    notifyListeners();
    return null;
  }

  Future<bool> registerPatient({
    required String email,
    required String password,
    required String nome,
    required String phone,
    required String birthDate,
    required int age,
    required String sex,
    required String inviteCode,
    required String specialistId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = await _repository.registerPatient(
        email: email,
        password: password,
        nome: nome,
        phone: phone,
        birthDate: birthDate,
        age: age,
        sex: sex,
        inviteCode: inviteCode,
        specialistId: specialistId,
      );

      if (user != null) {
        _user = user;
        _userType = UserType.patient;
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      _error = e.toString().replaceAll("Exception: ", "");
    }
    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> logout() async {
    await _repository.logout();
    _userType = UserType.unknown;
    notifyListeners();
  }

  Future<void> _fetchUserType(String uid) async {
    final typeStr = await _repository.getUserType(uid);
    if (typeStr == 'doctor' || typeStr == 'especialista') {
      _userType = UserType.doctor;
    } else if (typeStr == 'patient' || typeStr == 'paciente') {
      _userType = UserType.patient;
    } else {
      _userType = UserType.unknown;
    }
    notifyListeners();
  }

  Future<void> resetPassword(String email) async {
    try {
      await _repository.resetPassword(email);
    } catch (_) {}
  }

  Future<String?> checkInviteCode(String code) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final specialistId = await _repository.verifyInviteCode(code);
      _isLoading = false;

      if (specialistId == null) {
        _error = 'Código inválido ou não encontrado.';
      }
      notifyListeners();
      return specialistId;
    } catch (e) {
      _isLoading = false;
      _error = 'Erro de conexão ao verificar código.';
      notifyListeners();
      return null;
    }
  }
}
