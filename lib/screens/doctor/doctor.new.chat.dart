import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PatientSelectionForChatPage extends StatefulWidget {
  const PatientSelectionForChatPage({super.key});

  @override
  State<PatientSelectionForChatPage> createState() =>
      _PatientSelectionForChatPageState();
}

class _PatientSelectionForChatPageState
    extends State<PatientSelectionForChatPage> {
  String searchText = '';
  String? _specialistId;

  @override
  void initState() {
    super.initState();
    _specialistId = FirebaseAuth.instance.currentUser?.uid;
  }

  Future<void> _startChat(String patientId, String patientName) async {
    final currentSpecialistId = _specialistId;
    if (currentSpecialistId == null) return;

    List<String> ids = [currentSpecialistId, patientId];
    ids.sort();
    final String roomId = ids.join('_');
    final chatRef = FirebaseFirestore.instance.collection('chats').doc(roomId);

    await chatRef.set({
      'roomId': roomId,
      'patientName': patientName,
      'specialistId': currentSpecialistId,
      'participants': FieldValue.arrayUnion([currentSpecialistId, patientId]),
      'lastMessageTimestamp': FieldValue.serverTimestamp(),
      'lastMessage': '',
    }, SetOptions(merge: true));

    Navigator.pop(context);
    Navigator.pushNamed(
      context,
      '/chat-detail',
      arguments: {'roomId': roomId, 'name': patientName, 'id': patientId},
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentSpecialistId = _specialistId;
    return Scaffold(
      backgroundColor: Color(0xFFF4F7F6),
      appBar: AppBar(
        backgroundColor: Color(0xFFF4F7F6),
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Novo Chat',
          style: GoogleFonts.montserrat(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Pesquisar pacientes',
                prefixIcon: Icon(Icons.search, color: Color(0xFF0E382C)),
                filled: true,
                fillColor: Color(0xFFF4F7F6),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchText = value;
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: currentSpecialistId == null
                  ? null
                  : FirebaseFirestore.instance
                        .collection('pacientes')
                        .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(color: Color(0xFF0E382C)),
                  );
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Erro ao carregar pacientes'));
                }

                final allPatients = snapshot.data?.docs ?? [];
                final filteredPatients = allPatients.where((doc) {
                  final name = (doc['nome'] ?? '').toString().toLowerCase();
                  final query = searchText.toLowerCase();
                  return name.contains(query);
                }).toList();

                if (filteredPatients.isEmpty) {
                  return Center(
                    child: Text(
                      searchText.isEmpty
                          ? 'Você não possui pacientes cadastrados.'
                          : 'Nenhum paciente encontrado',
                      style: GoogleFonts.openSans(color: Colors.black54),
                    ),
                  );
                }
                return ListView.separated(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredPatients.length,
                  separatorBuilder: (_, __) => SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final patient = filteredPatients[index];
                    final patientName = patient['nome'] ?? 'Paciente Sem Nome';
                    final patientId = patient.id;
                    final initialLetter = patientName.isNotEmpty
                        ? patientName[0].toUpperCase()
                        : '?';

                    return Card(
                      color: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Color(0xFF0E382C),
                          child: Text(
                            initialLetter,
                            style: GoogleFonts.montserrat(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          patientName,
                          style: GoogleFonts.montserrat(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        onTap: () => _startChat(patientId, patientName),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
