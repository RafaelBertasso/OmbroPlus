import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class NewExercisePage extends StatefulWidget {
  const NewExercisePage({super.key});

  @override
  State<NewExercisePage> createState() => _NewExercisePageState();
}

class _NewExercisePageState extends State<NewExercisePage> {
  String? videoFileName;
  XFile? videoFile;
  final _picker = ImagePicker();

  void _showVideoOptions() {
    showModalBottomSheet(
      backgroundColor: Color(0xFF0E382C),
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.video_library, color: Colors.white),
              title: Text(
                'Galeria',
                style: GoogleFonts.openSans(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () async {
                Navigator.pop(context);
                final XFile? video = await _picker.pickVideo(
                  source: ImageSource.gallery,
                );
                if (video != null) {
                  setState(() {
                    videoFile = video;
                    videoFileName = video.name;
                  });
                }
              },
            ),
            ListTile(
              leading: Icon(Icons.videocam, color: Colors.white),
              title: Text(
                'Câmera',
                style: GoogleFonts.openSans(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () async {
                Navigator.pop(context);
                final XFile? video = await _picker.pickVideo(
                  source: ImageSource.camera,
                );
                if (video != null) {
                  setState(() {
                    videoFile = video;
                    videoFileName = video.name;
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF4F7F6),
      appBar: AppBar(
        backgroundColor: Color(0xFF0E382C),
        title: Text(
          'Adicionar Exercício',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        iconTheme: IconThemeData(color: Colors.white, size: 26),
        elevation: 0.4,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Exercício',
                style: GoogleFonts.openSans(fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 6),
              TextField(
                decoration: InputDecoration(
                  hint: Text(
                    'Nome do exercício',
                    style: GoogleFonts.openSans(color: Colors.black54),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(11),
                  ),
                  fillColor: const Color.fromARGB(140, 181, 181, 181),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                  filled: true,
                ),
              ),
              SizedBox(height: 12),
              Text(
                'Descrição',
                style: GoogleFonts.openSans(fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 6),
              TextField(
                decoration: InputDecoration(
                  hint: Text(
                    'Descrição do exercício',
                    style: GoogleFonts.openSans(color: Colors.black54),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(11),
                  ),
                  fillColor: const Color.fromARGB(140, 181, 181, 181),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                  filled: true,
                ),
              ),
              SizedBox(height: 12),
              Text(
                'Número de Séries',
                style: GoogleFonts.openSans(fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 6),
              TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hint: Text(
                    'Número de Séries do exercício',
                    style: GoogleFonts.openSans(color: Colors.black54),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(11),
                  ),
                  fillColor: const Color.fromARGB(140, 181, 181, 181),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                  filled: true,
                ),
              ),
              SizedBox(height: 12),
              Text(
                'Número de Repetições',
                style: GoogleFonts.openSans(fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 6),
              TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hint: Text(
                    'Número de Repetições em cada série.',
                    style: GoogleFonts.openSans(color: Colors.black54),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(11),
                  ),
                  fillColor: const Color.fromARGB(140, 181, 181, 181),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                  filled: true,
                ),
              ),
              SizedBox(height: 12),
              Text(
                'Vídeo de ajuda',
                style: GoogleFonts.openSans(fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 6),
              OutlinedButton(
                onPressed: _showVideoOptions,
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: const Color.fromARGB(140, 181, 181, 181),
                  side: BorderSide.none,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(11),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Center(
                        child: Text(
                          videoFileName != null
                              ? videoFileName!
                              : 'Selecionar vídeo (Galeria ou Câmera)',
                          style: GoogleFonts.openSans(
                            color: Colors.black54,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 26),
              ElevatedButton(
                onPressed: () {
                  // Lógica para salvar o novo exercício
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF0E382C),
                  minimumSize: Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9),
                  ),
                ),
                child: Text(
                  'Salvar',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
