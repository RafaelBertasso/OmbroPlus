import 'package:cloud_firestore/cloud_firestore.dart';

class ExerciseModel {
  final String id;
  final String nome;
  final String descricao;
  final String? youtubeId;
  final String? categoria;
  final String? imagemUrl;
  final DateTime? criadoEm;

  ExerciseModel({
    required this.id,
    required this.nome,
    required this.descricao,
    this.criadoEm,
    this.youtubeId,
    this.categoria,
    this.imagemUrl,
  });

  factory ExerciseModel.fromMap(Map<String, dynamic> map, String id) {
    return ExerciseModel(
      id: id,
      nome: map['nome'] ?? 'Sem nome',
      descricao: map['descricao'],
      youtubeId: map['youtubeId'],
      categoria: map['categoria'],
      imagemUrl: map['imageUrl'],
      criadoEm: map['criadoEm'] != null
          ? (map['criadoEm'] as Timestamp).toDate()
          : null,
    );
  }
}

class ProtocolExerciseItem {
  final ExerciseModel exercise;
  String series;
  String repeticoes;

  ProtocolExerciseItem({
    required this.exercise,
    this.series = '3',
    this.repeticoes = '10',
  });

  Map<String, dynamic> toMap() {
    return {
      'exercicioId': exercise.id,
      'nome': exercise.nome,
      'series': series,
      'repeticoes': repeticoes,
      'youtubeId': exercise.youtubeId,
      'descricao': exercise.descricao,
    };
  }
}
