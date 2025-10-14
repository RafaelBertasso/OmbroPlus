import 'dart:convert';
import 'dart:io';

import 'package:Ombro_Plus/components/app.logo.dart';
import 'package:Ombro_Plus/components/build.info.row.dart';
import 'package:Ombro_Plus/components/config.tile.dart';
import 'package:Ombro_Plus/components/patient.navbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

extension EnumExtension on Enum {
  String get displayName {
    final name = this.name;
    switch (name) {
      case 'direito':
        return 'Direito';
      case 'esquerdo':
        return 'Esquerdo';
      case 'ambos':
        return 'Ambos';
      case 'leve':
        return 'Leve';
      case 'moderado':
        return 'Moderada';
      case 'intensa':
        return 'Intensa';
      case 'limitada':
        return 'Limitada';
      case 'parcial':
        return 'Parcial';
      case 'boa':
        return 'Boa';
      default:
        return name;
    }
  }
}

enum LadoAfetado { direito, esquerdo, ambos }

enum NivelDor { leve, moderado, intensa }

enum NivelMobilidade { limitada, parcial, boa }

class PatientProfilePage extends StatefulWidget {
  const PatientProfilePage({super.key});

  @override
  State<PatientProfilePage> createState() {
    return _PatientProfilePageState();
  }
}

class _PatientProfilePageState extends State<PatientProfilePage> {
  final int _selectedIndex = 4;
  final _auth = FirebaseAuth.instance;
  late Future<Map<String, dynamic>?> _userData;
  String? _profileImage;
  final ImagePicker _picker = ImagePicker();

