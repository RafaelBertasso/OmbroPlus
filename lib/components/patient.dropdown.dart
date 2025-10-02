import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PatientDropdown extends StatefulWidget {
  final Function(String?) onPatientSelected;
  final String? selectedPatient;
  const PatientDropdown({
    super.key,
    required this.onPatientSelected,
    this.selectedPatient,
  });

  @override
  State<PatientDropdown> createState() => _PatientDropdownState();
}

class _PatientDropdownState extends State<PatientDropdown> {
  List<Map<String, String>> patients = [];

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('pacientes')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator(color: Color(0xFF0E382C));
        } else if (snapshot.hasError) {
          return Text(
            'Erro ao carregar pacientes',
            style: GoogleFonts.montserrat(
              fontSize: 16,
              color: Colors.grey[700],
            ),
          );
        }
        patients =
            snapshot.data?.docs
                .map((doc) => {'id': doc.id, 'nome': doc['nome'] as String})
                .toList() ??
            [];

        final validId = patients.map((p) => p['id']).toList();
        final currentValue = validId.contains(widget.selectedPatient)
            ? widget.selectedPatient
            : null;
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black26),
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton2<String>(
              dropdownStyleData: DropdownStyleData(
                decoration: BoxDecoration(
                  color: Color(0xFFF4F7F6),
                ),
              ),
              isExpanded: true,
              value: currentValue,
              hint: Text(
                'Selecione o Paciente',
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              underline: SizedBox(),
              iconStyleData: IconStyleData(
                icon: Icon(Icons.arrow_drop_down, color: Colors.black54),
              ),
              style: GoogleFonts.openSans(fontSize: 14, color: Colors.black87),
              items: patients.map((patient) {
                return DropdownMenuItem<String>(
                  value: patient['id'],
                  child: Text(
                    patient['nome'] ?? '',
                    style: GoogleFonts.openSans(),
                  ),
                );
              }).toList(),
              onChanged: widget.onPatientSelected,
            ),
          ),
        );
      },
    );
  }
}
