import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

// [getDatLabel] e [DateUtils] são mantidos no topo do arquivo.
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

class PatientChatPage extends StatefulWidget {
  const PatientChatPage({super.key});

  @override
  State<PatientChatPage> createState() => _PatientChatPageState();
}

class _PatientChatPageState extends State<PatientChatPage> {
  final TextEditingController _controller = TextEditingController();
  String? _specialistId; // ID do outro usuário (Especialista)
  String? _roomId;
  String? _currentUserId; // ID do Paciente logado (EU)
  final ScrollController _scrollController = ScrollController();

  String? _specialistName;
  String? _patientName; // Nome do paciente logado
  Map<String, String?> _profileImageUrls = {};
  Map<String, String> _userNames = {}; // Armazena nomes de ambos

  @override
  void initState() {
    super.initState();
    _currentUserId = FirebaseAuth.instance.currentUser?.uid; // ID do Paciente
  }

  void _loadChatParticipantsDetails() async {
    if (_specialistId == null || _currentUserId == null) return;

    // 1. Busca detalhes do PACIENTE (EU)
    final patientDoc = await FirebaseFirestore.instance
        .collection('pacientes')
        .doc(_currentUserId)
        .get();
    final patientData = patientDoc.data();
    final patientName = patientData?['nome'] ?? 'Paciente';
    final patientImage = patientData?['profileImage'] as String?;

    // 2. Busca detalhes do ESPECIALISTA (O OUTRO)
    final specialistDoc = await FirebaseFirestore.instance
        .collection('especialistas')
        .doc(_specialistId)
        .get();
    final specialistData = specialistDoc.data();
    final specialistName = specialistData?['nome'] ?? 'Especialista';
    final specialistImage = specialistData?['profileImage'] as String?;

    setState(() {
      _patientName = patientName; // O nome do paciente logado
      _specialistName =
          specialistName; // O nome do especialista (para a AppBar)

      // Mapeia IDs para nomes e fotos
      _userNames[_currentUserId!] = patientName;
      _userNames[_specialistId!] = specialistName;
      _profileImageUrls[_currentUserId!] = patientImage;
      _profileImageUrls[_specialistId!] = specialistImage;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_roomId == null) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      _roomId = args?['roomId'] as String?;
      // O ID passado pela rota é o ID do ESPECIALISTA ('id' na DoctorMainChatPage)
      _specialistId = args?['id'] as String?;
    }

    if (_specialistId != null) {
      _loadChatParticipantsDetails();
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

  // --- FUNÇÕES DE AVATAR (ADAPTADAS PARA PERSPECTIVA DO PACIENTE) ---

  String _getInitialLetter(String? name) {
    if (name == null || name.isEmpty) {
      return '?';
    }
    return name.trim().split(' ').first[0].toUpperCase();
  }

  // Helper para o Avatar nas Bolhas de Mensagem
  Widget _buildAvatar(String userId, bool isMe, String userName) {
    final String? imageBase64 = _profileImageUrls[userId];
    final String initial = _getInitialLetter(userName);

    // INVERSÃO DA LÓGICA DE COR PARA O PACIENTE
    final Color patientColor = const Color(0xFF0E382C); // Paciente (EU)
    final Color specialistColor =
        Colors.grey.shade200; // Especialista (O OUTRO)

    final Color avatarBgColor = isMe ? patientColor : specialistColor;
    final Color initialTextColor = isMe ? Colors.white : patientColor;
    const double radius = 14;

    if (imageBase64 != null && imageBase64.isNotEmpty) {
      try {
        final bytes = base64Decode(imageBase64);

        return Padding(
          padding: EdgeInsets.only(right: isMe ? 0 : 8, left: isMe ? 8 : 0),
          child: CircleAvatar(
            radius: radius,
            backgroundColor: avatarBgColor,
            child: ClipOval(
              child: Image.memory(
                bytes,
                width: radius * 2,
                height: radius * 2,
                fit: BoxFit.cover,
              ),
            ),
          ),
        );
      } catch (e) {
        print('Falha ao decodificar Base64: $e');
      }
    }

    // Fallback: Letra inicial
    return Padding(
      padding: EdgeInsets.only(right: isMe ? 0 : 8, left: isMe ? 8 : 0),
      child: CircleAvatar(
        radius: radius,
        backgroundColor: avatarBgColor,
        child: Text(
          initial,
          style: GoogleFonts.montserrat(
            color: initialTextColor,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // Helper para o Avatar da App Bar (Especialista - O OUTRO)
  Widget _buildAppBarAvatar(String? imageBase64, String? name) {
    const double radius = 18;
    final initial = _getInitialLetter(name);

    if (imageBase64 != null && imageBase64.isNotEmpty) {
      try {
        final bytes = base64Decode(imageBase64);
        return ClipOval(
          child: Image.memory(
            bytes,
            width: radius * 2,
            height: radius * 2,
            fit: BoxFit.cover,
          ),
        );
      } catch (_) {}
    }

    // Fallback: Usa a cor principal do app (verde)
    return Text(
      initial,
      style: GoogleFonts.montserrat(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }
  // -------------------------------------------------------------

  Widget _buildMessageBubble(Map<String, dynamic> msg) {
    final String senderId = msg['senderId'] as String;
    final bool isMe = senderId == _currentUserId; // EU SOU O PACIENTE
    final String senderName =
        _userNames[senderId] ?? (isMe ? 'Eu' : 'Especialista');

    // INVERSÃO DE CORES: Paciente (EU) envia em Verde Escuro
    final Color messageColor = isMe
        ? const Color(0xFF0E382C)
        : const Color.fromARGB(
            255,
            199,
            213,
            203,
          ); // Cor clara para o Especialista

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
              if (!isMe) _buildAvatar(senderId, isMe, senderName),

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
                    // Paciente (Eu) alinha à direita
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

              if (isMe) _buildAvatar(senderId, isMe, senderName),
            ],
          ),

          Padding(
            padding: EdgeInsets.only(
              top: 4,
              // Ajusta o padding para o lado oposto da bolha
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
    final currentRoomId = _roomId;

    // Dados para a App Bar
    final specialistNameForAppBar = _specialistName ?? 'Especialista';
    final specialistImageBase64 = _profileImageUrls[_specialistId];

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color(0xFFF4F7F6),
        elevation: 0.4,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Row(
          children: [
            // Avatar do ESPECIALISTA (O OUTRO)
            CircleAvatar(
              backgroundColor: const Color(0xFF0E382C),
              child: _buildAppBarAvatar(
                specialistImageBase64,
                specialistNameForAppBar,
              ),
            ),
            const SizedBox(width: 12),
            // Nome do Especialista
            Text(
              specialistNameForAppBar.isNotEmpty
                  ? specialistNameForAppBar
                  : 'Nome do Especialista',
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
                        .orderBy(
                          'timestamp',
                          descending: false,
                        ) // Inverte a ordem para facilitar a rolagem
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

                      // Constrói a lista de mensagens (do mais novo para o mais antigo)
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

                        chatWidgets.add(_buildMessageBubble(msg));
                      }

                      // Renderiza a lista do mais antigo para o mais novo (bottom-up)
                      return ListView(
                        controller: _scrollController,
                        reverse:
                            true, // Começa de baixo (mensagens mais recentes)
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        children: chatWidgets.reversed.toList(),
                      );
                    },
                  ),
          ),

          // CAMPO DE INPUT
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
                      fillColor: Colors.white,
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
