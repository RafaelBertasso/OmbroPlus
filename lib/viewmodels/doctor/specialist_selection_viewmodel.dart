import 'package:Ombro_Plus/models/doctor_model.dart';
import 'package:Ombro_Plus/repositories/doctor_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SpecialistSelectionViewmodel extends ChangeNotifier {
  final DoctorListRepository _repository;

  List<DoctorModel> _allDoctors = [];
  List<String> _selectedIds = [];
  List<String> _selectedNames = [];
  bool _isLoading = true;

  String _searchQuery = '';

  SpecialistSelectionViewmodel({required DoctorListRepository repository})
    : _repository = repository;

  bool get isLoading => _isLoading;
  List<DoctorModel> get allDoctors => _allDoctors;
  List<String> get selectedIds => _selectedIds;
  List<String> get selectedNames => _selectedNames;

  List<DoctorModel> get filteredDoctors {
    if (_searchQuery.isEmpty) return _allDoctors;
    return _allDoctors
        .where(
          (doctor) =>
              doctor.nome.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();
  }

  void init(List<String> initialIds) {
    _selectedIds = List.from(initialIds);
    _loadDoctors();
  }

  Future<void> _loadDoctors() async {
    try {
      final doctors = await _repository.getAllSpecialists();
      final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

      doctors.removeWhere((doc) => doc.id == currentUserId);

      _allDoctors = doctors;

      _selectedNames = _allDoctors
          .where((d) => _selectedIds.contains(d.id))
          .map((d) => d.nome)
          .toList();
    } catch (e) {
      print("Erro ao carregar especialistas: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void toggleSelection(DoctorModel doctor) {
    if (_selectedIds.contains(doctor.id)) {
      _selectedIds.remove(doctor.id);
      _selectedNames.remove(doctor.nome);
    } else {
      _selectedIds.add(doctor.id);
      _selectedNames.add(doctor.nome);
    }
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }
}
