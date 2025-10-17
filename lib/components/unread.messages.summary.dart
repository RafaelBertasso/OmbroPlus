import 'package:Ombro_Plus/models/chat.summary.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class UnreadMessagesSummary extends StatelessWidget {
  final currentUserId = FirebaseAuth.instance.currentUser?.uid;
  UnreadMessagesSummary({super.key});

  Future<ChatSummary> _fetchSummary() async {
    final uid = currentUserId;
    if (uid == null) {
      return ChatSummary(
        totalUnread: 0,
        lastUnreadMessage: 'Faça login para ver as mensagens.',
        lastUnreadTime: '',
      );
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
        if (count > 0 &&
            (lastUnreadTimestamp == null ||
                (data['lastMessageTimestamp'] as Timestamp).compareTo(
                      lastUnreadTimestamp,
                    ) >
                    0)) {
          lastUnreadMessage = data['lastMessage'] ?? 'Mensagem sem counteúdo';
          lastUnreadTimestamp = data['lastMessageTimestamp'] as Timestamp;
        }
      }
      final lastTime = lastUnreadTimestamp != null
          ? DateFormat('HH:mm').format(lastUnreadTimestamp.toDate())
          : '';

      return ChatSummary(
        totalUnread: totalUnread,
        lastUnreadMessage: lastUnreadMessage,
        lastUnreadTime: lastTime,
      );
    } catch (e) {
      print('Erro ao buscar resumo de chats: $e');
      return ChatSummary(
        totalUnread: 0,
        lastUnreadMessage: 'Erro de carregamento.',
        lastUnreadTime: '',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ChatSummary>(
      future: _fetchSummary(),
      builder: (context, snapshot) {
        final summary =
            snapshot.data ??
            ChatSummary(
              totalUnread: 0,
              lastUnreadMessage: 'Nenhuma mensagem nova.',
              lastUnreadTime: '',
            );
        return InkWell(
          onTap: () =>
              Navigator.pushReplacementNamed(context, '/patient-main-chat'),
          child: Container(
            color: Color(0xFFF4F7F6),
            padding: EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mensagens',
                        style: GoogleFonts.montserrat(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 5),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              summary.lastUnreadMessage,
                              style: GoogleFonts.montserrat(
                                fontSize: 12,
                                color: Colors.grey[700],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (summary.lastUnreadTime.isNotEmpty)
                            Text(
                              " · ${summary.lastUnreadTime}",
                              style: GoogleFonts.montserrat(
                                fontSize: 12,
                                color: Colors.grey[700],
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                Stack(
                  children: [
                    Icon(
                      Icons.chat_bubble_outline,
                      color: Colors.red,
                      size: 28,
                    ),
                    if (summary.totalUnread > 0)
                      Positioned(
                        right: -1,
                        top: -1,
                        child: Container(
                          padding: EdgeInsets.all(1),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.white, width: 1.5),
                          ),
                          constraints: BoxConstraints(
                            minWidth: 18,
                            minHeight: 18,
                          ),
                          child: Center(
                            child: Text(
                              summary.totalUnread > 99
                                  ? '99+'
                                  : summary.totalUnread.toString(),
                              style: GoogleFonts.openSans(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
