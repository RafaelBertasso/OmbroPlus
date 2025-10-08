import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

String getDayLabel(DateTime date, DateTime now) {
  final diff = now.difference(DateTime(date.year, date.month, date.day)).inDays;
  if (diff == 0) return 'Hoje';
  if (diff == 1) return 'Ontem';
  if (diff < 7 &&
      diff > 1 &&
      date.isAfter(now.subtract(Duration(days: now.weekday)))) {
    final weekDays = [
      'segunda-feira',
      'terça-feira',
      'quarta-feira',
      'quinta-feira',
      'sexta-feira',
      'sábado',
      'domingo',
    ];
    return weekDays[date.weekday - 1];
  }
  return DateFormat('dd/MM/yyyy').format(date);
}

class DoctorChatPage extends StatefulWidget {
  const DoctorChatPage({super.key});

  @override
  State<DoctorChatPage> createState() => _DoctorChatPageState();
}

class _DoctorChatPageState extends State<DoctorChatPage> {
  final TextEditingController _controller = TextEditingController();
  String? _patientId;
  String? _roomId;
  String? _currentUserId;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _currentUserId = FirebaseAuth.instance.currentUser?.uid;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_roomId == null) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      _roomId = args?['roomId'] as String?;
      _patientId = args?['id'] as String?;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _roomId == null || _currentUserId == null) return;

    _controller.clear();
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
    final now = FieldValue.serverTimestamp();
    await FirebaseFirestore.instance
        .collection('chats')
        .doc(_roomId)
        .collection('messages')
        .add({'senderId': _currentUserId, 'text': text, 'timestamp': now});

    await FirebaseFirestore.instance.collection('chats').doc(_roomId).update({
      'lastMessage': text,
      'lastMessageTimestamp': now,
    });
  }

  Widget _buildMessageBubble(Map<String, dynamic> msg, bool isMe) {
    final Color messageColor = isMe
        ? const Color(0xFF0E382C)
        : const Color.fromARGB(255, 199, 213, 203);
    final Color textColor = isMe ? Colors.white : Colors.black87;
    final CrossAxisAlignment rowAlignment = isMe
        ? CrossAxisAlignment.end
        : CrossAxisAlignment.start;

    final timestamp = msg['timestamp'] as Timestamp?;
    final timeString = timestamp != null
        ? DateFormat('HH:mm').format(timestamp.toDate())
        : '...';

    return Container(
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.only(bottom: 6),
      child: Column(
        crossAxisAlignment: rowAlignment,
        children: [
          Row(
            mainAxisAlignment: isMe
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isMe)
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: CircleAvatar(
                    radius: 14,
                    backgroundColor: Colors.grey[200],
                    child: const Icon(
                      Icons.person,
                      color: Color(0xFF2A5C7D),
                      size: 18,
                    ),
                  ),
                ),

              Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.75,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: messageColor,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16),
                    topRight: const Radius.circular(16),
                    bottomLeft: isMe
                        ? const Radius.circular(16)
                        : const Radius.circular(4),
                    bottomRight: isMe
                        ? const Radius.circular(4)
                        : const Radius.circular(16),
                  ),
                ),
                child: Text(
                  msg['text'] ?? '',
                  style: GoogleFonts.openSans(color: textColor, fontSize: 15),
                ),
              ),

              if (isMe)
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: CircleAvatar(
                    radius: 14,
                    backgroundColor: const Color(0xFF8FC1A9),
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
            ],
          ),

          Padding(
            padding: EdgeInsets.only(
              top: 4,
              right: isMe ? 20 : 0,
              left: isMe ? 0 : 20,
            ),
            child: Text(
              timeString,
              style: GoogleFonts.openSans(fontSize: 10, color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final patientName = args?['name'] as String? ?? 'Paciente';
    // O roomId já está no estado, mas o null check é importante
    final currentRoomId = _roomId;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Color(0xFFF4F7F6),
        elevation: 0.4,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: const Color(0xFF0E382C),
              child: const Icon(Icons.person, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Text(
              patientName.isNotEmpty ? patientName : 'Nome do Paciente',
              style: GoogleFonts.montserrat(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
          ],
        ),
        automaticallyImplyLeading: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: currentRoomId == null
                ? const Center(
                    child: Text('Erro: Sala de chat não identificada.'),
                  )
                : StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('chats')
                        .doc(currentRoomId)
                        .collection('messages')
                        .orderBy('timestamp', descending: false)
                        .snapshots(),

                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF0E382C),
                          ),
                        );
                      }
                      if (snapshot.hasError) {
                        return const Center(
                          child: Text('Erro ao carregar mensagens.'),
                        );
                      }

                      final documents = snapshot.data!.docs;

                      List<Widget> chatWidgets = [];
                      DateTime? lastDateLabel;

                      for (var doc in documents) {
                        final msg = doc.data() as Map<String, dynamic>;
                        final timestamp = msg['timestamp'] as Timestamp?;
                        final msgDate = timestamp?.toDate() ?? DateTime.now();

                        bool shouldShowLabel =
                            lastDateLabel == null ||
                            !DateUtils.isSameDay(msgDate, lastDateLabel);

                        if (shouldShowLabel) {
                          chatWidgets.add(
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Center(
                                child: Text(
                                  getDayLabel(msgDate, now),
                                  style: GoogleFonts.openSans(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black45,
                                  ),
                                ),
                              ),
                            ),
                          );
                          lastDateLabel = msgDate;
                        }

                        // Adiciona a bolha
                        final isEspecialista =
                            msg['senderId'] == _currentUserId;
                        chatWidgets.add(
                          _buildMessageBubble(msg, isEspecialista),
                        );
                      }

                      return ListView(
                        controller: _scrollController,
                        reverse: true,
                        children: chatWidgets.reversed.toList(),
                      );
                    },
                  ),
          ),

          Container(
            color: Colors.grey[100],
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    textCapitalization: TextCapitalization.sentences,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                    decoration: InputDecoration(
                      hintText: 'Escreva uma mensagem...',
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      fillColor: Color(0xFFF4F7F6),
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 0,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _sendMessage,
                  icon: const Icon(Icons.send, color: Color(0xFF0E382C)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
