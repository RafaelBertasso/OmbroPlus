import 'package:Ombro_Plus/components/info.card.dart';
import 'package:Ombro_Plus/components/section.title.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ProtocolDatesSection extends StatelessWidget {
  final DateTime startDate;
  final DateTime? endDate;
  const ProtocolDatesSection({
    super.key,
    required this.endDate,
    required this.startDate,
  });

  @override
  Widget build(BuildContext context) {
    final formattedStartDate = DateFormat('dd/MM/yyyy').format(startDate);
    final formattedEndDate = endDate != null
        ? DateFormat('dd/MM/yyyy').format(endDate!)
        : 'Indefinida';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(title: 'Período do Protocolo'),
        SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: InfoCard(
                title: 'Início',
                content: formattedStartDate,
                icon: Icons.calendar_today_outlined,
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: InfoCard(
                title: 'Término',
                content: formattedEndDate,
                icon: Icons.event_available_outlined,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
