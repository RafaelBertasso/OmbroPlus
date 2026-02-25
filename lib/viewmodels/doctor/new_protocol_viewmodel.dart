import 'package:Ombro_Plus/models/protocol_model.dart';
import 'package:Ombro_Plus/repositories/protocol_repository.dart';
import 'package:flutter/material.dart';

class NewProtocolViewModel extends ChangeNotifier {
  final ProtocolRepository _repository;

  bool _isLoading = false;
  String? _error;

  List<ProtocolSession> _sessions = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<ProtocolSession> get sessions => _sessions;

  Map<int, List<ProtocolSession>> get sessionsByWeek {
    final map = <int, List<ProtocolSession>>{};
    for (var session in _sessions) {
      if (!map.containsKey(session.semana)) {
        map[session.semana] = [];
      }
      map[session.semana]!.add(session);
    }
    return map;
  }

  NewProtocolViewModel({required ProtocolRepository repository})
    : _repository = repository;

  void updateSessions(List<ProtocolSession> updatedSessions) {
    _sessions = updatedSessions;
    notifyListeners();
  }

  Future<bool> saveProtocol({
    required String nome,
    required String pacienteId,
    required String pacienteName,
    required String especialistaId,
    required DateTime? dataInicio,
    required DateTime? dataFim,
    String? notas,
    String? materialUrl,
    List<String>? allowedSpecialists,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (nome.isEmpty) throw Exception("O nome do protocolo é obrigatório.");
      if (pacienteId.isEmpty) throw Exception("Selecione um paciente.");
      if (dataInicio == null || dataFim == null) {
        throw Exception("Defina as datas de início e fim.");
      }
      if (dataFim.isBefore(dataInicio)) {
        throw Exception("A data final não pode ser antes da inicial.");
      }
      if (_sessions.isEmpty) {
        throw Exception("Adicione pelo menos uma sessão ao cronograma.");
      }

      for (var session in _sessions) {
        if (session.exercises.isEmpty) {
          throw Exception(
            "A sessão '${session.name}' deve conter pelo menos um exercício.",
          );
        }
      }

      int totalEstimado = _sessions.length;

      List<String> colaboradores = allowedSpecialists != null
          ? List<String>.from(allowedSpecialists)
          : [];

      if (!colaboradores.contains(especialistaId)) {
        colaboradores.add(especialistaId);
      }

      final protocol = ProtocolModel(
        nome: nome,
        pacienteId: pacienteId,
        pacienteName: pacienteName,
        especialistaId: especialistaId,
        especialistasColaboradores: colaboradores,
        materialUrl: materialUrl,
        dataInicio: dataInicio,
        dataFim: dataFim,
        notas: notas ?? '',
        totalSessoesEstimadas: totalEstimado,
        sessoes: _sessions,
      );

      await _repository.createProtocol(protocol, pacienteName);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll("Exception: ", "");
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
