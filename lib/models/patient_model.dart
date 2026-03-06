import 'package:cloud_firestore/cloud_firestore.dart';

class PatientModel {
  final String id;
  final String nome;
  final String email;
  final String? telefone;
  final String? profileImage;
  final String? especialistaId;
  final String? sexo;
  final DateTime? dataNascimento;
  final DateTime? dataCadastro;
  final String? diagnosticoPrincipal;

  PatientModel({
    required this.id,
    required this.nome,
    required this.email,
    this.telefone,
    this.profileImage,
    this.sexo,
    this.especialistaId,
    this.dataCadastro,
    this.dataNascimento,
    this.diagnosticoPrincipal,
  });

  factory PatientModel.fromMap(Map<String, dynamic> map, String docId) {
    return PatientModel(
      id: docId,
      nome: map['nome'] ?? 'Sem nome',
      email: map['email'] ?? '',
      telefone: map['telefone'],
      profileImage: map['profileImage'],
      sexo: map['sexo'],
      especialistaId: map['especialistaId'],
      diagnosticoPrincipal: map['diagnosticoPrincipal'],
      dataNascimento: map['data_nascimento'] is Timestamp
          ? (map['data_nascimento'] as Timestamp).toDate()
          : null,
      dataCadastro: map['data_cadastro'] is Timestamp
          ? (map['data_cadastro'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'email': email,
      'telefone': telefone,
      'profileImage': profileImage,
      'especialistaId': especialistaId,
      'sexo': sexo,
      'data_nascimento': dataNascimento != null
          ? Timestamp.fromDate(dataNascimento!)
          : null,
    };
  }
}
