import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NewProtocolPage extends StatefulWidget {
  const NewProtocolPage({super.key});

  @override
  State<NewProtocolPage> createState() => _NewProtocolPageState();
}

class _NewProtocolPageState extends State<NewProtocolPage> {
  final _protocolNameController = TextEditingController();
  final _patientNameController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  final _notesController = TextEditingController();

  List<Map<String, String>> exercises = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0E382C),
        title: Text(
          'Criar Protocolo',
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white, size: 26),
        elevation: 0.4,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nome do protocolo e Paciente
              TextField(
                controller: _protocolNameController,
                decoration: InputDecoration(
                  hint: Text(
                    'Nome do Protocolo',
                    style: GoogleFonts.openSans(color: Colors.black54),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(11),
                  ),
                  fillColor: const Color.fromARGB(140, 181, 181, 181),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                  filled: true,
                ),
              ),
              SizedBox(height: 12),
              TextField(
                controller: _patientNameController,
                decoration: InputDecoration(
                  hint: Text(
                    'Nome do Paciente',
                    style: GoogleFonts.openSans(color: Colors.black54),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(11),
                  ),
                  fillColor: const Color.fromARGB(140, 181, 181, 181),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                  filled: true,
                ),
              ),
              SizedBox(height: 26),

              // Exercícios
              Text(
                'Exercícios',
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),
              SizedBox(height: 10),
              Column(
                children: [
                  for (final ex in exercises)
                    Card(
                      color: Color(0xFFF4F7F6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      margin: EdgeInsets.only(bottom: 8),
                      elevation: 0.8,
                      child: ListTile(
                        leading: Icon(
                          Icons.fitness_center,
                          color: Color(0xFF667786),
                        ),
                        title: Text(
                          ex['title']!,
                          style: GoogleFonts.openSans(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text(
                          ex['subtitle']!,
                          style: GoogleFonts.openSans(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                        trailing: Icon(Icons.chevron_right),
                        onTap: () {
                          // Futuro: editar/excluir exercício
                        },
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 4,
                        ),
                      ),
                    ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () =>
                          Navigator.pushNamed(context, '/new-exercise'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(
                          98,
                          232,
                          232,
                          232,
                        ),
                        minimumSize: Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(9),
                        ),
                      ),
                      child: Text(
                        'Adicionar exercício',
                        style: GoogleFonts.openSans(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24),

              // Agendar
              Text(
                'Agendar',
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _startDateController,
                readOnly: true,
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    _startDateController.text =
                        '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
                  }
                },
                decoration: InputDecoration(
                  hint: Text(
                    'Data de Início',
                    style: GoogleFonts.openSans(color: Colors.black54),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(11),
                  ),
                  fillColor: const Color.fromARGB(140, 181, 181, 181),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                  filled: true,
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _endDateController,
                readOnly: true,
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    _endDateController.text =
                        '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
                  }
                },
                decoration: InputDecoration(
                  hint: Text(
                    'Data Final',
                    style: GoogleFonts.openSans(color: Colors.black54),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(11),
                  ),
                  fillColor: const Color.fromARGB(140, 181, 181, 181),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                  filled: true,
                ),
              ),
              SizedBox(height: 26),

              // Notas
              Text(
                'Notas',
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _notesController,
                minLines: 3,
                maxLines: 6,
                decoration: InputDecoration(
                  hint: Text(
                    'Adicionar anotações para o paciente',
                    style: GoogleFonts.openSans(color: Colors.black54),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                  fillColor: const Color.fromARGB(140, 181, 181, 181),
                  filled: true,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 16,
                  ),
                ),
              ),
              SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Salvar protocolo
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF0E382C),
                    minimumSize: Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9),
                    ),
                  ),
                  child: Text(
                    'Salvar Protocolo',
                    style: GoogleFonts.openSans(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
