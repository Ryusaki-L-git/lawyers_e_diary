import 'package:flutter/material.dart';

import '../../../models/case_model.dart';
import '../../../models/team_model.dart';
import '../../../services/team_service.dart';
import '../../../widgets/app_palette.dart';
import '../../../widgets/case_card.dart';
import '../widgets/team_header.dart';
import 'cases_all_team_cases_screen.dart';

/// Screen 5: Cases — My Cases (Member View)
/// Docket of cases specifically assigned to or handled by the logged-in member.
class CasesMyCasesScreen extends StatelessWidget {
  const CasesMyCasesScreen({
    super.key,
    required this.team,
    required this.membership,
  });

  final TeamModel team;
  final TeamMembership membership;

  static const Color _bg = AppPalette.canvas;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: TeamHeader(
        title: 'My Assigned Cases',
        subtitle: team.name,
        showBack: false,
        actions: [
          IconButton(
            tooltip: 'All Firm Cases',
            icon: const Icon(Icons.all_inbox_outlined, color: AppPalette.primaryGreen),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CasesAllTeamCasesScreen(team: team),
              ),
            ),
          ),
        ],
      ),
      body: StreamBuilder<List<CaseModel>>(
        stream: TeamService.instance.watchTeamCases(
          team.id,
          assignedTo: membership.userId,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final cases = snapshot.data ?? [];
          if (cases.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: AppPalette.primaryGreen.withValues(alpha: 0.10),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.assignment_turned_in_outlined,
                        color: AppPalette.primaryGreen,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No Cases Assigned',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'serif',
                        color: AppPalette.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'You do not have any active matters assigned to you right now. You can also view all firm cases.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: AppPalette.textMuted),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CasesAllTeamCasesScreen(team: team),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppPalette.primaryGreen,
                        foregroundColor: AppPalette.cardBackground,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.folder_open_rounded, size: 18),
                      label: const Text('Browse All Firm Cases'),
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
    );
  }
}
