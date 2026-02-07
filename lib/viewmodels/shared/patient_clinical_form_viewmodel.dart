import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum LadoAfetado { direito, esquerdo, ambos }

enum NivelDor { leve, moderado, intensa }

enum NivelMobilidade { limitada, parcial, boa }

class PatientClinicalFormViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = true;
  bool _isSaving = false;
  String? _patientId;
  String? _patientName = 'Paciente';

  LadoAfetado? _ladoAfetado;
  bool? _fezFisioterapiaAntes;
  String? _tipoTratamento;
  NivelDor? _nivelDor;
  NivelMobilidade? _mobilidadeOmbro;

  String? _diagnosticoPrincipal;
  bool _isDiagnosticoOutroSelected = false;

  String? _objetivoTratamento;
  bool _isObjetivoOutroSelected = false;

  final Map<String, bool> _dificuldadesPrincipais = {
    'Levantar Braço': false,
    'Dormir': false,
    'Atividades Diárias': false,
    'Exercícios': false,
    'Outros': false,
  };

  final List<String> diagnosticos = [
    'Lesão do Manguito Rotador',
    'Luxação',
    'Artrose',
    'Fratura',
    'Reparo Cirúrgico',
    'Instabilidade',
    'Outro',
  ];
  final List<String> objetivos = [
    'Voltar ao Esporte',
    'Melhorar Dor',
    'Rotina Diária',
    'Estética',
    'Outro',
  ];

  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  LadoAfetado? get ladoAfetado => _ladoAfetado;
  bool? get fezFisioterapiaAntes => _fezFisioterapiaAntes;
  String? get tipoTratamento => _tipoTratamento;
  NivelDor? get nivelDor => _nivelDor;
  NivelMobilidade? get mobilidadeOmbro => _mobilidadeOmbro;
  String? get diagnosticoPrincipal => _diagnosticoPrincipal;
  bool get isDiagnosticoOutroSelected => _isDiagnosticoOutroSelected;
  String? get objetivoTratamento => _objetivoTratamento;
  bool get isObjetivoOutroSelected => _isObjetivoOutroSelected;
  Map<String, bool> get dificuldadesPrincipais => _dificuldadesPrincipais;

  void setLadoAfetado(LadoAfetado? val) {
    _ladoAfetado = val;
    notifyListeners();
  }

  void setFezFisioterapia(String? val) {
    _fezFisioterapiaAntes = val == 'Sim';
    notifyListeners();
  }

  void setTipoTratamento(String? val) {
    _tipoTratamento = val;
    notifyListeners();
  }

  void setNivelDor(NivelDor? val) {
    _nivelDor = val;
    notifyListeners();
  }

  void setMobilidade(NivelMobilidade? val) {
    _mobilidadeOmbro = val;
    notifyListeners();
  }

  void setDificuldade(String key, bool value) {
    _dificuldadesPrincipais[key] = value;
    notifyListeners();
  }

  void setDiagnostico(String? val) {
    _diagnosticoPrincipal = val;
    _isDiagnosticoOutroSelected = (val == 'Outro');
    notifyListeners();
  }

  void setObjetivo(String? val) {
    _objetivoTratamento = val;
    _isObjetivoOutroSelected = (val == 'Outro');
    notifyListeners();
  }

  Future<Map<String, dynamic>?> loadClinicalData(String id) async {
    _patientId = id;
    _isLoading = true;
    notifyListeners();

    try {
      final doc = await _firestore.collection('pacientes').doc(id).get();
      if (!doc.exists || doc.data() == null) return null;

      final data = doc.data()!;
      _patientName = data['nome'] ?? 'Paciente';

      _ladoAfetado = _parseEnum(data['ladoAfetado'], LadoAfetado.values);
      _nivelDor = _parseEnum(data['nivelDor'], NivelDor.values);
      _mobilidadeOmbro = _parseEnum(
        data['mobilidadeOmbro'],
        NivelMobilidade.values,
      );

      _fezFisioterapiaAntes = data['fezFisioterapiaAntes'] as bool?;
      _tipoTratamento = data['tipoTratamento'];

      final diag = data['diagnosticoPrincipal'] as String?;
      if (diag != null && diag.startsWith('Outro:')) {
        _diagnosticoPrincipal = 'Outro';
        _isDiagnosticoOutroSelected = true;
        data['diagnosticoOutroText'] = diag.substring(7).trim();
      } else {
        _diagnosticoPrincipal = diag;
      }

      final obj = data['objetivoTratamento'] as String?;
      if (obj != null && obj.startsWith('Outro:')) {
        _objetivoTratamento = 'Outro';
        _isObjetivoOutroSelected = true;
        data['objetivoOutroText'] = obj.substring(7).trim();
      } else {
        _objetivoTratamento = obj;
      }

      final diffs = data['dificuldadesPrincipais'] as List<dynamic>? ?? [];
      for (var key in _dificuldadesPrincipais.keys) {
        _dificuldadesPrincipais[key] = diffs.contains(key);
      }
      final outroDiff = diffs.firstWhere(
        (e) => e.toString().startsWith('Outras:'),
        orElse: () => null,
      );
      if (outroDiff != null) {
        _dificuldadesPrincipais['Outros'] = true;
        data['dificuldadesOutrosText'] = outroDiff
            .toString()
            .substring(8)
            .trim();
      }

      _isLoading = false;
      notifyListeners();
      return data;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<bool> saveClinicalData({
    required String doencas,
    required String detalhesTratamento,
    required String dataTratamento,
    required String medico,
    required String diagnosticoOutro,
    required String objetivoOutro,
    required String dificuldadesOutro,
  }) async {
    _isSaving = true;
    notifyListeners();

    try {
      String? finalDiagnostico = _isDiagnosticoOutroSelected
          ? 'Outro: $diagnosticoOutro'
          : _diagnosticoPrincipal;
      String? finalObjetivo = _isObjetivoOutroSelected
          ? 'Outro: $objetivoOutro'
          : _objetivoTratamento;

      List<String> diffSelecionadas = [];
      _dificuldadesPrincipais.forEach((key, isSelected) {
        if (isSelected) {
          diffSelecionadas.add(
            key == 'Outros' ? 'Outras: $dificuldadesOutro' : key,
          );
        }
      });

      await _firestore.collection('pacientes').doc(_patientId).set({
        'ladoAfetado': _ladoAfetado?.name,
        'fezFisioterapiaAntes': _fezFisioterapiaAntes,
        'doencasAssociadas': doencas,
        'diagnosticoPrincipal': finalDiagnostico,
        'tipoTratamento': _tipoTratamento,
        'detalhesTratamento': detalhesTratamento,
        'dataTratamento': dataTratamento,
        'medicoResponsavel': medico,
        'nivelDor': _nivelDor?.name,
        'mobilidadeOmbro': _mobilidadeOmbro?.name,
        'dificuldadesPrincipais': diffSelecionadas,
        'objetivoTratamento': finalObjetivo,
        'lastClinicalUpdate': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await _firestore.collection('activity_feed').add({
        'type': 'CLINICAL_FORM_COMPLETED',
        'patientName': _patientName,
        'message': 'Ficha clínica de $_patientName preenchida/atualizada',
        'timestamp': FieldValue.serverTimestamp(),
        'patientId': _patientId,
      });

      return true;
    } catch (e) {
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  T? _parseEnum<T extends Enum>(String? value, List<T> values) {
    if (value == null) return null;
    try {
      return values.firstWhere((e) => e.name == value);
    } catch (_) {
      return null;
    }
  }
}
