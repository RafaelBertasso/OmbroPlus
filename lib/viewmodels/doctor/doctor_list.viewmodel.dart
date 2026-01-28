import 'package:Ombro_Plus/models/doctor.model.dart';
import 'package:Ombro_Plus/repositories/doctor.repository.dart';
import 'package:flutter/material.dart';

class DoctorListViewModel extends ChangeNotifier {
  final DoctorListRepository repository;

  DoctorListViewModel({required this.repository});

  List<DoctorModel> _specialists = [];
  List<DoctorModel> _filteredSpecialists = [];
  bool _isLoading = false;
  String? _error;

  List<DoctorModel> get specialists => _filteredSpecialists;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchSpecialists() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _specialists = await repository.getAllSpecialists();
      _filteredSpecialists = _specialists;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void search(String query) {
    if (query.isEmpty) {
      _filteredSpecialists = _specialists;
    } else {
      _filteredSpecialists = _specialists.where((s) {
        final name = s.nome.toLowerCase();
        return name.contains(query.toLowerCase());
      }).toList();
    }
    notifyListeners();
  }
}
