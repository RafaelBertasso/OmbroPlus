import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String text,
  }) async {
    final messageData = {
      'senderId': senderId,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
    };

    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add(messageData);

    // ✅ CORREÇÃO: Usar 'lastMessageTimestamp'
    await _firestore.collection('chats').doc(chatId).update({
      'lastMessage': text,
      'lastMessageTimestamp': FieldValue.serverTimestamp(), // ✅ MUDANÇA AQUI
    });
  }

  // 2. Stream de mensagens de um chat (Tempo Real)
  Stream<QuerySnapshot> getMessagesStream(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  Stream<QuerySnapshot> getUserChatsStream(String userId, String userTypeKey) {
    return _firestore
        .collection('chats')
        .where(userTypeKey, isEqualTo: userId)
        .orderBy(
          'lastMessageTimestamp',
          descending: true,
        ) // ✅ Garantir consistência
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

  Future<String> getOrCreateChatId(
    String specialistId,
    String patientId,
    String patientName,
    String specialistName,
  ) async {
    print("🔵 getOrCreateChatId chamado"); // ✅ LOG
    print("   specialistId: $specialistId"); // ✅ LOG
    print("   patientId: $patientId"); // ✅ LOG

    List<String> ids = [specialistId, patientId];
    ids.sort();
    final String roomId = ids.join('_');
    print("🟢 RoomId gerado: $roomId"); // ✅ LOG

    final chatDocRef = _firestore.collection('chats').doc(roomId);

    try {
      print("🔵 Verificando se chat existe..."); // ✅ LOG
      final docSnapshot = await chatDocRef.get();

      if (docSnapshot.exists) {
        print("🟢 Chat já existe!"); // ✅ LOG
        final data = docSnapshot.data() as Map<String, dynamic>;

        if (data['participants'] == null ||
            (data['participants'] as List).isEmpty) {
          print("🟡 Atualizando participants..."); // ✅ LOG
          await chatDocRef.update({
            'participants': FieldValue.arrayUnion([specialistId, patientId]),
          });
        }

        return roomId;
      }
    } catch (e) {
      print("🟡 Chat não encontrado ou erro: $e"); // ✅ LOG
    }

    // Criação do documento
    print("🔵 Criando novo chat..."); // ✅ LOG

    await chatDocRef.set({
      'roomId': roomId,
      'patientName': patientName,
      'specialistId': specialistId,
      'specialistName': specialistName,
      'participants': FieldValue.arrayUnion([specialistId, patientId]),
      'lastMessageTimestamp': FieldValue.serverTimestamp(),
      'lastMessage': '',
      'unreadCount': {specialistId: 0, patientId: 0},
    }, SetOptions(merge: true));

    print("🟢 Chat criado com sucesso!"); // ✅ LOG

    return roomId;
  }
}
