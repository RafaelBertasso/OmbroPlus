import 'package:Ombro_Plus/components/section.title.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:youtube_parser/youtube_parser.dart';

class NewExercisePage extends StatefulWidget {
  const NewExercisePage({super.key});

  @override
  State<NewExercisePage> createState() => _NewExercisePageState();
}

class _NewExercisePageState extends State<NewExercisePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _youtubeUrlController = TextEditingController();

  bool _isSaving = false;
  String? _extractedYoutubeId;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _youtubeUrlController.dispose();
    super.dispose();
  }

  String? _validateAndExtractYoutubeId(String? url) {
    final videoId = getIdFromUrl(url!);

    if (videoId == null) {
      return 'URL do YouTube inválida.';
    }

    _extractedYoutubeId = videoId;
    return null;
  }

  Future<void> _saveNewExercise() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });
    final specialistId = FirebaseAuth.instance.currentUser!.uid;

    if (specialistId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro: Usuário não autenticado.')));
      setState(() {
        _isSaving = false;
        return;
      });
    }
    try {
      await FirebaseFirestore.instance.collection('exercicios').add({
        'nome': _nameController.text.trim(),
        'descricao': _descriptionController.text.trim(),
        'youtubeId': _extractedYoutubeId,
        'criadoEm': FieldValue.serverTimestamp(),
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Exercício salvo com sucesso!')));
      Navigator.pop(context, true);
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar exercício. Tente novamente.')),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF4F7F6),
      appBar: AppBar(
        backgroundColor: Color(0xFF0E382C),
        title: Text(
          'Adicionar Exercício',
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        iconTheme: IconThemeData(color: Colors.white, size: 26),
        elevation: 0.4,
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionTitle(title: 'Identificação do Exercício'),
                SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  
                  decoration: InputDecoration(
                    labelText: 'Nome do Exercício',
                    hintText: 'Ex: Elevação Lateral do Ombro',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: Color(0xFFF4F7F6),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'O nome é obrigatório.' : null,
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Descrição e Instruções',
                    hintText: 'Passos detalhados para o paciente',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: Color(0xFFF4F7F6),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 6,
                  validator: (value) =>
                      value!.isEmpty ? 'A descrição é obrigatória.' : null,
                ),
                SizedBox(height: 30),
                SectionTitle(title: 'Vídeo de Ajuda'),
                SizedBox(height: 16),
                TextFormField(
                  controller: _youtubeUrlController,
                  keyboardType: TextInputType.url,
                  decoration: InputDecoration(
                    labelText: 'Link do Youtube',
                    hintText: 'Cole o link do seu vídeo aqui',
                    prefixIcon: Icon(
                      Icons.videocam_rounded,
                      color: Color(0xFF0E382C),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: Color(0xFFF4F7F6),
                  ),
                  validator: _validateAndExtractYoutubeId,
                ),
                SizedBox(height: 8),
                Text(
                  'O vídeo será exibido no aplicativo do paciente. Use um vídeo claro e objetivo.',
                  style: GoogleFonts.openSans(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveNewExercise,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF0E382C),
                      minimumSize: Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9),
                      ),
                    ),
                    child: _isSaving
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text(
                            'Salvar Exercício',
                            style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
