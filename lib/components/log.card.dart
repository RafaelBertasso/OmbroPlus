import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LogCard extends StatelessWidget {
  final String activity;
  final DateTime date;
  const LogCard({super.key, required this.activity, required this.date});

  @override
  Widget build(BuildContext context) {
    DateFormat dateFormat = DateFormat("d 'de' MMMM 'de' y, HH:mm", 'pt_BR');
    return Card(
      color: Color.fromARGB(220, 255, 255, 255),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(Icons.date_range, color: Colors.grey),
            ),
            SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dateFormat.format(date),
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
