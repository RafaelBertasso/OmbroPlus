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

  Stream<QuerySnapshot> getPatientsStream(String specialistId) {
    return _firestore
        .collection('pacientes')
        .where('especialistaId', isEqualTo: specialistId)
        .snapshots();
  }

  Future<void> startChat(
    BuildContext context,
    String patientId,
    String patientName,
  ) async {
    print("🔵 startChat chamado - patientId: $patientId, name: $patientName");

    final currentSpecialistId = FirebaseAuth.instance.currentUser?.uid;
    if (currentSpecialistId == null) {
      print("🔴 ERRO: currentSpecialistId é NULL!");
      return;
    }

    print("🔵 currentSpecialistId: $currentSpecialistId");

    final navigator = Navigator.of(context);

    _isLoading = true;
    notifyListeners();

    try {
      String specialistName = 'Especialista';
      try {
        print("🔵 Buscando dados do especialista...");
        final specialistDoc = await _firestore
            .collection('especialistas')
            .doc(currentSpecialistId)
            .get();
        if (specialistDoc.exists && specialistDoc.data() != null) {
          specialistName = specialistDoc.data()!['nome'] ?? 'Especialista';
          print("🟢 Nome do especialista: $specialistName");
        }
      } catch (e) {
        print("🟡 Aviso: Não foi possível buscar o nome do médico: $e");
      }

      print("🔵 Criando/buscando roomId...");
      final roomId = await chatRepository.getOrCreateChatId(
        currentSpecialistId,
        patientId,
        patientName,
        specialistName,
      );
      print("🟢 RoomId criado/recuperado: $roomId");

      _isLoading = false;
      notifyListeners();

      print("🔵 Navegando usando navigator capturado...");
      navigator.pop();
      navigator.pushNamed(
        '/chat-detail',
        arguments: {'roomId': roomId, 'name': patientName, 'id': patientId},
      );
      print("🟢 Navegação concluída!");
    } catch (e) {
      print("🔴 Erro Crítico ao criar chat: $e");
      print("🔴 Stack trace: ${StackTrace.current}");

      _isLoading = false;
      notifyListeners();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro de conexão: $e'),
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
