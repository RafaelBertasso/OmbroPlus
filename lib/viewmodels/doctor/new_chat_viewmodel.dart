import 'package:Ombro_Plus/repositories/chat_repository.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NewChatViewModel extends ChangeNotifier {
  final ChatRepository chatRepository;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _searchText = '';
  bool _isLoading = false;

  NewChatViewModel({required this.chatRepository});

  String get searchText => _searchText;
  bool get isLoading => _isLoading;

  void setSearchText(String value) {
    _searchText = value;
    notifyListeners();
  }

  // AGORA FILTRA APENAS OS PACIENTES DESTE MÉDICO
  Stream<QuerySnapshot> getPatientsStream(String specialistId) {
    return _firestore
        .collection('pacientes')
        .where('especialistaId', isEqualTo: specialistId) // Filtro crucial
        .snapshots();
  }

  Future<void> startChat(
    BuildContext context,
    String patientId,
    String patientName,
  ) async {
    final currentSpecialistId = FirebaseAuth.instance.currentUser?.uid;
    if (currentSpecialistId == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      // 1. Busca os dados do médico (com fallback para não travar se falhar)
      String specialistName = 'Especialista';
      try {
        final specialistDoc = await _firestore
            .collection('especialistas')
            .doc(currentSpecialistId)
            .get();
        if (specialistDoc.exists && specialistDoc.data() != null) {
          specialistName = specialistDoc.data()!['nome'] ?? 'Especialista';
        }
      } catch (e) {
        print("Aviso: Não foi possível buscar o nome do médico.");
      }

      // 2. Cria ou recupera a sala
      final roomId = await chatRepository.getOrCreateChatId(
        currentSpecialistId,
        patientId,
        patientName,
        specialistName,
      );

      _isLoading = false;
      notifyListeners();

      // 3. Navegação Imediata
      if (context.mounted) {
        Navigator.pushReplacementNamed(
          context,
          '/chat-detail',
          arguments: {'roomId': roomId, 'name': patientName, 'id': patientId},
        );
      }
    } catch (e) {
      print("Erro Crítico ao criar chat: $e");
      _isLoading = false;
      notifyListeners();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro de conexão ao iniciar a conversa.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String getInitialLetter(String? name) {
    if (name == null || name.isEmpty) return '?';
    return name.trim().split(' ').first[0].toUpperCase();
  }
}
