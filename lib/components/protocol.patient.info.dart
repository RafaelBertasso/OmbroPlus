import 'package:Ombro_Plus/components/info.card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ProtocolPatientIfo extends StatelessWidget {
  final String patientId;
  const ProtocolPatientIfo({super.key, required this.patientId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('pacientes')
          .doc(patientId)
          .get(),
      builder: (context, snapshot) {
        String patientName = 'Carregando...';
        if (snapshot.hasData && snapshot.data!.exists) {
          patientName =
              (snapshot.data!.data() as Map<String, dynamic>)['nome'] ??
              'Paciente sem nome';
        } else if (snapshot.hasError) {
          patientName = 'Erro ao carregar nome';
        }
        return InfoCard(
          title: 'Paciente Associado',
          content: patientName,
          icon: Icons.person_outline_rounded,
        );
      },
    );
  }
}
