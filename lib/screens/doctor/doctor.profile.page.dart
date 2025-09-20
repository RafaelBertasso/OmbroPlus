import 'dart:convert';
import 'dart:io';

import 'package:Ombro_Plus/components/app.logo.dart';
import 'package:Ombro_Plus/components/doctor.navbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class DoctorProfilePage extends StatefulWidget {
  const DoctorProfilePage({super.key});

  @override
  State<DoctorProfilePage> createState() => _DoctorProfilePageState();
}

class _DoctorProfilePageState extends State<DoctorProfilePage> {
  final int _selectedIndex = 4;
  final _auth = FirebaseAuth.instance;
  final user = FirebaseAuth.instance.currentUser;
  late Future<Map<String, dynamic>?> _userData;
  String? _profileImage;
  final ImagePicker _picker = ImagePicker();

  void _onTabTapped(BuildContext context, int index) {
    if (index == _selectedIndex) return;
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/doctor-home');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/doctor-dashboard');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/doctor-protocols');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/doctor-main-chat');
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
        .collection('especialistas')
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
      backgroundColor: Color(0xFFF4F7F6),
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.photo_library, color: Color(0xFF0E382C)),
              title: Text(
                'Galeria',
                style: GoogleFonts.openSans(
                  color: Color(0xFF0E382C),
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () => _pickImage(ImageSource.gallery),
            ),
            ListTile(
              leading: Icon(Icons.camera_alt, color: Color(0xFF0E382C)),
              title: Text(
                'Câmera',
                style: GoogleFonts.openSans(
                  color: Color(0xFF0E382C),
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
              .collection('especialistas')
              .doc(user.uid)
              .update({'profileImage': base64Image});

          setState(() {
            _profileImage = base64Image;
          });
        }
      }
    }
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
            return Center(child: Text('Não foi possível carregar o perfil.'));
          }
          final userData = snapshot.data!;
          final nome = userData['nome'] ?? 'Especialista';
          final email = userData['email'] ?? '';
          final crefito = userData['crefito'] ?? 'Não informado';
          final crm = userData['crm'] ?? 'Não informado';
          return Column(
            children: [
              AppLogo(),
              Container(
                padding: EdgeInsets.only(top: 50, bottom: 15),
                alignment: Alignment.center,
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _showImageOptions,
                      child: CircleAvatar(
                        radius: 46,
                        backgroundColor: Color(0xFF0E382C),
                        child: _profileImage != null
                            ? ClipOval(
                                child: Image.memory(
                                  base64Decode(_profileImage!),
                                  width: 92,
                                  height: 92,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Icon(Icons.person, color: Colors.white, size: 54),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      nome,
                      style: GoogleFonts.montserrat(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      email,
                      style: GoogleFonts.openSans(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 18),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    Card(
                      color: Color(0xFFF4F7F6),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: ListTile(
                        leading: Icon(
                          Icons.account_circle,
                          color: Color(0xFF0E382C),
                          size: 30,
                        ),
                        title: Text(
                          'Dados Pessoais',
                          style: GoogleFonts.openSans(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        trailing: Icon(
                          Icons.arrow_forward_ios,
                          size: 18,
                          color: Colors.grey[400],
                        ),
                        onTap: () => Navigator.pushNamed(
                          context,
                          '/doctor-edit-profile',
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Dados Profissionais',
                      style: GoogleFonts.openSans(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(height: 8),
                    Card(
                      color: Color(0xFFF4F7F6),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (crefito != null &&
                                crefito.isNotEmpty &&
                                crefito != 'Não informado')
                              Text(
                                'CREFITO: $crefito',
                                style: GoogleFonts.openSans(fontSize: 16),
                              )
                            else if (crm != null &&
                                crm.isNotEmpty &&
                                crm != 'Não informado')
                              Text(
                                'CRM: $crm',
                                style: GoogleFonts.openSans(fontSize: 16),
                              )
                            else
                              Text(
                                'Dados profissionais não informados',
                                style: GoogleFonts.openSans(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Configurações',
                      style: GoogleFonts.openSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 8),
                    Card(
                      color: Color(0xFFF4F7F6),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: ListTile(
                        leading: Icon(
                          Icons.settings,
                          color: Color(0xFF0E382C),
                          size: 30,
                        ),
                        title: Text(
                          'Gerenciar Conta',
                          style: GoogleFonts.openSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        trailing: Icon(
                          Icons.arrow_forward_ios,
                          size: 18,
                          color: Colors.grey[400],
                        ),
                        onTap: () {
                          //TODO: criar a tela de configurações
                        },
                      ),
                    ),
                    SizedBox(height: 30),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
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
                        icon: Icon(Icons.logout, color: Colors.white),
                        label: Text(
                          'Sair',
                          style: GoogleFonts.openSans(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 17,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF0E382C),
                          minimumSize: Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
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

      bottomNavigationBar: DoctorNavbar(
        currentIndex: _selectedIndex,
        onTap: (index) => _onTabTapped(context, index),
      ),
    );
  }
}
