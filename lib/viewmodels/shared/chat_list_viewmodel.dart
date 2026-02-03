import 'package:Ombro_Plus/repositories/chat_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatListViewmodel extends ChangeNotifier {
  final ChatRepository chatRepository;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _searchText = '';
  final Map<String, String?> _profileImageCache = {};

  ChatListViewmodel({required this.chatRepository});

  String get searchText => _searchText;

  void setSearchText(String value) {
    _searchText = value;
    notifyListeners();
  }

  Stream<QuerySnapshot> getChatsStream(String userTypeKey) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return const Stream.empty();

    return chatRepository.getUserChatsStream(userId, userTypeKey);
  }

  Future<String?> getPatientProfileImage(String patientId) async {
    if (_profileImageCache.containsKey(patientId)) {
      return _profileImageCache[patientId];
    }
    try {
      final doc = await _firestore.collection('pacientes').doc(patientId).get();
      final imageBase64 = doc.data()?['profileImage'] as String?;
      _profileImageCache[patientId] = imageBase64;
      return imageBase64;
    } catch (e) {
      return null;
    }
  }

  String getInitialLetter(String? name) {
    if (name == null || name.isEmpty) return '?';
    return name.trim().split(' ').first[0].toUpperCase();
  }
}
