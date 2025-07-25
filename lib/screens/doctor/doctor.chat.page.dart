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

class DoctorChatPage extends StatelessWidget {
  final List<Map<String, dynamic>> messages = [
    {
      'sender': 'especialista',
      'name': 'Dr. João Silva',
      'content': 'Olá, como posso ajudar hoje?',
      'date': DateTime.now().subtract(Duration(hours: 4)),
    },
    {
      'sender': 'paciente',
      'name': 'Maria Oliveira',
      'content': 'Oi Dr. João, estou com uma dor no ombro.',
      'date': DateTime.now().subtract(Duration(days: 3)),
    },
    {
      'sender': 'especialista',
      'name': 'Dr. João Silva',
      'content': 'Entendi, Maria. Pode me contar mais sobre a dor?',
      'date': DateTime.now().subtract(Duration(days: DateTime.now().weekday)),
    },
    {
      'sender': 'paciente',
      'name': 'Maria Oliveira',
      'content': 'É uma dor aguda, especialmente quando movo o braço.',
      'date': DateTime.now().subtract(Duration(days: 15)),
    },
    {
      'sender': 'especialista',
      'name': 'Dr. João Silva',
      'content': 'Certo, vou precisar de alguns exames para entender melhor.',
      'date': DateTime.now().subtract(Duration(minutes: 30)),
    },
    {
      'sender': 'paciente',
      'name': 'Maria Oliveira',
      'content': 'Claro, quais exames você recomenda?',
      'date': DateTime.now().subtract(Duration(days: 6)),
    },
    {
      'sender': 'especialista',
      'name': 'Dr. João Silva',
      'content': 'Um ultrassom e uma ressonância magnética seriam ideais.',
      'date': DateTime.now().subtract(Duration(minutes: 5)),
    },
  ];
  DoctorChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final patientName = args != null && args['name'] != null
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
      final isEspecialista = msg['sender'] == 'especialista';
      chatWidgets.add(
        Align(
          alignment: isEspecialista
              ? Alignment.centerRight
              : Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 6, horizontal: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: isEspecialista
                  ? MainAxisAlignment.start
                  : MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: isEspecialista
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
              backgroundColor: Color(0xFF8FC1A9),
              child: Icon(Icons.person, color: Colors.white),
            ),
            SizedBox(width: 12),
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
          Expanded(child: ChatMessagesList(chatWidgets: chatWidgets)),
          Container(
            color: Colors.grey[100],
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
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
                  onPressed: () {},
                  icon: Icon(Icons.send, color: Color(0xFF2A5C7D)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
