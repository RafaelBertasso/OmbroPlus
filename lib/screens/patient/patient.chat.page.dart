import 'package:Ombro_Plus/components/chat.messages.list.dart';
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

class PatientChatPage extends StatefulWidget {
  const PatientChatPage({super.key});

  @override
  State<PatientChatPage> createState() => _PatientChatPageState();
}

class _PatientChatPageState extends State<PatientChatPage> {
  final List<Map<String, dynamic>> messages = [];

  final TextEditingController _controller = TextEditingController();

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      messages.add({
        'sender': 'paciente',
        'content': text,
        'date': DateTime.now(),
      });
      _controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final specialistName = args != null && args['name'] != null
        ? args['name'] as String
        : 'Paciente';

    final sortedMessages = List<Map<String, dynamic>>.from(
      messages,
    )..sort((a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime));

    List<Widget> chatWidgets = [];
    DateTime? lastDateLabel;

    for (var msg in sortedMessages) {
      DateTime msgDate = msg['date'] as DateTime;
      bool shouldShowLabel =
          lastDateLabel == null || !DateUtils.isSameDay(msgDate, lastDateLabel);

      if (shouldShowLabel) {
        chatWidgets.add(
          Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
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
      final isPaciente = msg['sender'] == 'paciente';
      chatWidgets.add(
        Align(
          alignment: isPaciente ? Alignment.centerRight : Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 6, horizontal: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: isPaciente
                  ? MainAxisAlignment.start
                  : MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: isPaciente
                  ? [
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 12,
                          ),
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.7,
                          ),
                          decoration: BoxDecoration(
                            color: Color.fromARGB(255, 199, 213, 203),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            msg['content'],
                            style: GoogleFonts.openSans(
                              color: Colors.black87,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: Color(0xFF8FC1A9),
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                    ]
                  : [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.grey[200],
                        child: Icon(Icons.person, color: Color(0xFF2A5C7D)),
                      ),
                      SizedBox(width: 8),
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 12,
                          ),
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.7,
                          ),
                          decoration: BoxDecoration(
                            color: Color.fromARGB(255, 183, 195, 202),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            msg['content'],
                            style: GoogleFonts.openSans(
                              color: Colors.black87,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Color(0xFFF4F7F6),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.4,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Color(0xFF0E382C),
              child: Icon(Icons.person, color: Colors.white),
            ),
            SizedBox(width: 12),
            Text(
              specialistName.isNotEmpty ? specialistName : 'Nome do Especialista',
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
          Expanded(child: ChatMessagesList(chatWidgets: chatWidgets)),
          Container(
            color: Colors.grey[100],
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
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
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 0,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                IconButton(
                  onPressed: _sendMessage,
                  icon: Icon(Icons.send, color: Color(0xFF0E382C)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
