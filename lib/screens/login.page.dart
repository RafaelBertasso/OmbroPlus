import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ValueNotifier<bool> _obscurePassword = ValueNotifier(true);
  final _emailEspecialistaController = TextEditingController();
  final _passwordEspecialistaController = TextEditingController();
  final _emailPacienteController = TextEditingController();
  final _passwordPacienteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailEspecialistaController.dispose();
    _passwordEspecialistaController.dispose();
    _emailPacienteController.dispose();
    _passwordPacienteController.dispose();
    _obscurePassword.dispose();
    super.dispose();
  }

  Future<String> getUserRole() async {
    final user = _auth.currentUser;
    if (user == null) {
      return 'deslogado';
    }

    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data();
        return data?['role'];
      }
    } catch (e) {
      print('Erro ao buscar a role do usuário: $e');
    }
    return 'cliente';
  }

  Future<void> _loginEspecialista(BuildContext context) async {
    if (_emailEspecialistaController.text.isEmpty ||
        _passwordEspecialistaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, preencha todos os campos.')),
      );
      return;
    }
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailEspecialistaController.text.trim(),
        password: _passwordEspecialistaController.text.trim(),
      );

      final role = await getUserRole();
      if (role == 'especialista') {
        Navigator.pushReplacementNamed(context, '/doctor-home');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Essa conta não é um especialista.')),
        );
        await _auth.signOut();
      }
    } on FirebaseAuthException catch (e) {
      String message;
      if (e.code == 'user-not-found') {
        message = 'Usuário não encontrado.';
      } else if (e.code == 'wrong-password') {
        message = 'Senha incorreta.';
      } else {
        message = 'Erro ao fazer login. Tente novamente.';
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao fazer login. Tente novamente.')),
      );
    }
  }

  Future<void> _loginPaciente(BuildContext context) async {
    if (_emailPacienteController.text.isEmpty ||
        _passwordPacienteController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, preencha todos os campos.')),
      );
      return;
    }
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailPacienteController.text.trim(),
        password: _passwordPacienteController.text.trim(),
      );

      final role = await getUserRole();
      if (role == 'paciente') {
        Navigator.pushReplacementNamed(context, '/patient-home');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Essa conta não é um paciente.')),
        );
        await _auth.signOut();
      }
    } on FirebaseAuthException catch (e) {
      String message;
      if (e.code == 'user-not-found') {
        message = 'Usuário não encontrado.';
      } else if (e.code == 'wrong-password') {
        message = 'Senha incorreta.';
      } else {
        message = 'Erro ao fazer login. Tente novamente.';
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao fazer login. Tente novamente.')),
      );
    }
  }

  Widget _buildFormLogin({
    required TextEditingController emailController,
    required TextEditingController passwordController,
    required VoidCallback onLoginPressed,
    bool showRegister = false,
  }) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          TextField(
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(labelText: 'E-mail'),
            controller: emailController,
          ),
          SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 8),
              ValueListenableBuilder<bool>(
                valueListenable: _obscurePassword,
                builder: (context, value, child) {
                  return TextField(
                    controller: passwordController,
                    obscureText: value,
                    decoration: InputDecoration(
                      hintText: 'Senha',
                      suffixIcon: IconButton(
                        onPressed: () {
                          _obscurePassword.value = !value;
                        },
                        icon: Icon(
                          value ? Icons.visibility_off : Icons.visibility,
                        ),
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 8),
            ],
          ),
          SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF0E382C),
              minimumSize: Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: onLoginPressed,
            child: Text('Entrar', style: TextStyle(color: Colors.white)),
          ),
          SizedBox(height: 16),
          if (showRegister)
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/patient-register');
              },
              child: Text(
                'Criar Conta',
                style: GoogleFonts.openSans(
                  fontSize: 16,
                  color: Color(0xFF0E382C),
                ),
              ),
            ),
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, '/forgot-password');
            },
            child: Text(
              'Esqueceu a senha?',
              style: GoogleFonts.openSans(
                fontSize: 16,
                color: Color(0xFF0E382C),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF4F7F6),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 48),
              Image.asset(
                'assets/images/logo-app.png',
                width: 250,
                height: 250,
              ),
              SizedBox(height: 10),
              Container(
                width: 380,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    TabBar(
                      controller: _tabController,
                      labelColor: Color(0xFF0E382C),
                      unselectedLabelColor: Color.fromARGB(255, 87, 173, 131),
                      indicatorColor: Color(0xFF0E382C),
                      tabs: [
                        Tab(text: 'Especialista'),
                        Tab(text: 'Paciente'),
                      ],
                    ),
                    SizedBox(
                      height: 420,
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildFormLogin(
                            emailController: _emailEspecialistaController,
                            passwordController: _passwordEspecialistaController,
                            onLoginPressed: () => _loginEspecialista(context),
                            showRegister: false,
                          ),
                          _buildFormLogin(
                            emailController: _emailPacienteController,
                            passwordController: _passwordPacienteController,
                            onLoginPressed: () => _loginPaciente(context),
                            showRegister: true,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
