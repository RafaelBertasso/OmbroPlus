import 'package:cloud_firestore/cloud_firestore.dart';

class ProtocolSession {
  final String id;
  final int semana;
  final String name;
  final List<Map<String, dynamic>> exercises;
  final bool isCompleted;

  ProtocolSession({
    required this.id,
    required this.semana,
    required this.name,
    required this.exercises,
    this.isCompleted = false,
  });

  Map<String, dynamic> toMap() {
    return {'id': id, 'semana': semana, 'name': name, 'exercises': exercises};
  }

  factory ProtocolSession.fromMap(Map<String, dynamic> map) {
    return ProtocolSession(
      id: map['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      semana: map['semana'] ?? 1,
      name: map['name'] ?? 'Sessão sem nome',
      exercises: List<Map<String, dynamic>>.from(
        (map['exercises'] as List? ?? []).map(
          (e) => Map<String, dynamic>.from(e),
        ),
      ),
    );
  }
}

class ProtocolModel {
  final String? id;
  final String nome;
  final String pacienteId;
  final String pacienteName;

  final String especialistaId;
  final List<String>
  especialistasColaboradores; // IDs dos especialistas colaboradores

  final String? materialUrl;

  final DateTime dataInicio;
  final DateTime dataFim;
  final String notas;
  final String status;
  final int totalSessoesEstimadas;
  final int sessoesConcluidas;
  final DateTime? criadoEm;

  final List<ProtocolSession>
  sessoes; // Lista de sessões, cada uma com seus exercícios
  // final Map<String, List<Map<String, dynamic>>> schedule;

  ProtocolModel({
    this.id,
    required this.nome,
    required this.pacienteId,
    this.pacienteName = 'Paciente',
    required this.especialistaId,
    this.especialistasColaboradores = const [],
    this.materialUrl,
    required this.dataInicio,
    required this.dataFim,
    this.notas = '',
    this.status = 'active',
    required this.totalSessoesEstimadas,
    this.sessoesConcluidas = 0,
    this.criadoEm,
    required this.sessoes,
    // required this.schedule,
  });

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'pacienteId': pacienteId,
      'pacienteName': pacienteName,
      'especialistaId': especialistaId,
      'especialistasColaboradores': especialistasColaboradores,
      'materialUrl': materialUrl,
      'dataInicio': Timestamp.fromDate(dataInicio),
      'dataFim': Timestamp.fromDate(dataFim),
      'notas': notas,
      'status': status,
      'totalSessoesEstimadas': totalSessoesEstimadas,
      'sessoesConcluidas': sessoesConcluidas,
      'criadoEm': criadoEm != null
          ? Timestamp.fromDate(criadoEm!)
          : FieldValue.serverTimestamp(),
      'sessoes': sessoes.map((s) => s.toMap()).toList(),
      // 'schedule': schedule,
    };
  }

  factory ProtocolModel.fromMap(Map<String, dynamic> map, String docId) {
    List<ProtocolSession> parsedSessoes = [];

    if (map['sessoes'] != null && map['sessoes'] is List) {
      final list = map['sessoes'] as List<dynamic>;
      parsedSessoes = list.map((item) {
        return ProtocolSession.fromMap(Map<String, dynamic>.from(item));
      }).toList();
    } else if (map['schedule'] != null && map['schedule'] is Map) {
      final oldSchedule = map['schedule'] as Map<String, dynamic>;
      oldSchedule.forEach((dateKey, value) {
        if (value is List) {
          parsedSessoes.add(
            ProtocolSession(
              id: dateKey,
              semana: 1,
              name: "Treino do dia $dateKey",
              exercises: List<Map<String, dynamic>>.from(
                value.map((e) => Map<String, dynamic>.from(e)),
              ),
            ),
          );
        }
      });
      parsedSessoes.sort((a, b) => a.id.compareTo(b.id));
    }

    final creatorId = map['especialistaId'] as String? ?? '';
    List<String> colaboradores = List<String>.from(
      map['especialistasColaboradores'] ?? [],
    );
    if (!colaboradores.contains(creatorId) && creatorId.isNotEmpty) {
      colaboradores.add(creatorId);
    }

    return ProtocolModel(
      id: docId,
      nome: map['nome'] as String? ?? 'Sem nome',
      pacienteId: map['pacienteId'] as String? ?? '',
      pacienteName: map['pacienteName'] as String? ?? 'Paciente',
      especialistaId: map['especialistaId'] as String? ?? '',
      especialistasColaboradores: colaboradores,
      materialUrl: map['materialUrl'] as String?,

      dataInicio: map['dataInicio'] is Timestamp
          ? (map['dataInicio'] as Timestamp).toDate()
          : DateTime.now(),
      dataFim: map['dataFim'] is Timestamp
          ? (map['dataFim'] as Timestamp).toDate()
          : DateTime.now().add(const Duration(days: 30)),

      notas: map['notas'] as String? ?? '',
      status: map['status'] as String? ?? 'active',

      totalSessoesEstimadas:
          (map['totalSessoesEstimadas'] as num?)?.toInt() ?? 0,
      sessoesConcluidas: (map['sessoesConcluidas'] as num?)?.toInt() ?? 0,

      criadoEm: map['criadoEm'] is Timestamp
          ? (map['criadoEm'] as Timestamp).toDate()
          : null,
      sessoes: parsedSessoes,
      // schedule: parsedSchedule,
    );
  }

  ProtocolModel copyWith({
    String? id,
    String? nome,
    String? status,
    String? pacienteName,
    int? sessoesConcluidas,
    List<String>? especialistasColaboradores,
    String? materialUrl,
    List<ProtocolSession>? sessoes,
  }) {
    return ProtocolModel(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      pacienteId: this.pacienteId,
      pacienteName: pacienteName ?? this.pacienteName,
      especialistaId: this.especialistaId,
      especialistasColaboradores:
          especialistasColaboradores ?? this.especialistasColaboradores,
      materialUrl: materialUrl ?? this.materialUrl,
      dataInicio: this.dataInicio,
      dataFim: this.dataFim,
      notas: this.notas,
      status: status ?? this.status,
      totalSessoesEstimadas: this.totalSessoesEstimadas,
      sessoesConcluidas: sessoesConcluidas ?? this.sessoesConcluidas,
      criadoEm: this.criadoEm,
      sessoes: sessoes ?? this.sessoes,
    );
  }
}
