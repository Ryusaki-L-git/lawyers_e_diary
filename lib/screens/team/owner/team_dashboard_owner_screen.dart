import 'package:flutter/material.dart';

import '../../../models/case_model.dart';
import '../../../models/team_model.dart';
import '../../../services/team_service.dart';
import '../../../widgets/app_palette.dart';
import 'audit_activity_master_log_screen.dart';
import 'cases_assignment_matrix_screen.dart';
import 'cases_master_docket_screen.dart';
import 'invite_member_screen.dart';
import 'team_chat_announcements_screen.dart';
import 'team_library_owner_screen.dart';
import 'team_management_hub_screen.dart';
import 'team_settings_screen.dart';

/// Screen 1 (Owner): Team Dashboard / Overview
/// Practice-wide metrics, active member count, hearing workload distribution.
class TeamDashboardOwnerScreen extends StatelessWidget {
  const TeamDashboardOwnerScreen({
    super.key,
    required this.team,
    required this.membership,
  });

  final TeamModel team;
  final TeamMembership membership;

  static const Color _bg = AppPalette.canvas;
  static const Color _gold = AppPalette.accentGold;
  static const Color _card = AppPalette.cardBackground;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Owner Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppPalette.primaryGreen,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x14000000),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: _gold.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: _gold.withValues(alpha: 0.5)),
                          ),
                          child: Text(
                            membership.role.label.toUpperCase(),
                            style: const TextStyle(
                              color: _gold,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.settings_outlined, color: AppPalette.cardBackground, size: 20),
                          tooltip: 'Team Settings',
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => TeamSettingsScreen(team: team),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      team.name,
                      style: const TextStyle(
                        color: AppPalette.cardBackground,
                        fontFamily: 'serif',
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      team.lawFirm,
                      style: const TextStyle(color: AppPalette.cardBackground, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Practice-Wide Metrics Grid
              StreamBuilder<List<CaseModel>>(
                stream: TeamService.instance.watchTeamCases(team.id),
                builder: (context, caseSnap) {
                  final cases = caseSnap.data ?? [];
                  final totalCases = cases.length;
                  final unassigned = cases.where((c) => c.handledBy.isEmpty || c.handledBy == 'Advocate').length;

                  return StreamBuilder<List<TeamMembership>>(
                    stream: TeamService.instance.watchMembers(team.id),
                    builder: (context, memberSnap) {
                      final members = memberSnap.data ?? [];
                      final memberCount = members.length;

                      return Row(
                        children: [
                          Expanded(
                            child: _MetricCard(
                              title: 'Total Docket',
                              value: '$totalCases',
                              subtitle: 'Active matters',
                              icon: Icons.gavel_rounded,
                              color: AppPalette.primaryGreen,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => CasesMasterDocketScreen(team: team),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _MetricCard(
                              title: 'Associates',
                              value: '$memberCount',
                              subtitle: 'In chamber roster',
                              icon: Icons.groups_rounded,
                              color: AppPalette.deepGreen,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => TeamManagementHubScreen(
                                    team: team,
                                    membership: membership,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _MetricCard(
                              title: 'Unassigned',
                              value: '$unassigned',
                              subtitle: 'Needs allocation',
                              icon: Icons.assignment_late_outlined,
                              color: unassigned > 0 ? AppPalette.unread : AppPalette.accentGold,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => CasesAssignmentMatrixScreen(team: team),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 24),

              // Leadership Quick Hub
              const Text(
                'LEADERSHIP COMMAND HUB',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppPalette.textMuted,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: _card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppPalette.borderLight),
                ),
                child: Column(
                  children: [
                    _LeaderTile(
                      icon: Icons.person_add_alt_1_rounded,
                      color: const Color(0xFF1F3D2B),
                      title: 'Invite Associate / Colleague',
                      subtitle: 'Add counsel with role and permission presets',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => InviteMemberScreen(team: team),
                        ),
                      ),
                    ),
                    const Divider(height: 1, indent: 64, color: Color(0xFFE5DFD7)),
                    _LeaderTile(
                      icon: Icons.view_quilt_rounded,
                      color: AppPalette.accentGold,
                      title: 'Case Assignment Matrix',
                      subtitle: 'Allocate and rebalance caseloads across associates',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CasesAssignmentMatrixScreen(team: team),
                        ),
                      ),
                    ),
                    const Divider(height: 1, indent: 64, color: Color(0xFFE5DFD7)),
                    _LeaderTile(
                      icon: Icons.campaign_rounded,
                      color: const Color(0xFF00604E),
                      title: 'Firm Announcements & Chat',
                      subtitle: 'Broadcast notices and team discussions',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TeamChatAnnouncementsScreen(
                            team: team,
                            membership: membership,
                          ),
                        ),
                      ),
                    ),
                    const Divider(height: 1, indent: 64, color: Color(0xFFE5DFD7)),
                    _LeaderTile(
                      icon: Icons.folder_copy_rounded,
                      color: const Color(0xFF6750A4),
                      title: 'Firm Asset Library',
                      subtitle: 'Manage pleading templates and firm precedents',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TeamLibraryOwnerScreen(team: team),
                        ),
                      ),
                    ),
                    const Divider(height: 1, indent: 64, color: Color(0xFFE5DFD7)),
                    _LeaderTile(
                      icon: Icons.verified_user_outlined,
                      color: AppPalette.textPrimary,
                      title: 'Audit & Activity Master Log',
                      subtitle: 'Unalterable system log of changes, logins & deletions',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AuditActivityMasterLogScreen(team: team),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE5DFD7)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppPalette.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: const TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: AppPalette.textMuted,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _LeaderTile extends StatelessWidget {
  const _LeaderTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 11.5, color: Color(0xFF6B665E)),
      ),
      trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF888888)),
    );
  }
}
