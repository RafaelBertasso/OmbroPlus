import 'dart:convert';
import 'dart:io';

import 'package:Ombro_Plus/repositories/auth_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';

class DoctorProfileViewModel extends ChangeNotifier {
  final AuthRepository authRepository;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  DoctorProfileViewModel({required this.authRepository});

  Map<String, dynamic>? _userData;
  String? _profileImage;
  bool _isLoading = false;
  String? _error;

  Map<String, dynamic>? get userData => _userData;
  String? get profileImage => _profileImage;
  bool get isLoading => _isLoading;
  String? get error => _error;
  User? get currentUser => authRepository.currentUser;

  Future<void> loadProfile() async {
    final user = authRepository.currentUser;
    if (user == null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final doc = await _firestore
          .collection('especialistas')
          .doc(user.uid)
          .get();
      _userData = doc.data();
      if (_userData != null) {
        _profileImage = _userData!['profileImage'];
      }
    } catch (e) {
      _error = 'Erro ao carregar perfil: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> pickAndUploadImage(ImageSource source) async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);

    if (image != null) {
      _isLoading = true;
      notifyListeners();

      try {
        List<int>? compressedBytes;
        if (Platform.isAndroid || Platform.isIOS) {
          compressedBytes = await FlutterImageCompress.compressWithFile(
            image.path,
            minHeight: 600,
            minWidth: 400,
            quality: 50,
          );
        } else {
          compressedBytes = await image.readAsBytes();
        }

        if (compressedBytes != null) {
          final base64Image = base64Encode(compressedBytes);
          final uid = authRepository.currentUser!.uid;

          await _firestore.collection('especialistas').doc(uid).update({
            'profileImage': base64Image,
          });

          _profileImage = base64Image;
        }
      } catch (e) {
        _error = "Erro ao atualizar foto: $e";
      } finally {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> logout() async {
    await authRepository.logout();
  }

  Future<bool> deleteAccount(String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await authRepository.deleteAccount(password);
      return true;
    } catch (e) {
      _error = e.toString().replaceAll("Exception: ", "");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
