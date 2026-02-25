import 'package:Ombro_Plus/viewmodels/doctor/specialist_selection_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class SpecialistSelectionModal extends StatelessWidget {
  final ScrollController scrollController;
  final Function(List<String> selectedIds, List<String> selectedNames)
  onSelectionCompleted;
  const SpecialistSelectionModal({
    super.key,
    required this.scrollController,
    required this.onSelectionCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<SpecialistSelectionViewmodel>();
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Adicionar Colaboradores',
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(width: 4),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0E382C),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () => onSelectionCompleted(
                    viewModel.selectedIds,
                    viewModel.selectedNames,
                  ),
                  child: Text(
                    'Confirmar',
                    style: GoogleFonts.openSans(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              onChanged: viewModel.setSearchQuery,
              decoration: InputDecoration(
                hintText: 'Buscar especialista...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: const Color(0xFFF4F7F6),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),

          const Divider(height: 1),
          Expanded(
            child: viewModel.isLoading
                ? const Center(child: CircularProgressIndicator.adaptive())
                : viewModel.filteredDoctors.isEmpty
                ? const Center(
                    child: Text('Nenhum outro especialista encontrado.'),
                  )
                : ListView.builder(
                    controller: scrollController,
                    itemCount: viewModel.filteredDoctors.length,
                    itemBuilder: (context, index) {
                      final doctor = viewModel.filteredDoctors[index];
                      final isSelected = viewModel.selectedIds.contains(
                        doctor.id,
                      );

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color(
                            0xFF0E382C,
                          ).withOpacity(0.1),
                          child: const Icon(
                            Icons.medical_services,
                            color: Color(0xFF0E382C),
                            size: 20,
                          ),
                        ),
                        title: Text(doctor.nome),
                        subtitle: Text(doctor.crefito ?? doctor.crm ?? ''),
                        trailing: Checkbox(
                          value: isSelected,
                          onChanged: (_) => viewModel.toggleSelection(doctor),
                          activeColor: const Color(0xFF0E382C),
                        ),
                        onTap: () => viewModel.toggleSelection(doctor),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
