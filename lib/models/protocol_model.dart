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

  // O cronograma: Data (String) -> Lista de Exercícios (Map)
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
    // --- LÓGICA DE SEGURANÇA PARA O SCHEDULE ---
    Map<String, List<Map<String, dynamic>>> parsedSchedule = {};

    // 1. Verifica se o campo 'schedule' existe e é um Mapa
    if (map['schedule'] != null && map['schedule'] is Map) {
      final rawMap = map['schedule'] as Map<String, dynamic>;

      rawMap.forEach((key, value) {
        // 2. Verifica se o valor dentro da data é uma Lista (evita o erro 'int is not List')
        if (value is List) {
          try {
            // 3. Converte cada item da lista para Map<String, dynamic> com segurança
            final List<Map<String, dynamic>> exercisesList = value.map((e) {
              return Map<String, dynamic>.from(e as Map);
            }).toList();

            parsedSchedule[key] = exercisesList;
          } catch (e) {
            print("Erro ao converter exercícios do dia $key: $e");
          }
        }
      });
    }
    // Fallback: Suporte a versões antigas ou dados inconsistentes
    else {
      // Se quiser, pode verificar o campo antigo 'exercicios' aqui,
      // mas por enquanto deixamos vazio para não quebrar.
      parsedSchedule = {};
    }
    // -------------------------------------------

    return ProtocolModel(
      id: docId,
      nome: map['nome'] as String? ?? 'Sem nome',
      pacienteId: map['pacienteId'] as String? ?? '',
      pacienteName: map['pacienteName'] as String? ?? 'Paciente',
      especialistaId: map['especialistaId'] as String? ?? '',

      // Tratamento seguro de datas (caso venha null, usa data atual)
      dataInicio: map['dataInicio'] is Timestamp
          ? (map['dataInicio'] as Timestamp).toDate()
          : DateTime.now(),
      dataFim: map['dataFim'] is Timestamp
          ? (map['dataFim'] as Timestamp).toDate()
          : DateTime.now().add(const Duration(days: 30)),

      notas: map['notas'] as String? ?? '',
      status: map['status'] as String? ?? 'active',

      // Tratamento seguro de números (aceita int ou double/num)
      totalSessoesEstimadas:
          (map['totalSessoesEstimadas'] as num?)?.toInt() ?? 0,
      sessoesConcluidas: (map['sessoesConcluidas'] as num?)?.toInt() ?? 0,

      criadoEm: map['criadoEm'] is Timestamp
          ? (map['criadoEm'] as Timestamp).toDate()
          : null,

      schedule: parsedSchedule,
    );
  }

  ProtocolModel copyWith({
    String? id,
    String? nome,
    String? status,
    String? pacienteName,
    int? sessoesConcluidas,
    Map<String, List<Map<String, dynamic>>>? schedule,
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
      schedule: schedule ?? this.schedule,
    );
  }
}
