import 'package:Ombro_Plus/repositories/protocol.repository.dart';
import 'package:flutter/material.dart';
import 'package:youtube_parser/youtube_parser.dart';

class NewExerciseViewModel extends ChangeNotifier {
  final ProtocolRepository repository;

  NewExerciseViewModel({required this.repository});

  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  String? extractYoutubeId(String url) {
    if (url.isEmpty) return null;
    return getIdFromUrl(url);
  }

  Future<bool> saveExercise({
    required String nome,
    required String descricao,
    required String youtubeUrl,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      String? videoId;
      if (youtubeUrl.isNotEmpty) {
        videoId = extractYoutubeId(youtubeUrl);
        if (videoId == null) {
          throw Exception('URL do Youtube inválida.');
        }
      }

      await repository.createExercise(
        nome: nome,
        descricao: descricao,
        youtubeId: videoId,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll("Exception:", "");
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
