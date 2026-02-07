import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RadioGroupField<T> extends StatelessWidget {
  final String title;
  final T? groupValue;
  final List<T> values;
  final ValueChanged<T?> onChanged;
  RadioGroupField({
    super.key,
    required this.title,
    required this.groupValue,
    required this.onChanged,
    required this.values,
  });

  String _getDisplayTitle(T value) {
    final parts = value.toString().split('.');
    return parts.last.replaceAll('_', ' ').toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsetsGeometry.symmetric(vertical: 8),
          child: Text(
            title,
            style: GoogleFonts.montserrat(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
        ...values.map((value) {
          return RadioListTile<T>(
            value: value,
            title: Text(_getDisplayTitle(value)),
            groupValue: groupValue,
            onChanged: onChanged,
            activeColor: Color(0xFF0E382C),
            dense: true,
          );
        }).toList(),
        Divider(),
      ],
    );
  }
}
