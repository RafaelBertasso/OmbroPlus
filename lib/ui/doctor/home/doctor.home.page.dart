import 'package:Ombro_Plus/components/activity.item.dart';
import 'package:Ombro_Plus/components/doctor.navbar.dart';
import 'package:Ombro_Plus/viewmodels/doctor_home.viewmodel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class DoctorHomePage extends StatefulWidget {
  const DoctorHomePage({super.key});

  @override
  State<DoctorHomePage> createState() => _DoctorHomePageState();
}

class _DoctorHomePageState extends State<DoctorHomePage> {
  final int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DoctorHomeViewModel>().loadDoctorName();
    });
  }

  void _onTabTapped(int index) {
    if (index == _selectedIndex) return;
    switch (index) {
      case 1:
        Navigator.pushReplacementNamed(context, '/doctor-dashboard');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/doctor-protocols');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/doctor-main-chat');
        break;
      case 4:
        Navigator.pushReplacementNamed(context, '/doctor-profile');
        break;
      default:
        break;
    }
  }

  IconData _getIconForActivityType(String type) {
    switch (type) {
      case 'NEW_PATIENT':
        return Icons.person_add;
      case 'PROTOCOL_FINISHED':
        return Icons.star;
      case 'PROTOCOL_CREATED':
        return Icons.insert_invitation_outlined;
      default:
        return Icons.info_outline;
    }
  }

  Color _getColorForActivityType(String type) {
    switch (type) {
      case 'NEW_PATIENT':
        return const Color(0xFF0E382C);
      case 'PROTOCOL_CREATED':
        return Colors.blue.shade600;
      case 'PROTOCOL_FINISHED':
        return Colors.amber.shade800;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Usamos o Consumer para reconstruir quando o nome carregar
    return Consumer<DoctorHomeViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          backgroundColor: const Color(0xFFF4F7F6),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 18, bottom: 8),
                child: SizedBox(
                  height: 100,
                  child: Center(
                    child: Image.asset(
                      'assets/images/logo-app.png',
                      width: 100,
                      height: 100,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18.0,
                      vertical: 24,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Nome do Médico (vindo do ViewModel)
                        Text(
                          'Bem vindo, ${viewModel.doctorName}',
                          style: GoogleFonts.montserrat(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Botões de Ação
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF0E382C),
                                  minimumSize: const Size(0, 48),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () => Navigator.pushNamed(
                                  context,
                                  '/new-protocol',
                                ),
                                child: const Text(
                                  'Nova sessão',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromARGB(
                                    112,
                                    145,
                                    228,
                                    205,
                                  ),
                                  minimumSize: const Size(0, 48),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () =>
                                    Navigator.pushNamed(context, '/user-list'),
                                child: const Text(
                                  'Usuários',
                                  style: TextStyle(color: Color(0xFF0E382C)),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 60),

                        Text(
                          'Atividades Recentes',
                          style: GoogleFonts.montserrat(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Feed de Atividades (StreamBuilder conectado ao ViewModel)
                        StreamBuilder<QuerySnapshot>(
                          stream: viewModel.activityFeedStream,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(
                                  color: Color(0xFF0E382C),
                                ),
                              );
                            }
                            if (snapshot.hasError) {
                              return const Text(
                                'Erro ao carregar o feed',
                                style: TextStyle(color: Colors.red),
                              );
                            }

                            final documents = snapshot.data?.docs ?? [];
                            if (documents.isEmpty) {
                              return const Text(
                                'Nenhuma atividade recente encontrada.',
                              );
                            }

                            return ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: documents.length,
                              itemBuilder: (context, index) {
                                final activity =
                                    documents[index].data()
                                        as Map<String, dynamic>;
                                final type =
                                    activity['type'] as String? ?? 'DEFAULT';
                                final iconData = _getIconForActivityType(type);
                                final iconColor = _getColorForActivityType(
                                  type,
                                );

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: ActivityItem(
                                    title:
                                        activity['patientName'] ??
                                        'Desconhecido',
                                    subtitle: activity['message'] ?? '',
                                    icon: iconData,
                                    iconColor: iconColor,
                                  ),
                                );
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: DoctorNavbar(
            currentIndex: _selectedIndex,
            onTap: _onTabTapped,
          ),
        );
      },
    );
  }
}
