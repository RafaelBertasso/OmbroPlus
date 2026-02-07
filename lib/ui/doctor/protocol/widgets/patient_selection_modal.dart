import 'package:Ombro_Plus/viewmodels/shared/patient_selection_viewmodel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PatientSelectionModal extends StatefulWidget {
  final ScrollController scrollController;
  final Function(String id, String name) onPatientSelected;

  const PatientSelectionModal({
    super.key,
    required this.scrollController,
    required this.onPatientSelected,
  });

  @override
  State<PatientSelectionModal> createState() => _PatientSelectionModalState();
}

class _PatientSelectionModalState extends State<PatientSelectionModal> {
  final PatientSelectionViewmodel _viewModel = PatientSelectionViewmodel();

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Selecione o Paciente',
              style: GoogleFonts.montserrat(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0E382C),
              ),
            ),
          ),

          // Campo de Busca
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar paciente por nome',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF0E382C)),
                filled: true,
                fillColor: Theme.of(context).scaffoldBackgroundColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              // Chama o método do ViewModel em vez de setState direto
              onChanged: _viewModel.updateSearch,
            ),
          ),

          // Lista de Pacientes
          Expanded(
            // ListenableBuilder ouve as mudanças no searchText do ViewModel
            child: ListenableBuilder(
              listenable: _viewModel,
              builder: (context, child) {
                return StreamBuilder<QuerySnapshot>(
                  stream: _viewModel.patientsStream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF0E382C),
                        ),
                      );
                    }
                    if (snapshot.hasError) {
                      return const Center(
                        child: Text('Erro ao carregar pacientes'),
                      );
                    }

                    // O ViewModel faz a filtragem dos dados
                    final filteredPatients = _viewModel.filterPatients(
                      snapshot.data?.docs ?? [],
                    );

                    if (filteredPatients.isEmpty) {
                      return Center(
                        child: Text(
                          'Nenhum paciente encontrado',
                          style: GoogleFonts.openSans(color: Colors.black54),
                        ),
                      );
                    }

                    return ListView.separated(
                      controller: widget.scrollController,
                      itemCount: filteredPatients.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final patient = filteredPatients[index];
                        final data =
                            patient.data()
                                as Map<String, dynamic>; // Cast seguro
                        final patientName = data['nome'] ?? 'Sem Nome';
                        final initialLetter = patientName.isNotEmpty
                            ? patientName[0].toUpperCase()
                            : '?';

                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: const Color(0xFF0E382C),
                            child: Text(
                              initialLetter,
                              style: GoogleFonts.montserrat(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            patientName,
                            style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          onTap: () =>
                              widget.onPatientSelected(patient.id, patientName),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
