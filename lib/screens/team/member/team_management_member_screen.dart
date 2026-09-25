import 'package:flutter/material.dart';

import '../../../models/team_model.dart';
import '../../../services/team_service.dart';
import '../../../widgets/app_palette.dart';
import '../widgets/team_header.dart';
import 'leave_team_screen.dart';
import 'member_profile_view_screen.dart';
import 'transfer_ownership_member_screen.dart';

/// Screen 3: Team Management (Member View)
/// View-only firm roster listing colleagues, designations, and account options.
class TeamManagementMemberScreen extends StatelessWidget {
  const TeamManagementMemberScreen({
    super.key,
    required this.team,
    required this.membership,
  });

  final TeamModel team;
  final TeamMembership membership;

  static const Color _bg = AppPalette.canvas;
  static const Color _card = AppPalette.cardBackground;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: TeamHeader(
        title: 'Team Roster',
        subtitle: team.name,
        showBack: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppPalette.primaryGreen,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded, color: AppPalette.accentGold, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Viewing as Member · Firm roster managed by ${team.lawFirm}.',
                    style: const TextStyle(color: AppPalette.cardBackground, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          const Text(
            'CHAMBER COLLEAGUES',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppPalette.textMuted,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),

          StreamBuilder<List<TeamMembership>>(
            stream: TeamService.instance.watchMembers(team.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ));
              }

              final members = snapshot.data ?? [];
              if (members.isEmpty) {
                return const Center(
                  child: Text('No members found in this team.'),
                );
              }

              return Container(
                decoration: BoxDecoration(
                  color: _card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppPalette.borderLight),
                ),
                child: Column(
                  children: members.asMap().entries.map((entry) {
                    final isLast = entry.key == members.length - 1;
                    final m = entry.value;

                    return Column(
                      children: [
                        ListTile(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MemberProfileViewScreen(
                                membership: m,
                                team: team,
                              ),
                            ),
                          ),
                          leading: CircleAvatar(
                            backgroundColor: AppPalette.primaryGreen.withValues(alpha: 0.10),
                            child: Text(
                              m.initials,
                              style: const TextStyle(
                                color: AppPalette.primaryGreen,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          title: Row(
                            children: [
                              Flexible(
                                child: Text(
                                  m.displayName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                    color: AppPalette.textPrimary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (m.userId == membership.userId) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppPalette.primaryGreen.withValues(alpha: 0.10),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'YOU',
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                      color: AppPalette.primaryGreen,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          subtitle: Text(
                            '${m.role.label} · ${m.advocateType.isNotEmpty ? m.advocateType : "Counsel"}',
                            style: const TextStyle(fontSize: 12, color: AppPalette.textMuted),
                          ),
                          trailing: const Icon(Icons.chevron_right_rounded, color: AppPalette.textMuted),
                        ),
                        if (!isLast)
                          const Divider(height: 1, indent: 64, color: AppPalette.borderLight),
                      ],
                    );
                  }).toList(),
                ),
              );
            },
          ),
          const SizedBox(height: 28),

          const Text(
            'MEMBERSHIP ACTIONS',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppPalette.textMuted,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppPalette.borderLight),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.swap_horiz_rounded, color: AppPalette.primaryGreen),
                  title: const Text('Transfer Ownership Information', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppPalette.textPrimary)),
                  subtitle: const Text('View owner permissions & contact managing partner', style: TextStyle(fontSize: 12, color: AppPalette.textMuted)),
                  trailing: const Icon(Icons.chevron_right_rounded, color: AppPalette.textMuted),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TransferOwnershipMemberScreen(team: team),
                    ),
                  ),
                ),
                const Divider(height: 1, indent: 64, color: AppPalette.borderLight),
                ListTile(
                  leading: const Icon(Icons.logout_rounded, color: AppPalette.unread),
                  title: const Text(
                    'Leave Team',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppPalette.unread),
                  ),
                  subtitle: const Text('Relinquish access to firm dockets & chat', style: TextStyle(fontSize: 12, color: AppPalette.textMuted)),
                  trailing: const Icon(Icons.chevron_right_rounded, color: AppPalette.unread),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LeaveTeamScreen(team: team),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

