import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PatientDropdown extends StatelessWidget {
  final Function(String?) onPatientSelected;
  final String? selectedPatient;
  final List<DropdownMenuItem<String>> items;

  const PatientDropdown({
    super.key,
    required this.onPatientSelected,
    required this.items,
    this.selectedPatient,
  });

  @override
  Widget build(BuildContext context) {
    final validIds = items
        .map((item) => item.value)
        .whereType<String>()
        .toList();
    final currentValue = validIds.contains(selectedPatient)
        ? selectedPatient
        : null;
    final List<DropdownMenuItem<String>> dropdownItems = items.isEmpty
        ? [
            DropdownMenuItem<String>(
              value: null,
              enabled: false,
              child: Text(
                'Nenhum paciente ativo',
                style: GoogleFonts.montserrat(color: Colors.grey[600]),
              ),
            ),
          ]
        : items;
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
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          isExpanded: true,
          value: currentValue,
          hint: Text(
            items.isEmpty ? 'Nenhum paciente ativo' : 'Selecione o Paciente',
            style: GoogleFonts.montserrat(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          underline: SizedBox(),
          iconStyleData: IconStyleData(
            icon: Icon(Icons.arrow_drop_down_outlined, color: Colors.black54),
          ),
          style: GoogleFonts.openSans(fontSize: 14, color: Colors.black87),
          items: dropdownItems,
          onChanged: onPatientSelected,
        ),
      ),
    );
  }
}
