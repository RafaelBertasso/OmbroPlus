import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PatientListPage extends StatefulWidget {
  const PatientListPage({super.key});

  @override
  State<PatientListPage> createState() => _PatientListPageState();
}

class _PatientListPageState extends State<PatientListPage> {
  final List<Map<String, String>> _patients = [
    {'name': 'John Doe'},
    {'name': 'Jane Smith'},
    {'name': 'Carlos Garcia'},
    {'name': 'Maria Lopez'},
    {'name': 'David Wilson'},
    {'name': 'Emily Davis'},
    {'name': 'Michael Brown'},
    {'name': 'Sarah Johnson'},
    {'name': 'Alice Johnson'},
    {'name': 'Bob Brown'},
  ];
  String _search = '';
  @override
  Widget build(BuildContext context) {
    final filtered = _patients
        .where((p) => p['name']!.toLowerCase().contains(_search.toLowerCase()))
        .toList();
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
            fontSize: 20,
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
                fillColor: Color.fromARGB(90, 14, 56, 44),
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
            child: ListView.separated(
              padding: EdgeInsets.only(top: 10),
              itemBuilder: (context, index) {
                final patient = filtered[index];
                return ListTile(
                  leading: CircleAvatar(
                    radius: 25,
                    backgroundColor: Color(0xFFF4F7F6),
                    child: Icon(Icons.person, color: Colors.black, size: 30),
                  ),
                  title: Text(
                    patient['name']!,
                    style: GoogleFonts.openSans(
                      fontSize: 17,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () => Navigator.pushNamed(
                    context,
                    '/patient-detail',
                    arguments: {'name': patient['name']},
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 2,
                  ),
                );
              },
              separatorBuilder: (_, __) => SizedBox(height: 2),
              itemCount: filtered.length,
            ),
          ),
        ],
      ),
    );
  }
}
