class DoctorModel {
  final String id;
  final String nome;
  final String email;
  final String? telefone;
  final String? crefito;
  final String? crm;
  final String? profileImage;
  final bool isAdmin;

  DoctorModel({
    required this.id,
    required this.nome,
    required this.email,
    this.telefone,
    this.crefito,
    this.crm,
    this.profileImage,
    this.isAdmin = false,
  });

  factory DoctorModel.fromMap(Map<String, dynamic> map, String docId) {
    bool adminStatus = false;
    if (map['isAdmin'] is bool) {
      adminStatus = map['isAdmin'];
    } else if (map['isAdmin'] is String) {
      adminStatus = map['isAdmin'].toString().toLowerCase() == 'true';
    }

    return DoctorModel(
      id: docId,
      nome: map['nome'] ?? 'Sem nome',
      email: map['email'] ?? '',
      telefone: map['telefone'],
      crefito: map['crefito'],
      crm: map['crm'],
      profileImage: map['profileImage'],
      isAdmin: adminStatus,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'email': email,
      'telefone': telefone,
      'crefito': crefito,
      'crm': crm,
      'profileImage': profileImage,
      'isAdmin': isAdmin,
    };
  }
}
