import 'dart:convert';

import 'package:Ombro_Plus/viewmodels/shared/chat_viewmodel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class PatientChatPage extends StatefulWidget {
  const PatientChatPage({super.key});

  @override
  State<PatientChatPage> createState() => _PatientChatPageState();
}

class _PatientChatPageState extends State<PatientChatPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_isInitialized) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      final roomId = args?['roomId'] as String?;
      final targetUserId = args?['id'] as String?; // ID do especialista

      if (roomId != null &&
          targetUserId != null &&
          roomId.isNotEmpty &&
          targetUserId.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.read<ChatViewModel>().initialize(
            roomId: roomId,
            targetUserId: targetUserId,
          );
        });
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Erro: Dados do chat inválidos.")),
          );
          Navigator.pop(context);
        });
      }
      _isInitialized = true;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage(ChatViewModel viewModel) {
    if (_controller.text.trim().isNotEmpty) {
      viewModel.sendMessage(_controller.text.trim());
      _controller.clear();
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    }
  }

  String _getDayLabel(DateTime date, DateTime now) {
    final diff = now
        .difference(DateTime(date.year, date.month, date.day))
        .inDays;
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

  Widget _buildAvatar(
    ChatViewModel viewModel,
    String userId,
    bool isMe,
    String userName,
  ) {
    final String? imageBase64 = viewModel.profileImageUrls[userId];
    final String initial = userName.isNotEmpty
        ? userName[0].toUpperCase()
        : '?';

    final Color patientColor = const Color(0xFF0E382C);
    final Color specialistColor = Colors.grey.shade300;

    final Color avatarBgColor = isMe ? patientColor : specialistColor;
    final Color textColor = isMe ? Colors.white : patientColor;

    if (imageBase64 != null && imageBase64.isNotEmpty) {
      return Padding(
        padding: EdgeInsets.only(right: isMe ? 0 : 8, left: isMe ? 8 : 0),
        child: CircleAvatar(
          radius: 14,
          backgroundColor: avatarBgColor,
          child: ClipOval(
            child: Image.memory(
              base64Decode(imageBase64),
              width: 28,
              height: 28,
              fit: BoxFit.cover,
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.only(right: isMe ? 0 : 8, left: isMe ? 8 : 0),
      child: CircleAvatar(
        radius: 14,
        backgroundColor: avatarBgColor,
        child: Text(
          initial,
          style: GoogleFonts.montserrat(
            color: textColor,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(
    ChatViewModel viewModel,
    Map<String, dynamic> msg,
  ) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final String senderId = msg['senderId'] as String;
    final bool isMe = senderId == currentUserId;
    final String senderName =
        viewModel.userNames[senderId] ?? (isMe ? 'Eu' : 'Especialista');

    final timestamp = msg['timestamp'] as Timestamp?;
    final timeString = timestamp != null
        ? DateFormat('HH:mm').format(timestamp.toDate())
        : '...';

    return Container(
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: isMe
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: isMe
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isMe) _buildAvatar(viewModel, senderId, isMe, senderName),

              Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.75,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isMe
                      ? const Color(0xFF0E382C)
                      : const Color.fromARGB(255, 199, 213, 203),
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
                  style: GoogleFonts.openSans(
                    color: isMe ? Colors.white : Colors.black87,
                    fontSize: 15,
                  ),
                ),
              ),

              if (isMe) _buildAvatar(viewModel, senderId, isMe, senderName),
            ],
          ),

          Padding(
            padding: EdgeInsets.only(
              top: 4,
              right: isMe ? 45 : 0,
              left: isMe ? 0 : 45,
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
    final nameToDisplay = args?['name'] as String? ?? 'Especialista';

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color(0xFFF4F7F6),
        elevation: 0.4,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          nameToDisplay,
          style: GoogleFonts.montserrat(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
      ),
      body: Consumer<ChatViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoadingParticipants) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF0E382C)),
            );
          }

          if (viewModel.errorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Erro: ${viewModel.errorMessage}'),
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: viewModel.getMessagesStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF0E382C),
                        ),
                      );
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Erro ao carregar mensagens: ${snapshot.error}',
                        ),
                      );
                    }

                    final documents = snapshot.data!.docs;
                    List<Widget> chatWidgets = [];
                    DateTime? lastDateLabel;

                    for (var doc in documents) {
                      final msg = doc.data() as Map<String, dynamic>;
                      final msgDate =
                          (msg['timestamp'] as Timestamp?)?.toDate() ??
                          DateTime.now();

                      if (lastDateLabel == null ||
                          !DateUtils.isSameDay(msgDate, lastDateLabel)) {
                        chatWidgets.add(
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Center(
                              child: Text(
                                _getDayLabel(msgDate, now),
                                style: GoogleFonts.openSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        );
                        lastDateLabel = msgDate;
                      }
                      chatWidgets.add(_buildMessageBubble(viewModel, msg));
                    }

                    return ListView(
                      controller: _scrollController,
                      reverse: true,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                      children: chatWidgets.reversed.toList(),
                    );
                  },
                ),
              ),

              // Barra de Input
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        textCapitalization: TextCapitalization.sentences,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _sendMessage(viewModel),
                        decoration: InputDecoration(
                          hintText: 'Escreva uma mensagem...',
                          fillColor: const Color(0xFFF4F7F6),
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 10,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFF0E382C),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.send, color: Colors.white),
                        onPressed: () => _sendMessage(viewModel),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
