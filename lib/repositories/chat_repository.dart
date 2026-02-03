import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 1. Enviar uma nova mensagem
  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String text,
  }) async {
    final messageData = {
      'senderId': senderId,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false,
    };

    // Adiciona a mensagem na subcoleção
    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add(messageData);

    // Atualiza o documento principal do chat (última mensagem e timestamp)
    await _firestore.collection('chats').doc(chatId).update({
      'lastMessage': text,
      'lastMessageTime': FieldValue.serverTimestamp(),
    });
  }

  // 2. Stream de mensagens de um chat (Tempo Real)
  Stream<QuerySnapshot> getMessagesStream(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // 3. Stream da Lista de Chats do Usuário (Médico ou Paciente)
  // userType pode ser 'specialistId' ou 'patientId'
  Stream<QuerySnapshot> getUserChatsStream(String userId, String userTypeKey) {
    return _firestore
        .collection('chats')
        .where(userTypeKey, isEqualTo: userId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots();
  }

  // 4. Marcar mensagens como lidas
  Future<void> markMessagesAsRead(String chatId, String currentUserId) async {
    final unreadMessages = await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .where('senderId', isNotEqualTo: currentUserId)
        .where('isRead', isEqualTo: false)
        .get();

    final batch = _firestore.batch();
    for (var doc in unreadMessages.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  // 5. Iniciar um novo chat (ou retornar o existente)
  Future<String> getOrCreateChatId(
    String specialistId,
    String patientId,
    String patientName,
    String specialistName,
  ) async {
    List<String> ids = [specialistId, patientId];
    ids.sort();
    final String roomId = ids.join('_');

    // SOLUÇÃO: Usamos uma Query em vez de .get() direto no documento.
    // Isso evita o erro de permissão caso o documento não exista.
    final existingChat = await _firestore
        .collection('chats')
        .where('roomId', isEqualTo: roomId)
        .where('participants', arrayContains: specialistId)
        .limit(1)
        .get();

    // Se a sala não existe (a busca retornou vazia), cria com os dados iniciais
    if (existingChat.docs.isEmpty) {
      await _firestore.collection('chats').doc(roomId).set({
        'roomId': roomId,
        'patientName': patientName,
        'specialistId': specialistId,
        'specialistName': specialistName,
        'participants': [specialistId, patientId],
        'lastMessageTime': FieldValue.serverTimestamp(),
        'lastMessage': '',
      });
    }

    return roomId;
  }
}
