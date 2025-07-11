import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

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

  Widget _buildEspecialistaForm() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            TextField(decoration: InputDecoration(labelText: 'E-mail')),
            SizedBox(height: 10),
            TextField(
              decoration: InputDecoration(labelText: 'Senha'),
              obscureText: true,
            ),
            SizedBox(height: 15),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF8FC1A9),
                minimumSize: Size(double.infinity, 48),
              ),
              onPressed: () {},
              child: Text(
                'Entrar',
                style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0)),
              ),
            ),
            SizedBox(height: 10),
            Text('ou'),
            SizedBox(height: 10),
            OutlinedButton(
              onPressed: () => Navigator.pushNamed(context, '/register'),
              child: Text(
                'Criar Conta',
                style: TextStyle(color: Color(0xFF2A5C7D)),
              ),
            ),
            SizedBox(height: 10),
            SizedBox(height: 10),
            TextButton(onPressed: () {}, child: Text('Esqueceu a senha?')),
          ],
        ),
      ),
    );
  }

  Widget _buildPacienteForm() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          TextField(decoration: InputDecoration(labelText: 'E-mail')),
          SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(labelText: 'Senha'),
            obscureText: true,
          ),
          SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF8FC1A9),
              minimumSize: Size(double.infinity, 48),
            ),
            onPressed: () {},
            child: Text('Entrar', style: TextStyle(color: Colors.black)),
          ),
          SizedBox(height: 16),
          TextButton(onPressed: () {}, child: Text('Esqueceu a senha?')),
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
                        children: [
                          _buildEspecialistaForm(),
                          _buildPacienteForm(),
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
