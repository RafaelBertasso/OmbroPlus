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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _loginEspecialista(BuildContext context) async {
    //   if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
    //     final snackBar = SnackBar(content: Text('Preencha todos os campos'));
    //     ScaffoldMessenger.of(context).showSnackBar(snackBar);
    //     return;
    //   }
    //   try {
    //     UserCredential credential = await _auth.signInWithEmailAndPassword(
    //       email: _emailController.text,
    //       password: _passwordController.text
    //     );

    //     final doc = await FirebaseFirestore.instance
    //         .collection('especialista')
    //         .doc(credential.user!.uid)
    //         .get();

    //     if (doc.exists) {
    Navigator.pushReplacementNamed(context, '/doctor-home');
    //     } else {
    //       ScaffoldMessenger.of(context).showSnackBar(
    //         SnackBar(content: Text('Conta não cadastrada como especialista')),
    //       );
    //       await FirebaseAuth.instance.signOut();
    //     }
    //   } on FirebaseAuthException catch (e) {
    //     String message = 'Erro ao fazer login';
    //     if (e.code == 'user-not-found') {
    //       message = 'Usuário não encontrado';
    //     } else if (e.code == 'wrong-password') {
    //       message = 'Senha incorreta';
    //     }
    //     ScaffoldMessenger.of(
    //       context,
    //     ).showSnackBar(SnackBar(content: Text(message)));
    //   }
  }

  Widget _buildFormLogin() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          TextField(
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(labelText: 'E-mail'),
            controller: _emailController,
          ),
          SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(labelText: 'Senha'),
            obscureText: true,
            controller: _passwordController,
          ),
          SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF8FC1A9),
              minimumSize: Size(double.infinity, 48),
            ),
            onPressed: () => _loginEspecialista(context),
            child: Text('Entrar', style: TextStyle(color: Colors.black)),
          ),
          SizedBox(height: 16),
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, '/forgot-password');
            },
            child: Text(
              'Esqueceu a senha?',
              style: GoogleFonts.openSans(
                fontSize: 16,
                color: Color(0xFF2A5C7D),
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
                      labelColor: Color(0xFF2A5C7D),
                      unselectedLabelColor: Color.fromARGB(255, 87, 173, 131),
                      indicatorColor: Color(0xFF2A5C7D),
                      tabs: [
                        Tab(text: 'Especialista'),
                        Tab(text: 'Paciente'),
                      ],
                    ),
                    SizedBox(
                      height: 420,
                      child: TabBarView(
                        controller: _tabController,
                        children: [_buildFormLogin(), _buildFormLogin()],
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
