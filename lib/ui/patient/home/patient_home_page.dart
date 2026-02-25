import 'package:Ombro_Plus/ui/patient/home/session_execution_page.dart';
import 'package:Ombro_Plus/ui/shared/widgets/app_logo.dart';
import 'package:Ombro_Plus/ui/patient/home/widgets/mini_metric_card.dart';
import 'package:Ombro_Plus/ui/shared/widgets/navbar.dart';
import 'package:Ombro_Plus/ui/patient/home/widgets/unread_messages_summary.dart';
import 'package:Ombro_Plus/viewmodels/patient/patient_home_viewmodel.dart';
import 'package:Ombro_Plus/viewmodels/patient/session_execution_viewmodel.dart';
import 'package:Ombro_Plus/repositories/protocol_repository.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

class PatientHomePage extends StatefulWidget {
  const PatientHomePage({super.key});

  @override
  State<PatientHomePage> createState() => _PatientHomePageState();
}

class _PatientHomePageState extends State<PatientHomePage> {
  final int _selectedIndex = 0;

  // Variável para controlar o estado do check-in de dor na tela
  int? _selectedPainLevel;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PatientHomeViewModel>().loadHomeData();
    });
  }

  void _onTabTapped(BuildContext context, int index) {
    if (index == _selectedIndex) return;
    switch (index) {
      case 1:
        Navigator.pushReplacementNamed(context, '/patient-dashboard');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/patient-protocols');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/patient-main-chat');
        break;
      case 4:
        Navigator.pushReplacementNamed(context, '/patient-profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      body: Column(
        children: [
          const AppLogo(),
          Expanded(
            child: Consumer<PatientHomeViewModel>(
              builder: (context, viewModel, child) {
                if (viewModel.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF0E382C)),
                  );
                }

                if (viewModel.activeProtocols.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.healing,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Nenhum tratamento ativo.',
                          style: GoogleFonts.montserrat(
                            fontSize: 18,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        child: Text(
                          viewModel.activeProtocols.length > 1
                              ? 'Seus Tratamentos Ativos'
                              : 'Seu Tratamento Ativo',
                          style: GoogleFonts.montserrat(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0E382C),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // --- CARROSSEL HORIZONTAL CORRIGIDO (AUTO-HEIGHT) ---
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: viewModel.activeProtocols.map((summary) {
                            return _buildProtocolSlide(summary, context);
                          }).toList(),
                        ),
                      ),

                      // ---------------------------------------------------
                      const SizedBox(height: 10),

                      _buildPainCheckinCard(),

                      const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 20,
                        ),
                        child: UnreadMessagesSummary(),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: Navbar(
        currentIndex: _selectedIndex,
        onTap: (index) => _onTabTapped(context, index),
      ),
    );
  }

  Widget _buildPainCheckinCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.monitor_heart_outlined,
                color: Color(0xFF0E382C),
                size: 24,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Como está hoje?',
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildPainOption(0, '😄', 'Sem Dor', Colors.green),
              _buildPainOption(1, '😐', 'Incomoda', Colors.orange),
              _buildPainOption(2, '😣', 'Muita Dor', Colors.red),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPainOption(int level, String emoji, String label, Color color) {
    final isSelected = _selectedPainLevel == level;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPainLevel = level;
        });

        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Registro salvo! Isso ajuda muito a acompanhar a sua evolução.',
            ),
            backgroundColor: const Color(0xFF0E382C),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.openSans(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? color : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProtocolSlide(
    ActiveProtocolSummary summary,
    BuildContext context,
  ) {
    final protocol = summary.protocol;
    final weeklyData = summary.weeklyData;

    return Container(
      width: MediaQuery.of(context).size.width * 0.88,
      margin: const EdgeInsets.only(right: 16),
      // O mainAxisSize.min aqui garante que o slide só cresça o necessário!
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            protocol.nome,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.montserrat(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Semana ${weeklyData.currentWeek}',
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0E382C),
                ),
              ),
              Text(
                '${weeklyData.completedSessionIds.length}/${weeklyData.thisWeekSessions.length} sessões',
                style: GoogleFonts.openSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          _buildNextSessionCard(weeklyData),
          const SizedBox(height: 16),

          Row(
            children: [
              MiniMetricCard(
                title: 'Progresso do Tratamento',
                value: '${summary.progressPercent}',
                subValue: '%',
                color: Colors.black,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNextSessionCard(WeeklySessionData data) {
    if (data.thisWeekSessions.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          children: [
            Icon(Icons.event_busy, size: 40, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              'Nenhuma sessão agendada.',
              style: GoogleFonts.openSans(color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    final nextSession = data.nextSession;

    if (nextSession == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0E382C), Color(0xFF1A5A48)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.check_circle_outline,
              size: 48,
              color: Colors.white,
            ),
            const SizedBox(height: 12),
            Text(
              'Semana Concluída!',
              style: GoogleFonts.montserrat(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Você finalizou todos os treinos desta semana.',
              textAlign: TextAlign.center,
              style: GoogleFonts.openSans(color: Colors.white.withOpacity(0.9)),
            ),
          ],
        ),
      );
    }

    final bool isLockedToday = data.hasCompletedSessionToday;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF0E382C).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Próxima Sessão',
              style: GoogleFonts.openSans(
                color: const Color(0xFF0E382C),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            nextSession.name,
            style: GoogleFonts.montserrat(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${nextSession.exercises.length} exercícios propostos',
            style: GoogleFonts.openSans(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 20),

          if (isLockedToday)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.timer_outlined,
                    color: Colors.orange,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Você já treinou hoje! Descanse o corpo e volte amanhã.',
                      style: GoogleFonts.openSans(
                        color: Colors.orange.shade800,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isLockedToday
                  ? null
                  : () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChangeNotifierProvider(
                            create: (_) => SessionExecutionViewmodel(
                              repository: context.read<ProtocolRepository>(),
                            )..loadCompletedExercises(data.protocolId),
                            child: SessionExecutionPage(
                              protocolId: data.protocolId,
                              session: nextSession,
                            ),
                          ),
                        ),
                      );

                      if (result == true && context.mounted) {
                        context.read<PatientHomeViewModel>().loadHomeData();
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: isLockedToday
                    ? Colors.grey.shade300
                    : const Color(0xFF0E382C),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                isLockedToday ? 'Volte Amanhã' : 'Começar Agora',
                style: GoogleFonts.openSans(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isLockedToday ? Colors.grey.shade600 : Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
