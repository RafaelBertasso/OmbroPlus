import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PatientSelectionModal extends StatefulWidget {
  final ScrollController scrollController;
  final Function(String id, String name) onPatientSelected;

  const PatientSelectionModal({
    super.key,
    required this.scrollController,
    required this.onPatientSelected,
  });

  @override
  State<PatientSelectionModal> createState() => _PatientSelectionModalState();
}

class _PatientSelectionModalState extends State<PatientSelectionModal> {
  String searchText = '';
  String? _specialistId;

  @override
  void initState() {
    super.initState();
    _specialistId = FirebaseAuth.instance.currentUser?.uid;
  }

  @override
  Widget build(BuildContext context) {
    final currentSpecialistId = _specialistId;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Selecione o Paciente',
              style: GoogleFonts.montserrat(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0E382C),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar paciente por nome',
                prefixIcon: Icon(Icons.search, color: Color(0xFF0E382C)),
                filled: true,
                fillColor: Theme.of(context).scaffoldBackgroundColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) => setState(() {
                searchText = value.toLowerCase();
              }),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('pacientes')
                  .orderBy('nome')
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
                  return name.contains(searchText);
                }).toList();

                if (filteredPatients.isEmpty) {
                  return Center(
                    child: Text(
                      'Nenhum paciente encontrado',
                      style: GoogleFonts.openSans(color: Colors.black54),
                    ),
                  );
                }

                return ListView.separated(
                  controller: widget.scrollController,
                  itemCount: filteredPatients.length,
                  separatorBuilder: (_, __) => Divider(height: 1),
                  itemBuilder: (context, index) {
                    final patient = filteredPatients[index];
                    final patientName = patient['nome'] ?? 'Sem Nome';
                    final initialLetter = patientName.isNotEmpty
                        ? patientName[0].toUpperCase()
                        : '?';
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Color(0xFF0E382C),
                        child: Text(
                          initialLetter,
                          style: GoogleFonts.montserrat(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        patientName,
                        style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      onTap: () =>
                          widget.onPatientSelected(patient.id, patientName),
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
