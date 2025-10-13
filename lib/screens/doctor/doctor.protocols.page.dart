import 'package:Ombro_Plus/components/app.logo.dart';
import 'package:Ombro_Plus/components/doctor.navbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DoctorProtocolsPage extends StatefulWidget {
  const DoctorProtocolsPage({super.key});

  @override
  State<DoctorProtocolsPage> createState() => _DoctorProtocolsPageState();
}

class _DoctorProtocolsPageState extends State<DoctorProtocolsPage> {
  final int _selectedIndex = 2;
  final String? specialistId = FirebaseAuth.instance.currentUser?.uid;
  String _currentFilter = 'active';

  void _onTabTapped(BuildContext context, int index) {
    if (index == _selectedIndex) return;
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/doctor-home');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/doctor-dashboard');
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

  Widget _buildStatusChip(String status) {
    final bool isActive = status == 'active';
    final String label = isActive ? 'ATIVO' : 'FINALIZADO';
    final Color color = isActive ? Colors.green.shade700 : Colors.red.shade700;
    final Color backgroudColor = isActive
        ? Colors.green.shade50
        : Colors.red.shade50;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroudColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 0.5),
      ),
      child: Text(
        label,
        style: GoogleFonts.openSans(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Future<void> _deleteProtocol(String protocolId, String protocolName) async {
    try {
      await FirebaseFirestore.instance
          .collection('protocolos')
          .doc(protocolId)
          .delete();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Protocolo "$protocolName" excluído com sucesso!'),
            backgroundColor: Color(0xFF0E382C),
          ),
        );
      }
    } catch (e) {
      debugPrint('Erro ao excluir protocolo: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao excluir protocolo.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showDeleteConfirmationModal(String protocolId, String protocolName) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Center(
            child: const Text(
              'Excluir Protocolo',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          content: Text(
            'Tem certeza que deseja excluir o protocolo "$protocolName" permanentemente? Esta ação é irreversível.',
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Cancelar',
                style: GoogleFonts.montserrat(
                  color: const Color(0xFF0E382C),
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: Text(
                'Excluir',
                style: GoogleFonts.montserrat(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _deleteProtocol(protocolId, protocolName);
              },
            ),
          ],
        );
      },
    );
  }

  Stream<QuerySnapshot> _protocolStream() {
    Query query = FirebaseFirestore.instance
        .collection('protocolos')
        .where('especialistaId', isEqualTo: specialistId);

    if (_currentFilter != 'all') {
      query = query.where('status', isEqualTo: _currentFilter);
    }
    query = query
        .orderBy('nome', descending: false)
        .orderBy('criadoEm', descending: true);
    return query.snapshots();
  }

  void _showFilterMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Wrap(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Text(
                  'Filtrar Protocolos',
                  style: GoogleFonts.montserrat(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0E382C),
                  ),
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.auto_awesome_mosaic_outlined,
                  color: _currentFilter == 'all'
                      ? const Color(0xFF0E382C)
                      : Colors.grey,
                ),
                title: const Text('Todos'),
                onTap: () {
                  setState(() => _currentFilter = 'all');
                  Navigator.pop(context);
                },
                selected: _currentFilter == 'all',
              ),
              ListTile(
                leading: Icon(
                  Icons.check_circle_outline,
                  color: _currentFilter == 'active'
                      ? Colors.green.shade700
                      : Colors.grey,
                ),
                title: const Text('Ativos'),
                onTap: () {
                  setState(() => _currentFilter = 'active');
                  Navigator.pop(context);
                },
                selected: _currentFilter == 'active',
              ),
              ListTile(
                leading: Icon(
                  Icons.archive_outlined,
                  color: _currentFilter == 'finalized'
                      ? Colors.red.shade700
                      : Colors.grey,
                ),
                title: const Text('Finalizados'),
                onTap: () {
                  setState(() => _currentFilter = 'finalized');
                  Navigator.pop(context);
                },
                selected: _currentFilter == 'finalized',
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF4F7F6),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/new-protocol'),
        backgroundColor: Color(0xFF0E382C),
        tooltip: 'Adicionar Protocolo',
        child: Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          AppLogo(),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Protocolos',
                        style: GoogleFonts.montserrat(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                      IconButton(
                        onPressed: () => _showFilterMenu(context),
                        icon: Icon(
                          Icons.filter_list_outlined,
                          color: Color(0xFF0E382C),
                        ),
                        tooltip: 'Filtrar Protocolos',
                      ),
                    ],
                  ),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: _protocolStream(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF0E382C),
                            ),
                          );
                        }
                        if (snapshot.hasError) {
                          print(snapshot.error);
                          return Center(
                            child: Text('Erro ao carregar protocolos.'),
                          );
                        }
                        final protocolsDocs = snapshot.data?.docs ?? [];
                        if (protocolsDocs.isEmpty) {
                          return Center(
                            child: Text(
                              'Nenhum protocolo criado ainda. Crie um novo!',
                              style: GoogleFonts.openSans(
                                color: Colors.black54,
                              ),
                            ),
                          );
                        }
                        return ListView.separated(
                          itemCount: protocolsDocs.length,
                          separatorBuilder: (_, __) => SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final protocolData =
                                protocolsDocs[index].data()
                                    as Map<String, dynamic>;
                            final protocolId = protocolsDocs[index].id;
                            final protocolName =
                                protocolData['nome'] ?? 'Protocolo sem nome';
                            final protocolStatus =
                                protocolData['status'] as String? ?? 'active';
                            final isFinalized = protocolStatus == 'finalized';
                            return FutureBuilder<DocumentSnapshot>(
                              future: FirebaseFirestore.instance
                                  .collection('pacientes')
                                  .doc(protocolData['pacienteId'])
                                  .get(),
                              builder: (context, patientSnapshot) {
                                String patientName = 'Carregando Paciente';
                                if (patientSnapshot.hasData &&
                                    patientSnapshot.data!.exists) {
                                  patientName =
                                      patientSnapshot.data!['nome'] ??
                                      'Paciente sem nome';
                                } else if (patientSnapshot.hasError) {
                                  patientName = 'Erro ao carregar nome';
                                }

                                final Color cardColor = isFinalized
                                    ? Colors.grey.shade100
                                    : Color(0xFFF4F7F6);
                                final Color titleColor = isFinalized
                                    ? Colors.grey.shade600
                                    : Colors.black;
                                final Color subtitleColor = isFinalized
                                    ? Colors.grey.shade500
                                    : Colors.black54;

                                return Card(
                                  color: cardColor,
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: ListTile(
                                    onLongPress: () =>
                                        _showDeleteConfirmationModal(
                                          protocolId,
                                          protocolName,
                                        ),
                                    leading: Icon(
                                      Icons.description,
                                      color: titleColor,
                                    ),
                                    title: Text(
                                      protocolData['nome'] ??
                                          'Protocolo sem nome',
                                      style: GoogleFonts.montserrat(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: titleColor,
                                      ),
                                    ),
                                    subtitle: RichText(
                                      text: TextSpan(
                                        style: GoogleFonts.openSans(
                                          fontSize: 13,
                                          color: subtitleColor,
                                        ),
                                        children: <TextSpan>[
                                          TextSpan(
                                            text: 'Paciente\n',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                          TextSpan(text: patientName),
                                        ],
                                      ),
                                    ),
                                    onTap: isFinalized
                                        ? null
                                        : () {
                                            Navigator.pushNamed(
                                              context,
                                              '/protocol-details',
                                              arguments: {
                                                'protocoloId': protocolId,
                                              },
                                            );
                                          },
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        _buildStatusChip(protocolStatus),
                                        Icon(
                                          Icons.chevron_right,
                                          color: isFinalized
                                              ? Colors.grey.shade400
                                              : Colors.grey,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: DoctorNavbar(
        currentIndex: _selectedIndex,
        onTap: (index) => _onTabTapped(context, index),
      ),
    );
  }
}
