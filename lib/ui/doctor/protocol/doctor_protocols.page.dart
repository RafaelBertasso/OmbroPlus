import 'package:Ombro_Plus/ui/shared/widgets/navbar.dart';
import 'package:Ombro_Plus/models/protocol.model.dart';
import 'package:Ombro_Plus/viewmodels/doctor/doctor_protocols.viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class DoctorProtocolsPage extends StatefulWidget {
  const DoctorProtocolsPage({super.key});

  @override
  State<DoctorProtocolsPage> createState() => _DoctorProtocolsPageState();
}

class _DoctorProtocolsPageState extends State<DoctorProtocolsPage> {
  final int _selectedIndex = 2;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DoctorProtocolsViewModel>().loadProtocols();
    });
  }

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

  Future<void> _confirmDelete(BuildContext context, String protocolId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir Protocolo'),
        content: const Text('Tem certeza? Essa ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.black),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final success = await context
          .read<DoctorProtocolsViewModel>()
          .deleteProtocol(protocolId);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: const Text('Protocolo excluído com sucesso.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF4F7F6),
      appBar: AppBar(
        title: Text(
          'Meus Protocolos',
          style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          _buildFilterBar(context),
          Expanded(
            child: Consumer<DoctorProtocolsViewModel>(
              builder: (context, viewModel, child) {
                if (viewModel.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF0E382C)),
                  );
                }

                if (viewModel.protocols.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.filter_list_off,
                          size: 60,
                          color: Colors.grey.shade400,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Nenhum protocolo encontrado.',
                          style: GoogleFonts.openSans(
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: viewModel.protocols.length,
                  itemBuilder: (context, index) {
                    final protocol = viewModel.protocols[index];
                    return _buildProtocolCard(context, protocol);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/new-protocol').then((_) {
            context.read<DoctorProtocolsViewModel>().loadProtocols();
          });
        },
        backgroundColor: const Color(0xFF0E382C),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: Navbar(
        currentIndex: _selectedIndex,
        onTap: (index) => _onTabTapped(context, index),
      ),
    );
  }

  Widget _buildFilterBar(BuildContext context) {
    final viewModel = context.watch<DoctorProtocolsViewModel>();

    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _filterChip('Todos', 'all', viewModel),
          const SizedBox(width: 8),
          _filterChip('Ativos', 'active', viewModel),
          const SizedBox(width: 8),
          _filterChip('Finalizados', 'finalized', viewModel),
        ],
      ),
    );
  }

  Widget _filterChip(String label, String value, DoctorProtocolsViewModel vm) {
    final isSelected = vm.currentFilter == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => vm.setFilter(value),
      selectedColor: const Color(0xFF0E382C),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      backgroundColor: Colors.white,
    );
  }

  Widget _buildProtocolCard(BuildContext context, ProtocolModel protocol) {
    final startFormat = DateFormat('dd/MM').format(protocol.dataInicio);
    final endFormat = DateFormat('dd/MM').format(protocol.dataFim);
    final isActive = protocol.status == 'active';
    final statusColor = isActive ? Colors.green : Colors.grey;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            '/protocol-details',
            arguments: {'protocoloId': protocol.id},
          ).then((_) {
            if (mounted) {
              context.read<DoctorProtocolsViewModel>().loadProtocols();
            }
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          protocol.nome,
                          style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          protocol.pacienteName.isNotEmpty
                              ? protocol.pacienteName
                              : 'Paciente Removido',
                          style: GoogleFonts.openSans(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),

                  IconButton(
                    onPressed: () => _confirmDelete(context, protocol.id!),
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Colors.redAccent,
                    ),
                  ),
                ],
              ),
              Divider(),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 6),
                  Text(
                    '$startFormat - $endFormat',
                    style: GoogleFonts.openSans(
                      fontSize: 13,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  Spacer(),
                  Icon(
                    Icons.fitness_center,
                    size: 14,
                    color: Colors.grey.shade600,
                  ),
                  SizedBox(width: 4),
                  Text(
                    '${protocol.sessoesConcluidas}/${protocol.totalSessoesEstimadas}',
                    style: GoogleFonts.openSans(
                      fontSize: 13,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
