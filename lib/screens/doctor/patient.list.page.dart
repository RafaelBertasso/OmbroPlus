import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PatientListPage extends StatefulWidget {
  const PatientListPage({super.key});

  @override
  State<PatientListPage> createState() => _PatientListPageState();
}

class _PatientListPageState extends State<PatientListPage> {
  String _search = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF4F7F6),
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Color(0xFF0E382C),
        elevation: 0.4,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.black, size: 26),
        title: Text(
          'Pacientes',
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/new-patient'),
        backgroundColor: Color(0xFF0E382C),
        tooltip: 'Adicionar Paciente',
        child: Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar paciente',
                prefixIcon: Icon(Icons.search, color: Colors.black),
                filled: true,
                fillColor: Color(0xFFF4F7F6),
                contentPadding: EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 0,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) => setState(() {
                _search = value;
              }),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .where('role', isEqualTo: 'paciente')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(color: Color(0xFF0E382C)),
                  );
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Erro ao carregar pacientes',
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        color: Colors.grey[700],
                      ),
                    ),
                  );
                }
                final docs = snapshot.data?.docs ?? [];
                final filtered = docs.where((doc) {
                  final nome = (doc['nome'] ?? '').toString().toLowerCase();
                  return nome.contains(_search.toLowerCase());
                }).toList();
                if (filtered.isEmpty) {
                  return Center(
                    child: Text(
                      'Nenhum paciente encontrado',
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                  );
                }
                return ListView.separated(
                  padding: EdgeInsets.only(top: 10),
                  itemBuilder: (context, index) {
                    final patient = filtered[index];
                    return ListTile(
                      leading: CircleAvatar(
                        radius: 25,
                        backgroundColor: Color(0xFF0E382C),
                        child: Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      title: Text(
                        patient['nome'] ?? '',
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/patient-details',
                          arguments: {
                            'name': patient['nome'],
                            'id': patient.id,
                          },
                        );
                      },
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 2,
                      ),
                    );
                  },
                  separatorBuilder: (_, __) => SizedBox(height: 4),
                  itemCount: filtered.length,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
