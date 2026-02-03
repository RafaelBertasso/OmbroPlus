import 'package:Ombro_Plus/repositories/chat_repository.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatViewModel extends ChangeNotifier {
  final ChatRepository chatRepository;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _roomId;
  String? _currentUserId;
  String? _targetUserId; // O ID da outra pessoa na conversa

  // Dados dos participantes para renderizar a UI
  String? patientName;
  String? specialistName;
  Map<String, String?> profileImageUrls = {};
  Map<String, String> userNames = {};

  bool _isLoadingParticipants = true;
  bool get isLoadingParticipants => _isLoadingParticipants;

  ChatViewModel({required this.chatRepository});

  Future<void> initialize({
    required String roomId,
    required String targetUserId,
  }) async {
    _roomId = roomId;
    _targetUserId = targetUserId;
    _currentUserId = FirebaseAuth.instance.currentUser?.uid;

    if (_currentUserId == null) return;

    _isLoadingParticipants = true;
    notifyListeners();

    await _loadParticipantsDetails();
    await _markMessagesAsRead();

    _isLoadingParticipants = false;
    notifyListeners();
  }

  Stream<QuerySnapshot> getMessagesStream() {
    return chatRepository.getMessagesStream(_roomId!);
  }

  Future<void> sendMessage(String text) async {
    if (text.isEmpty || _roomId == null || _currentUserId == null) return;

    await chatRepository.sendMessage(
      chatId: _roomId!,
      senderId: _currentUserId!,
      text: text,
    );

    await _incrementTargetUnreadCount();
  }

  Future<void> _markMessagesAsRead() async {
    // Zera o contador na sala de chat
    await _firestore.collection('chats').doc(_roomId).update({
      'unreadCount.$_currentUserId': 0,
    });
    // E chama o repositório para marcar as mensagens individuais como lidas (se aplicável)
    await chatRepository.markMessagesAsRead(_roomId!, _currentUserId!);
  }

  Future<void> _incrementTargetUnreadCount() async {
    await _firestore.collection('chats').doc(_roomId).update({
      'unreadCount.$_targetUserId': FieldValue.increment(1),
    });
  }

  Future<void> _loadParticipantsDetails() async {
    // Dependendo de quem está logado, o "target" é o médico ou o paciente.
    // Aqui fazemos uma busca flexível.
    final patientDoc = await _firestore
        .collection('pacientes')
        .doc(_targetUserId)
        .get();
    final specialistDoc = await _firestore
        .collection('especialistas')
        .doc(_currentUserId)
        .get();

    // Lógica para quando o Médico está usando (target = paciente)
    if (patientDoc.exists) {
      patientName = patientDoc.data()?['nome'] ?? 'Paciente';
      specialistName = specialistDoc.data()?['nome'] ?? 'Eu';
      profileImageUrls[_targetUserId!] = patientDoc.data()?['profileImage'];
      profileImageUrls[_currentUserId!] = specialistDoc.data()?['profileImage'];

      userNames[_targetUserId!] = patientName!;
      userNames[_currentUserId!] = specialistName!;
    }
    // (A lógica reversa pode ser ajustada quando for a vez do paciente)
  }
}
