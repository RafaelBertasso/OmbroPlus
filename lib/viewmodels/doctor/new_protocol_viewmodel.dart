import 'package:Ombro_Plus/models/protocol_model.dart';
import 'package:Ombro_Plus/repositories/protocol_repository.dart';
import 'package:flutter/material.dart';

class NewProtocolViewModel extends ChangeNotifier {
  final ProtocolRepository _repository;

  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  NewProtocolViewModel({required ProtocolRepository repository})
    : _repository = repository;

  Future<bool> saveProtocol({
    required String nome,
    required String pacienteId,
    required String pacienteName,
    required String especialistaId,
    required DateTime? dataInicio,
    required DateTime? dataFim,
    required Map<String, List<Map<String, dynamic>>> schedule,
    String? notas,
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
      if (schedule.isEmpty) {
        throw Exception("Adicione exercícios ao cronograma.");
      }

      final protocol = ProtocolModel(
        nome: nome,
        pacienteId: pacienteId,
        especialistaId: especialistaId,
        dataInicio: dataInicio,
        dataFim: dataFim,
        notas: notas ?? '',
        totalSessoesEstimadas: schedule.length,
        schedule: schedule,
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