  void _onTabTapped(BuildContext context, int index) {
    if (index == _selectedIndex) return;
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/patient-home');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/patient-dashboard');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/patient-protocols');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/patient-main-chat');
        break;
      default:
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    _userData = _fetchUserData();
  }

  Future<Map<String, dynamic>?> _fetchUserData() async {
    final user = _auth.currentUser;
    if (user == null) {
      return null;
    }
    final doc = await FirebaseFirestore.instance
        .collection('pacientes')
        .doc(user.uid)
        .get();
    final data = doc.data();
    if (data != null && data['profileImage'] != null) {
      _profileImage = data['profileImage'];
    }
    return data;
  }

  void _showImageOptions() {
    showModalBottomSheet(
      backgroundColor: Color(0xFF0E382C),
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.photo_library, color: Color(0xFFF4F7F6)),
              title: Text(
                'Galeria',
                style: GoogleFonts.openSans(
                  color: Color(0xFFF4F7F6),
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () => _pickImage(ImageSource.gallery),
            ),
            ListTile(
              leading: Icon(Icons.camera_alt, color: Color(0xFFF4F7F6)),
              title: Text(
                'Câmera',
                style: GoogleFonts.openSans(
                  color: Color(0xFFF4F7F6),
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () => _pickImage(ImageSource.camera),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    Navigator.pop(context);
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      List<int>? compressedBytes;

      if (Platform.isAndroid || Platform.isIOS) {
        compressedBytes = await FlutterImageCompress.compressWithFile(
          image.path,
          minHeight: 600,
          minWidth: 400,
          quality: 50,
        );
      } else {
        compressedBytes = await image.readAsBytes();
      }
      if (compressedBytes != null) {
        final base64Image = base64Encode(compressedBytes);
        final user = _auth.currentUser;
        if (user != null) {
          await FirebaseFirestore.instance
              .collection('pacientes')
              .doc(user.uid)
              .update({'profileImage': base64Image});

          setState(() {
            _profileImage = base64Image;
          });
        }
      }
    }
  }

  String _formatDificuldades(List<dynamic>? dificuldades) {
    if (dificuldades == null || dificuldades.isEmpty) {
      return 'Nenhuma informada';
    }
    if (dificuldades.length <= 2) {
      return dificuldades.join(', ');
    }
    final buffer = StringBuffer();
    for (int i = 0; i < dificuldades.length; i++) {
      buffer.write(dificuldades[i]);

      if (i < dificuldades.length - 1) {
        if ((i + 1) % 2 == 0) {
          buffer.write(',\n');
        } else {
          buffer.write(', ');
        }
      }
    }
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _userData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: Color(0xFF0E382C)),
            );
          }
          if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
            return Center(child: Text('Não foi possível carregar o perfil'));
          }
          final userData = snapshot.data!;
          final nome = userData['nome'] ?? 'Paciente';
          final email = userData['email'] ?? '';
          final telefone = userData['telefone'] ?? 'Não informado';
          final dataNascimento = userData['data_nascimento'] ?? 'Não informado';
          final sexo = userData['sexo'] ?? 'Não informado';
          final diagnostico =
              userData['diagnosticoPrincipal'] ?? 'Não informado';
          final ladoAfetado = userData['ladoAfetado'] != null
              ? LadoAfetado.values
                    .firstWhere((e) => e.name == userData['ladoAfetado'])
                    .displayName
              : 'Não informado';
          final medicoResponsavel =
              userData['medicoResponsavel'] ?? 'Não informado';
          final nivelDor = userData['nivelDor'] != null
              ? NivelDor.values
                    .firstWhere((e) => e.name == userData['nivelDor'])
                    .displayName
              : 'Não informado';
          final nivelMobilidade = userData['mobilidadeOmbro'] != null
              ? NivelMobilidade.values
                    .firstWhere((e) => e.name == userData['mobilidadeOmbro'])
                    .displayName
              : 'Não informado';
          final objetivo = userData['objetivoTratamento'] ?? 'Não informado';
          final dificuldades = _formatDificuldades(
            userData['dificuldadesPrincipais'],
          );
          return Column(
            children: [
              SizedBox(
                height: 300,
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    AppLogo(),
                    Positioned(
                      top: 170,
                      child: GestureDetector(
                        onTap: _showImageOptions,
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            CircleAvatar(
                              radius: 60,
                              backgroundColor: Color(0xFF0E382C),
                              child: _profileImage != null
                                  ? ClipOval(
                                      child: Image.memory(
                                        base64Decode(_profileImage!),
                                        width: 120,
                                        height: 120,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : Text(
                                      (nome.isNotEmpty && nome.length >= 2)
                                          ? nome.substring(0, 2).toUpperCase()
                                          : 'P',
                                      style: GoogleFonts.montserrat(
                                        fontSize: 48,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                            Container(
                              padding: EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Color(0xFFF4F7F6),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Color(0xFF0E382C),
                                  width: 2,
                                ),
                              ),
                              child: Icon(
                                Icons.photo_camera,
                                color: Color(0xFF0E382C),
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 100,
                      child: Column(
                        children: [
                          Text(
                            nome,
                            style: GoogleFonts.montserrat(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            diagnostico,
                            style: GoogleFonts.openSans(
                              fontSize: 15,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  children: [
                    Row(
                      children: [
                        Text(
                          'Dados Pessoais',
                          style: GoogleFonts.openSans(
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                            color: Color(0xFF0E382C),
                          ),
                        ),
                        Spacer(),
                        IconButton(
                          onPressed: () async {
                            final shouldReload = await Navigator.pushNamed(
                              context,
                              '/patient-edit-profile',
                              arguments: {'id': _auth.currentUser?.uid},
                            );
                            if (shouldReload == true) {
                              setState(() {
                                _userData = _fetchUserData();
                              });
                            }
                          },
                          icon: Icon(Icons.edit, color: Color(0XFF0E382C)),
                        ),
                      ],
                    ),
                    Divider(color: Color(0xFF0E382C)),
                    BuildInfoRow(
                      label: 'E-mail',
                      value: email,
                      icon: Icons.email_outlined,
                    ),
                    BuildInfoRow(
                      label: 'Telefone',
                      value: telefone,
                      icon: Icons.phone_android_outlined,
                    ),
                    BuildInfoRow(
                      label: 'Data Nascimento',
                      value: dataNascimento,
                      icon: Icons.date_range_outlined,
                    ),
                    BuildInfoRow(
                      label: 'Sexo',
                      value: sexo,
                      icon: FontAwesomeIcons.venusMars,
                    ),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        Text(
                          'Meu Tratamento',
                          style: GoogleFonts.openSans(
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                            color: Color(0xFF0E382C),
                          ),
                        ),
                        Spacer(),
                        IconButton(
                          onPressed: () async {
                            final shouldReload = await Navigator.pushNamed(
                              context,
                              '/patient-clinical-form',
                              arguments: {'id': _auth.currentUser!.uid},
                            );
                            if (shouldReload == true) {
                              setState(() {
                                _userData = _fetchUserData();
                              });
                            }
                          },
                          icon: Icon(Icons.edit, color: Color(0xFF0E382C)),
                        ),
                      ],
                    ),
                    Divider(color: Color(0xFF0E382C)),
                    BuildInfoRow(
                      label: 'Diagnóstico',
                      value: diagnostico,
                      icon: Icons.medical_information_outlined,
                    ),
                    BuildInfoRow(
                      label: 'Lado Afetado',
                      value: ladoAfetado,
                      icon: Icons.accessibility_new_outlined,
                    ),
                    BuildInfoRow(
                      label: 'Especialista',
                      value: medicoResponsavel,
                      icon: Icons.local_hospital_outlined,
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Situação Funcional',
                      style: GoogleFonts.openSans(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        color: Color(0xFF0E382C),
                      ),
                    ),
                    Divider(color: Color(0xFF0E382C)),
                    BuildInfoRow(
                      label: 'Nível de Dor',
                      value: nivelDor,
                      icon: Icons.sentiment_dissatisfied_outlined,
                    ),
                    BuildInfoRow(
                      label: 'Mobilidade',
                      value: nivelMobilidade,
                      icon: Icons.rotate_right_outlined,
                    ),
                    BuildInfoRow(
                      label: 'Dificuldades',
                      value: dificuldades,
                      icon: Icons.warning_amber_outlined,
                    ),
                    BuildInfoRow(
                      label: 'Meta Principal',
                      value: objetivo,
                      icon: Icons.flag_outlined,
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Configurações',
                      style: GoogleFonts.openSans(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        color: Color(0xFF0E382C),
                      ),
                    ),
                    Divider(color: Color(0xFF0E382C)),
                    ConfigTile(
                      icon: Icons.notifications_active_outlined,
                      onTap: () {},
                      title: 'Notificações',
                    ),
                    ConfigTile(
                      icon: Icons.lock_outline,
                      onTap: () =>
                          Navigator.pushNamed(context, '/forgot-password'),
                      title: 'Mudar Senha',
                    ),
                    ConfigTile(
                      icon: Icons.description_outlined,
                      onTap: () {},
                      title: 'Termos de Uso',
                    ),
                    SizedBox(height: 10),
                    Padding(
                      padding: EdgeInsetsGeometry.symmetric(horizontal: 8),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _auth.signOut().then((_) {
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              '/login',
                              (route) => false,
                            );
                          });
                        },
                        icon: Icon(Icons.logout_outlined, color: Colors.white),
                        label: Text(
                          'Sair',
                          style: GoogleFonts.openSans(
                            fontWeight: FontWeight.w600,
                            fontSize: 17,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF0E382C),
                          minimumSize: Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadiusGeometry.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: PatientNavbar(
        currentIndex: _selectedIndex,
        onTap: (index) => _onTabTapped(context, index),
      ),
    );
  }
}
