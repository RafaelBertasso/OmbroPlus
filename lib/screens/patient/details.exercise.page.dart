import 'package:Ombro_Plus/services/protocol.service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class DetailsExercisePage extends StatefulWidget {
  const DetailsExercisePage({super.key});

  @override
  State<DetailsExercisePage> createState() => _DetailsExercisePageState();
}

class _DetailsExercisePageState extends State<DetailsExercisePage> {
  String? _protocolId;
  String? _exerciseId;
  String? _patientId;

  List<Map<String, dynamic>>? _allDailyExercises;

  bool _isLoading = true;
  bool _isMarkingComplete = false;
  bool _isCompletedToday = false;
  bool _isFullScreen = false;

  Map<String, dynamic>? _exerciseData;
  late YoutubePlayerController _youtubeController;

  @override
  void initState() {
    super.initState();
    _patientId = FirebaseAuth.instance.currentUser?.uid;

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_protocolId == null) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

      _protocolId = args?['protocoloId'] as String?;
      _exerciseId = args?['exercicioId'] as String?;
      _allDailyExercises =
          args?['allDailyExercises'] as List<Map<String, dynamic>>?;

      if (_protocolId != null && _exerciseId != null) {
        _fetchExerciseData();
      } else if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _initializeYoutubeController(String videoId) {
    _youtubeController = YoutubePlayerController(
      initialVideoId: videoId,
      flags: YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
        loop: false,
        isLive: false,
      ),
    )..addListener(_listener);
  }

  void _listener() {
    if (!mounted) return;

    final newIsFullScreen = _youtubeController.value.isFullScreen;
    if (_isFullScreen != newIsFullScreen) {
      setState(() {
        _isFullScreen = newIsFullScreen;
      });
      if (newIsFullScreen) {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
      } else {
        SystemChrome.setEnabledSystemUIMode(
          SystemUiMode.manual,
          overlays: SystemUiOverlay.values,
        );
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ]);
      }
    }
  }

  Future<void> _fetchExerciseData() async {
    if (_exerciseId == null ||
        _patientId == null ||
        _protocolId == null ||
        !mounted) {
      return;
    }
    try {
      final doc = await FirebaseFirestore.instance
          .collection('exercicios')
          .doc(_exerciseId!)
          .get();
      if (!mounted) return;

      final completedTodayIds = await ProtocolServices()
          .fetchCompletedExercisesToday(_protocolId!, _patientId!);

      if (mounted) {
        final data = doc.data();
        final isCompleted = completedTodayIds.contains(_exerciseId);
        if (data != null && data['youtubeId'] != null) {
          _initializeYoutubeController(data['youtubeId']);
        }
        setState(() {
          _exerciseData = data;
          _isCompletedToday = isCompleted;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Erro ao carregar dados do exercício: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _markAsComplete() async {
    if (_protocolId == null ||
        _exerciseId == null ||
        _patientId == null ||
        _isMarkingComplete ||
        _isCompletedToday ||
        !mounted) {
      return;
    }
    if (_allDailyExercises == null || _allDailyExercises!.isEmpty) {
      print("Erro: Lista de exercícios diários não fornecida pela rota.");
      Navigator.pop(context, true);
      return;
    }

    setState(() => _isMarkingComplete = true);

    final service = ProtocolServices();

    try {
      await service.logExerciseCompletion(
        _protocolId!,
        _patientId!,
        _exerciseId!,
        true,
      );

      final currentLogs = await service.fetchCompletedExercisesToday(
        _protocolId!,
        _patientId!,
      );

      if (currentLogs.length == _allDailyExercises!.length) {
        final success = await service.markSessionCompleted(
          _protocolId!,
          _patientId!,
        );

        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Sessão diária COMPLETA! Progresso atualizado.'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
          return;
        }
      }

      if (mounted) {
        await _fetchExerciseData();
        setState(() {
          _isMarkingComplete = false;
        });
      }
    } catch (e) {
      print('Erro ao marcar como completo: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao finalizar exercício. Tente novamente.'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isMarkingComplete = false);
      }
    }
  }

  Widget _buildYoutubePlayer(String youtubeId) {
    return YoutubePlayer(
      controller: _youtubeController,
      showVideoProgressIndicator: true,
      progressIndicatorColor: Color(0xFF0E382C),
    );
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    _youtubeController.removeListener(_listener);
    _youtubeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF0E382C)),
        ),
      );
    }
    final data = _exerciseData;
    if (data == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Erro')),
        body: Center(child: Text('Dados do exercício não encontrados')),
      );
    }
    final String name = data['nome'] ?? 'Exercício';
    final String description = data['descricao'] ?? 'Sem instruções';
    final String youtubeId = data['youtubeId'] ?? '';

    final buttonText = _isCompletedToday
        ? 'CONCLUÍDO HOJE'
        : 'FINALIZAR EXERCÍCIO';
    return Scaffold(
      backgroundColor: Color(0xFFF4F7F6),
      appBar: _isFullScreen
          ? null
          : AppBar(
              title: Text(
                name,
                style: GoogleFonts.montserrat(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: Color(0xFF0E382C),
              iconTheme: IconThemeData(color: Colors.white),
            ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (youtubeId.isNotEmpty)
            SizedBox(
              height: _isFullScreen ? MediaQuery.of(context).size.height : 200,
              child: _buildYoutubePlayer(youtubeId),
            ),

          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Instruções Detalhadas',
                    style: GoogleFonts.montserrat(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Divider(color: Colors.black45),
                  SizedBox(height: 10),
                  Text(
                    description,
                    style: GoogleFonts.openSans(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _isCompletedToday ? null : _markAsComplete,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isCompletedToday
                            ? Colors.green.shade400
                            : Color(0xFF0E382C),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadiusGeometry.circular(10),
                        ),
                      ),
                      icon: _isMarkingComplete
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Icon(
                              _isCompletedToday
                                  ? Icons.done_all
                                  : Icons.check_circle_outline,
                              color: Colors.white,
                            ),
                      label: Text(
                        buttonText,
                        style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
