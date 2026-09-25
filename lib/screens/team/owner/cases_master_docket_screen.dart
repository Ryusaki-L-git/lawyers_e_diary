import 'package:flutter/material.dart';

import '../../../models/case_model.dart';
import '../../../models/team_model.dart';
import '../../../services/team_service.dart';
import '../../../widgets/app_palette.dart';
import '../../../widgets/case_card.dart';
import '../widgets/team_header.dart';
import 'cases_assignment_matrix_screen.dart';

/// Screen 7 (Owner): Cases — Team Master Docket
/// Unrestricted firm overview of every matter filed under the firm identity with search and filters.
class CasesMasterDocketScreen extends StatefulWidget {
  const CasesMasterDocketScreen({super.key, required this.team});

  final TeamModel team;

  @override
  State<CasesMasterDocketScreen> createState() =>
      _CasesMasterDocketScreenState();
}

class _CasesMasterDocketScreenState extends State<CasesMasterDocketScreen> {
  String _filter = 'all'; // all, unassigned, assigned

  static const Color _bg = AppPalette.canvas;
  static const Color _gold = AppPalette.accentGold;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: TeamHeader(
        title: 'Team Master Docket',
        subtitle: widget.team.name,
        showBack: false,
        actions: [
          IconButton(
            tooltip: 'Assignment Matrix',
            icon: const Icon(Icons.view_quilt_rounded, color: _gold),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CasesAssignmentMatrixScreen(team: widget.team),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter tabs
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _filterChip('All Matters', 'all'),
                const SizedBox(width: 8),
                _filterChip('Unassigned', 'unassigned'),
                const SizedBox(width: 8),
                _filterChip('Assigned', 'assigned'),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE5DFD7)),

          // List stream
          Expanded(
            child: StreamBuilder<List<CaseModel>>(
              stream: TeamService.instance.watchTeamCases(widget.team.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                var cases = snapshot.data ?? [];
                if (_filter == 'unassigned') {
                  cases = cases
                      .where((c) => c.handledBy.isEmpty || c.handledBy == 'Advocate')
                      .toList();
                } else if (_filter == 'assigned') {
                  cases = cases
                      .where((c) => c.handledBy.isNotEmpty && c.handledBy != 'Advocate')
                      .toList();
                }

                if (cases.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.folder_open_outlined,
                              size: 48, color: Color(0xFF888888)),
                          const SizedBox(height: 12),
                          Text(
                            _filter == 'all'
                                ? 'No cases filed under this firm yet.'
                                : 'No matching matters in this view.',
                            style: const TextStyle(
                                fontSize: 14, color: Color(0xFF6B665E)),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                  itemCount: cases.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final c = cases[index];
                    return CaseCard(
                      caseItem: c,
                      actionStyle: CaseCardActionStyle.standard,
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

  Widget _filterChip(String label, String value) {
    final isSelected = _filter == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => setState(() => _filter = value),
      selectedColor: AppPalette.primaryGreen,
      labelStyle: TextStyle(
        color: isSelected ? AppPalette.cardBackground : AppPalette.textMuted,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        fontSize: 12,
      ),
      backgroundColor: AppPalette.canvas,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      side: BorderSide(
        color: isSelected ? AppPalette.primaryGreen : AppPalette.borderLight,
      ),
    );
  }
}
