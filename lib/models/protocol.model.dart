import 'package:cloud_firestore/cloud_firestore.dart';

class ProtocolModel {
  final String? id;
  final String nome;
  final String pacienteId;
  final String pacienteName;
  final String especialistaId;
  final DateTime dataInicio;
  final DateTime dataFim;
  final String notas;
  final String status;
  final int totalSessoesEstimadas;
  final int sessoesConcluidas;
  final DateTime? criadoEm;

  final Map<String, List<Map<String, dynamic>>> schedule;

  ProtocolModel({
    this.id,
    required this.nome,
    required this.pacienteId,
    this.pacienteName = 'Paciente',
    required this.especialistaId,
    required this.dataInicio,
    required this.dataFim,
    this.notas = '',
    this.status = 'active',
    required this.totalSessoesEstimadas,
    this.sessoesConcluidas = 0,
    this.criadoEm,
    required this.schedule,
  });

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'pacienteId': pacienteId,
      'pacienteName': pacienteName,
      'especialistaId': especialistaId,
      'dataInicio': Timestamp.fromDate(dataInicio),
      'dataFim': Timestamp.fromDate(dataFim),
      'notas': notas,
      'status': status,
      'totalSessoesEstimadas': totalSessoesEstimadas,
      'sessoesConcluidas': sessoesConcluidas,
      'criadoEm': criadoEm != null
          ? Timestamp.fromDate(criadoEm!)
          : FieldValue.serverTimestamp(),
      'schedule': schedule,
    };
  }

  factory ProtocolModel.fromMap(Map<String, dynamic> map, String docId) {
    return ProtocolModel(
      id: docId,
      nome: map['nome'] as String? ?? 'Sem nome',
      pacienteId: map['pacienteId'] as String? ?? '',
      pacienteName: map['pacienteName'] as String? ?? 'Paciente',
      especialistaId: map['especialistaId'] as String? ?? '',

      dataInicio: (map['dataInicio'] as Timestamp).toDate(),
      dataFim: (map['dataFim'] as Timestamp).toDate(),

      notas: map['notas'] as String? ?? '',
      status: map['status'] as String? ?? 'active',
      totalSessoesEstimadas:
          (map['totalSessoesEstimadas'] as num?)?.toInt() ?? 0,
      sessoesConcluidas: (map['sessoesConcluidas'] as num?)?.toInt() ?? 0,
      criadoEm: map['criadoEm'] != null
          ? (map['criadoEm'] as Timestamp).toDate()
          : null,
      schedule:
          (map['schedule'] as Map<String, dynamic>?)?.map((key, value) {
            final list = (value as List<dynamic>).map((item) {
              return Map<String, dynamic>.from(item as Map);
            }).toList();
            return MapEntry(key, list);
          }) ??
          {},
    );
  }

  ProtocolModel copyWith({
    String? id,
    String? nome,
    String? status,
    String? pacienteName,
    int? sessoesConcluidas,
  }) {
    return ProtocolModel(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      pacienteId: this.pacienteId,
      pacienteName: pacienteName ?? this.pacienteName,
      especialistaId: this.especialistaId,
      dataInicio: this.dataInicio,
      dataFim: this.dataFim,
      notas: this.notas,
      status: status ?? this.status,
      totalSessoesEstimadas: this.totalSessoesEstimadas,
      sessoesConcluidas: sessoesConcluidas ?? this.sessoesConcluidas,
      criadoEm: this.criadoEm,
      schedule: this.schedule,
    );
  }
}
