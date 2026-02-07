import 'package:Ombro_Plus/repositories/chat_repository.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatViewModel extends ChangeNotifier {
  final ChatRepository chatRepository;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _roomId;
  String? _currentUserId;
  String? _targetUserId;

  String? patientName;
  String? specialistName;
  Map<String, String?> profileImageUrls = {};
  Map<String, String> userNames = {};

  bool _isLoadingParticipants = true;
  bool get isLoadingParticipants => _isLoadingParticipants;

  String? errorMessage;

  ChatViewModel({required this.chatRepository});

  Future<void> initialize({
    required String roomId,
    required String targetUserId,
  }) async {
    print("ChatViewModel: Iniciando initialize para sala $roomId");
    _roomId = roomId;
    _targetUserId = targetUserId;
    _currentUserId = FirebaseAuth.instance.currentUser?.uid;
    errorMessage = null;

    if (_currentUserId == null) {
      print("ChatViewModel: Erro - Usuário não logado");
      _isLoadingParticipants = false;
      notifyListeners();
      return;
    }

    _isLoadingParticipants = true;
    notifyListeners();

    try {
      await _loadParticipantsDetails();
      await _markMessagesAsRead();
      print("ChatViewModel: Inicialização concluída com sucesso");
    } catch (e) {
      print("ChatViewModel: ERRO CRÍTICO na inicialização: $e");
      errorMessage = "Erro ao carregar dados: $e";
    } finally {
      _isLoadingParticipants = false;
      notifyListeners();
    }
  }

  Stream<QuerySnapshot> getMessagesStream() {
    return chatRepository.getMessagesStream(_roomId!);
  }

  Future<void> sendMessage(String text) async {
    if (text.isEmpty || _roomId == null || _currentUserId == null) return;

    try {
      await chatRepository.sendMessage(
        chatId: _roomId!,
        senderId: _currentUserId!,
        text: text,
      );

      await _incrementTargetUnreadCount();
    } catch (e) {
      print("Erro ao enviar mensagem: $e");
    }
  }

  Future<void> _markMessagesAsRead() async {
    if (_roomId == null || _currentUserId == null) return;
    try {
      await _firestore.collection('chats').doc(_roomId).update({
        'unreadCount.$_currentUserId': 0,
      });
      await chatRepository.markMessagesAsRead(_roomId!, _currentUserId!);
    } catch (e) {}
  }

  Future<void> _incrementTargetUnreadCount() async {
    if (_roomId == null || _targetUserId == null) return;
    try {
      await _firestore.collection('chats').doc(_roomId).update({
        'unreadCount.$_targetUserId': FieldValue.increment(1),
      });
    } catch (e) {
      print("Aviso: Falha ao incrementar contador: $e");
    }
  }

  Future<void> _loadParticipantsDetails() async {
    print("ChatViewModel: Buscando dados dos participantes...");

    // ✅ DETECTA SE O USUÁRIO LOGADO É PACIENTE OU MÉDICO
    final bool isCurrentUserPatient = await _isUserPatient(_currentUserId!);

    print(
      "ChatViewModel: Usuário atual é ${isCurrentUserPatient ? 'PACIENTE' : 'MÉDICO'}",
    );

    if (isCurrentUserPatient) {
      // ✅ USUÁRIO LOGADO = PACIENTE
      // Busca dados do PACIENTE (usuário atual)
      await _loadPatientData(_currentUserId!);

      // Busca dados do ESPECIALISTA (target)
      await _loadSpecialistData(_targetUserId!);
    } else {
      // ✅ USUÁRIO LOGADO = MÉDICO
      // Busca dados do ESPECIALISTA (usuário atual)
      await _loadSpecialistData(_currentUserId!);

      // Busca dados do PACIENTE (target)
      await _loadPatientData(_targetUserId!);
    }
  }

  Future<bool> _isUserPatient(String userId) async {
    try {
      final patientDoc = await _firestore
          .collection('pacientes')
          .doc(userId)
          .get();
      return patientDoc.exists;
    } catch (e) {
      print("Erro ao verificar tipo de usuário: $e");
      return false;
    }
  }

  Future<void> _loadPatientData(String patientId) async {
    try {
      final patientDoc = await _firestore
          .collection('pacientes')
          .doc(patientId)
          .get();

      if (patientDoc.exists) {
        final data = patientDoc.data();
        patientName = data?['nome'] ?? 'Paciente';
        profileImageUrls[patientId] = data?['profileImage'];
        userNames[patientId] = patientName!;
        print("✅ Dados do paciente carregados: $patientName");
      } else {
        print("⚠️ Doc do paciente $patientId não encontrado");
      }
    } catch (e) {
      print("❌ Erro ao buscar paciente: $e");
    }
  }

  Future<void> _loadSpecialistData(String specialistId) async {
    try {
      final specialistDoc = await _firestore
          .collection('especialistas')
          .doc(specialistId)
          .get();

      if (specialistDoc.exists) {
        final data = specialistDoc.data();
        specialistName = data?['nome'] ?? 'Especialista';
        profileImageUrls[specialistId] = data?['profileImage'];
        userNames[specialistId] = specialistName!;
        print("✅ Dados do especialista carregados: $specialistName");
      } else {
        print("⚠️ Doc do especialista $specialistId não encontrado");
      }
    } catch (e) {
      print("❌ Erro ao buscar especialista: $e");
    }
  }
}
