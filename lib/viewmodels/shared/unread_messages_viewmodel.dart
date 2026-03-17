import 'package:Ombro_Plus/models/chat_summary.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class UnreadMessagesViewmodel extends ChangeNotifier {
  ChatSummary _summary = ChatSummary(
    totalUnread: 0,
    lastUnreadMessage: 'Carregando...',
    lastUnreadTime: '',
  );

  bool _isLoading = true;
  bool _isDisposed = false;

  ChatSummary get summary => _summary;
  bool get isLoading => _isLoading;

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  Future<void> fetchSummary() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      _summary = ChatSummary(
        totalUnread: 0,
        lastUnreadMessage: 'Faça login para ver as mensagens.',
        lastUnreadTime: '',
      );
      _isLoading = false;
      if (!_isDisposed) return notifyListeners();
      return;
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('chats')
          .where('participants', arrayContains: uid)
          .orderBy('lastMessageTimestamp', descending: true)
          .get();

      int totalUnread = 0;
      String lastUnreadMessage = 'Nenhuma mensagem nova.';
      Timestamp? lastUnreadTimestamp;

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final unreadMap = data['unreadCount'] as Map<String, dynamic>?;
        final count = unreadMap?[uid] as int? ?? 0;

        totalUnread += count;

        if (count > 0) {
          final timestamp = data['lastMessageTimestamp'] as Timestamp?;
          if (timestamp != null &&
              (lastUnreadTimestamp == null ||
                  timestamp.compareTo(lastUnreadTimestamp) > 0)) {
            lastUnreadMessage = data['lastMessage'] ?? 'Mensagem sem conteúdo';
            lastUnreadTimestamp = timestamp;
          }
        }
      }

      final lastTime = lastUnreadTimestamp != null
          ? DateFormat('HH:mm').format(lastUnreadTimestamp.toDate())
          : '';

      _summary = ChatSummary(
        totalUnread: totalUnread,
        lastUnreadMessage: lastUnreadMessage,
        lastUnreadTime: lastTime,
      );
    } catch (e) {
      print('Erro ao buscar resumo de chats: $e');
      _summary = ChatSummary(
        totalUnread: 0,
        lastUnreadMessage: 'Erro de carregamento.',
        lastUnreadTime: '',
      );
    } finally {
      if (!_isDisposed) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }
}
