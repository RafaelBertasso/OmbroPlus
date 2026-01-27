import 'package:Ombro_Plus/viewmodels/patient/exercise_details.viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DetailsExercisePage extends StatefulWidget {
  const DetailsExercisePage({super.key});

  @override
  State<DetailsExercisePage> createState() => _DetailsExercisePageState();
}

class _DetailsExercisePageState extends State<DetailsExercisePage> {
  YoutubePlayerController? _youtubeController;
  bool _isFullScreen = false;

  String? _protocolId;
  String? _exerciseId;
  List<dynamic>? _allDailyExercises;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadArgumentsAndData();
    });
  }

  void _loadArgumentsAndData() {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args == null) return;

    _protocolId = args['protocoloId'];
    _exerciseId = args['exercicioId'];
    _allDailyExercises = args['allDailyExercises'];

    final patientId = FirebaseAuth.instance.currentUser?.uid;

    if (_protocolId != null && _exerciseId != null && patientId != null) {
      context.read<ExerciseDetailsViewModel>().loadExerciseData(
        _exerciseId!,
        _protocolId!,
        patientId,
      );
    }
  }

  void _initializeYoutubeController(String videoId) {
    if (_youtubeController != null &&
        _youtubeController!.initialVideoId == videoId) {
      return;
    }

    if (_youtubeController != null) {
      _youtubeController!.dispose();
    }

    _youtubeController = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
        loop: false,
        isLive: false,
        forceHD: false,
        enableCaption: false,
      ),
    )..addListener(_listener);

    if (mounted) setState(() {});
  }

  void _listener() {
    if (!mounted || _youtubeController == null) return;
    final newIsFullScreen = _youtubeController!.value.isFullScreen;

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

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    _youtubeController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExerciseDetailsViewModel>(
      builder: (context, viewModel, child) {
        if (!viewModel.isLoading && viewModel.exerciseData != null) {
          final youtubeId = viewModel.exerciseData!['youtubeId'];

          if (youtubeId != null && youtubeId.isNotEmpty) {
            bool needsInit =
                _youtubeController == null ||
                _youtubeController!.initialVideoId != youtubeId;

            if (needsInit) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  _initializeYoutubeController(youtubeId);
                }
              });
            }
          }
        }

        if (viewModel.isLoading) {
          return const Scaffold(
            backgroundColor: Color(0xFFF4F7F6),
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFF0E382C)),
            ),
          );
        }

        if (viewModel.error != null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text("Erro"),
              backgroundColor: const Color(0xFF0E382C),
              centerTitle: true,
            ),
            body: Center(child: Text(viewModel.error!)),
          );
        }

        final data = viewModel.exerciseData;
        if (data == null)
          return const Scaffold(body: Center(child: Text("Sem dados")));

        final String name = data['nome'] ?? 'Exercício';
        final String description = data['descricao'] ?? 'Sem instruções';

        final bool hasVideo = _youtubeController != null;

        final bool isCompletedToday = viewModel.isCompletedToday;
        final bool isMarking = viewModel.isMarkingComplete;

        final buttonText = isCompletedToday
            ? 'CONCLUÍDO HOJE'
            : 'FINALIZAR EXERCÍCIO';
        final buttonColor = isCompletedToday
            ? Colors.green.shade400
            : const Color(0xFF0E382C);

        return Scaffold(
          backgroundColor: const Color(0xFFF4F7F6),
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
                  centerTitle: true,
                  backgroundColor: const Color(0xFF0E382C),
                  iconTheme: const IconThemeData(color: Colors.white),
                ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (hasVideo)
                SizedBox(
                  height: _isFullScreen
                      ? MediaQuery.of(context).size.height
                      : 220,
                  width: double.infinity,
                  child: YoutubePlayer(
                    controller: _youtubeController!,
                    showVideoProgressIndicator: true,
                    progressIndicatorColor: const Color(0xFF0E382C),
                    topActions: <Widget>[
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: Text(
                          _youtubeController!.metadata.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18.0,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  height: 220,
                  width: double.infinity,
                  color: Colors.grey[300],
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.videocam_off,
                        size: 50,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Carregando vídeo...",
                        style: GoogleFonts.openSans(color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Instruções Detalhadas',
                        style: GoogleFonts.montserrat(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF333333),
                        ),
                      ),
                      const Divider(color: Colors.black26, height: 20),
                      Text(
                        description,
                        style: GoogleFonts.openSans(
                          fontSize: 16,
                          color: Colors.black87,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 40),

                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton.icon(
                          onPressed: isCompletedToday || isMarking
                              ? null
                              : () async {
                                  final patientId =
                                      FirebaseAuth.instance.currentUser?.uid;
                                  if (patientId != null &&
                                      _protocolId != null &&
                                      _exerciseId != null) {
                                    final sessionFinished = await viewModel
                                        .markAsComplete(
                                          _protocolId!,
                                          patientId,
                                          _exerciseId!,
                                          _allDailyExercises ?? [],
                                        );

                                    if (context.mounted) {
                                      if (sessionFinished) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Sessão diária COMPLETA! Parabéns.',
                                            ),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                      } else {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Exercício concluído!',
                                            ),
                                            backgroundColor: Color(0xFF0E382C),
                                          ),
                                        );
                                      }
                                      Navigator.pop(context, true);
                                    }
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: buttonColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          icon: isMarking
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : Icon(
                                  isCompletedToday
                                      ? Icons.done_all
                                      : Icons.check_circle_outline,
                                  color: Colors.white,
                                  size: 28,
                                ),
                          label: Text(
                            isMarking ? "SALVANDO..." : buttonText,
                            style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
