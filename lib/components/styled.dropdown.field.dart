import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StyledDropdownField<T> extends FormField<T> {
  final String labelText;
  final List<DropdownMenuItem<T>> items;
  final T? initialValue;
  final ValueChanged<T?>? onChanged;
  final String? Function(T?)? validator;

  StyledDropdownField({
    super.key,
    required this.labelText,
    required this.items,
    this.initialValue,
    this.onChanged,
    this.validator,
  }) : super(
         initialValue: initialValue,
         validator: validator,
         builder: (FormFieldState<T> state) {
           return Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               Text(
                 labelText,
                 style: GoogleFonts.openSans(
                   color: Colors.black54,
                   fontSize: 12,
                 ),
               ),
               const SizedBox(height: 4),

               Container(
                 padding: const EdgeInsets.symmetric(
                   horizontal: 12,
                   vertical: 0,
                 ),
                 decoration: BoxDecoration(
                   border: Border.all(
                     color: state.hasError ? Colors.red : Colors.black26,
                   ),
                   borderRadius: BorderRadius.circular(8),
                   color: Colors.white,
                 ),
                 child: DropdownButtonHideUnderline(
                   child: DropdownButton2<T>(
                     isExpanded: true,
                     value: state.value,
                     hint: Text(
                       labelText,
                       style: GoogleFonts.montserrat(
                         fontSize: 14,
                         color: Colors.grey[600],
                       ),
                     ),
                     onChanged: (T? newValue) {
                       state.didChange(newValue);
                       if (onChanged != null) {
                         onChanged(newValue);
                       }
                     },
                     items: items,
                     underline: const SizedBox(),
                     iconStyleData: IconStyleData(
                       icon: Icon(Icons.arrow_drop_down, color: Colors.black54),
                     ),
                     dropdownStyleData: DropdownStyleData(
                       decoration: BoxDecoration(
                         color: const Color(0xFFF4F7F6),
                         borderRadius: BorderRadius.circular(8),
                       ),
                     ),
                   ),
                 ),
               ),
               if (state.hasError)
                 Padding(
                   padding: const EdgeInsets.only(top: 8.0, left: 12.0),
                   child: Text(
                     state.errorText!,
                     style: GoogleFonts.openSans(
                       color: Colors.red,
                       fontSize: 12,
                     ),
                   ),
                 ),
             ],
           );
         },
       );
}
