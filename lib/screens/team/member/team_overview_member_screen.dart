import 'package:flutter/material.dart';

import '../../../models/team_model.dart';
import '../../../services/team_service.dart';
import '../../../widgets/app_palette.dart';
import 'cases_all_team_cases_screen.dart';
import 'cases_my_cases_screen.dart';
import 'groups_my_groups_screen.dart';
import 'team_chat_member_screen.dart';
import 'team_library_member_screen.dart';
import 'activity_log_member_screen.dart';

/// Screen 1: Team Overview (Member View)
/// High-level practice team status, assigned case counts, active groups, personal quick actions.
class TeamOverviewMemberScreen extends StatelessWidget {
  const TeamOverviewMemberScreen({
    super.key,
    required this.team,
    required this.membership,
  });

  final TeamModel team;
  final TeamMembership membership;

  static const Color _bg = AppPalette.canvas;
  static const Color _card = AppPalette.cardBackground;
  static const Color _gold = AppPalette.accentGold;

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
                            color: _gold.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'TEAM MEMBER',
                            style: TextStyle(
                              color: _gold,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        Text(
                          team.lawFirm,
                          style: const TextStyle(
                            color: AppPalette.cardBackground,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      team.name,
                      style: const TextStyle(
                        color: AppPalette.cardBackground,
                        fontFamily: 'serif',
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Welcome back, ${membership.displayName}. Here is your docket overview.',
                      style: const TextStyle(color: AppPalette.cardBackground, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: StreamBuilder(
                      stream: TeamService.instance.watchTeamCases(
                        team.id,
                        assignedTo: membership.userId,
                      ),
                      builder: (context, snapshot) {
                        final count = snapshot.data?.length ?? 0;
                        return _StatBox(
                          title: 'My Cases',
                          count: '$count',
                          icon: Icons.assignment_outlined,
                          color: AppPalette.primaryGreen,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CasesMyCasesScreen(
                                team: team,
                                membership: membership,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: StreamBuilder(
                      stream: TeamService.instance.watchGroups(
                        team.id,
                        memberId: membership.userId,
                      ),
                      builder: (context, snapshot) {
                        final count = snapshot.data?.length ?? 0;
                        return _StatBox(
                          title: 'My Groups',
                          count: '$count',
                          icon: Icons.folder_outlined,
                          color: AppPalette.deepGreen,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => GroupsMyGroupsScreen(
                                team: team,
                                membership: membership,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              const Text(
                'QUICK ACTIONS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppPalette.textMuted,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: _card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppPalette.borderLight),
                ),
                child: Column(
                  children: [
                    _ActionTile(
                      icon: Icons.library_books_outlined,
                      color: AppPalette.primaryGreen,
                      title: 'Team Library',
                      subtitle: 'Access shared forms, pleadings, and files',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TeamLibraryMemberScreen(team: team),
                        ),
                      ),
                    ),
                    const Divider(height: 1, indent: 64, color: AppPalette.borderLight),
                    _ActionTile(
                      icon: Icons.all_inbox_outlined,
                      color: AppPalette.deepGreen,
                      title: 'All Firm Cases',
                      subtitle: 'Browse master team cases accessible to you',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CasesAllTeamCasesScreen(team: team),
                        ),
                      ),
                    ),
                    const Divider(height: 1, indent: 64, color: AppPalette.borderLight),
                    _ActionTile(
                      icon: Icons.chat_bubble_outline_rounded,
                      color: AppPalette.accentGold,
                      title: 'Team Channel',
                      subtitle: 'Discuss hearings and assignments with counsel',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TeamChatMemberScreen(
                            team: team,
                            membership: membership,
                          ),
                        ),
                      ),
                    ),
                    const Divider(height: 1, indent: 64, color: AppPalette.borderLight),
                    _ActionTile(
                      icon: Icons.history_rounded,
                      color: AppPalette.textMuted,
                      title: 'Activity Log',
                      subtitle: 'Recent updates, hearings, and assignments',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ActivityLogMemberScreen(team: team),
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

class _StatBox extends StatelessWidget {
  const _StatBox({
    required this.title,
    required this.count,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String count;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppPalette.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppPalette.borderLight),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 14),
            Text(
              count,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppPalette.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: AppPalette.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
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
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 14,
          color: AppPalette.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 12, color: AppPalette.textMuted),
      ),
      trailing: const Icon(Icons.chevron_right_rounded, color: AppPalette.textMuted),
    );
  }
}

