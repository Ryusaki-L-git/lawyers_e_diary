import 'package:flutter/material.dart';

import '../../../models/case_model.dart';
import '../../../models/team_model.dart';
import '../../../services/team_service.dart';
import '../../../widgets/app_palette.dart';
import '../widgets/team_header.dart';

/// Screen 8 (Owner): Cases — Assignment Matrix
/// Caseload allocation interface to assign and rebalance matters across associates.
class CasesAssignmentMatrixScreen extends StatelessWidget {
  const CasesAssignmentMatrixScreen({super.key, required this.team});

  final TeamModel team;

  static const Color _bg = AppPalette.canvas;
  static const Color _card = AppPalette.cardBackground;

  void _showAssignmentDialog(
    BuildContext context,
    CaseModel c,
    List<TeamMembership> members,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Assign Case: ${c.title}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'serif',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  'Currently handled by: ${c.handledBy.isEmpty ? "Unassigned" : c.handledBy}',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF6B665E)),
                ),
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 8),

                // Unassign option
                ListTile(
                  leading: const Icon(Icons.person_off_outlined, color: Color(0xFFB3261E)),
                  title: const Text('Mark as Unassigned', style: TextStyle(color: Color(0xFFB3261E), fontWeight: FontWeight.w600, fontSize: 13.5)),
                  onTap: () async {
                    Navigator.pop(ctx);
                    await TeamService.instance.unassignCase(
                      teamId: team.id,
                      caseId: c.id,
                      caseTitle: c.title,
                    );
                  },
                ),
                const Divider(height: 1),

                // List members
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: members.length,
                    itemBuilder: (context, index) {
                      final m = members[index];
                      final isCurrent = c.handledBy == m.userId || c.handledBy == m.displayName;

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppPalette.primaryGreen,
                          radius: 16,
                          child: Text(
                            m.initials,
                            style: const TextStyle(color: AppPalette.accentGold, fontSize: 11, fontWeight: FontWeight.w700),
                          ),
                        ),
                        title: Text(m.displayName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
                        subtitle: Text('${m.role.label} · ${m.advocateType}', style: const TextStyle(fontSize: 11)),
                        trailing: isCurrent
                            ? const Icon(Icons.check_circle_rounded, color: Color(0xFF1F3D2B))
                            : null,
                        onTap: () async {
                          Navigator.pop(ctx);
                          await TeamService.instance.assignCase(
                            teamId: team.id,
                            caseId: c.id,
                            caseTitle: c.title,
                            memberId: m.userId,
                            memberName: m.displayName,
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: TeamHeader(
        title: 'Assignment Matrix',
        subtitle: team.name,
      ),
      body: StreamBuilder<List<CaseModel>>(
        stream: TeamService.instance.watchTeamCases(team.id),
        builder: (context, caseSnap) {
          if (caseSnap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final cases = caseSnap.data ?? [];
          if (cases.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text('No firm cases found to allocate.', style: TextStyle(color: Color(0xFF888888))),
              ),
            );
          }

          return StreamBuilder<List<TeamMembership>>(
            stream: TeamService.instance.watchMembers(team.id),
            builder: (context, memberSnap) {
              final members = memberSnap.data ?? [];

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: cases.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final c = cases[index];
                  final isAssigned = c.handledBy.isNotEmpty && c.handledBy != 'Advocate';

                  return Container(
                    decoration: BoxDecoration(
                      color: _card,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE5DFD7)),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      title: Text(
                        c.title,
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            '${c.caseNumber.isNotEmpty ? c.caseNumber : "Ref #"} · ${c.courtName}',
                            style: const TextStyle(fontSize: 11.5, color: Color(0xFF6B665E)),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(
                                isAssigned ? Icons.person_rounded : Icons.person_outline_rounded,
                                size: 14,
                                color: isAssigned ? const Color(0xFF1F3D2B) : const Color(0xFFB3261E),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                isAssigned ? 'Assigned to: ${c.handledBy}' : 'Unassigned',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: isAssigned ? const Color(0xFF1F3D2B) : const Color(0xFFB3261E),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      trailing: ElevatedButton(
                        onPressed: () => _showAssignmentDialog(context, c, members),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppPalette.primaryGreen,
                          foregroundColor: AppPalette.cardBackground,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          elevation: 0,
                        ),
                        child: Text(
                          isAssigned ? 'Reassign' : 'Allocate',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
