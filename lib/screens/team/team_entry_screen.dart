import 'package:flutter/material.dart';

import '../../models/team_model.dart';
import '../../services/team_service.dart';
import '../../widgets/app_palette.dart';
import 'create_team_screen.dart';
import 'member/cases_my_cases_screen.dart';
import 'member/groups_my_groups_screen.dart';
import 'member/team_chat_member_screen.dart';
import 'member/team_management_member_screen.dart';
import 'member/team_overview_member_screen.dart';
import 'owner/cases_master_docket_screen.dart';
import 'owner/groups_all_groups_screen.dart';
import 'owner/team_chat_announcements_screen.dart';
import 'owner/team_dashboard_owner_screen.dart';
import 'owner/team_management_hub_screen.dart';
import 'widgets/team_bottom_navigation.dart';

/// The primary entry screen for the Team System (/team or /clients).
/// Automatically detects user's role (Owner/Leader vs Member) and mounts
/// the corresponding 5 core tabs with the Black Team Navigation Bar.
class TeamEntryScreen extends StatefulWidget {
  const TeamEntryScreen({super.key});

  @override
  State<TeamEntryScreen> createState() => _TeamEntryScreenState();
}

class _TeamEntryScreenState extends State<TeamEntryScreen> {
  int _currentIndex = 0;

  static const Color _bg = AppPalette.canvas;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<TeamModel>>(
      stream: TeamService.instance.watchUserTeams(),
      builder: (context, teamSnap) {
        if (teamSnap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: _bg,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final teams = teamSnap.data ?? [];
        if (teams.isEmpty) {
          return _buildNoTeamState(context);
        }

        final activeTeam = teams.first;

        return StreamBuilder<TeamMembership?>(
          stream: TeamService.instance.watchMyMembership(activeTeam.id),
          builder: (context, memberSnap) {
            final membership = memberSnap.data ??
                TeamMembership(
                  userId: TeamService.instance.currentUserId ?? '',
                  teamId: activeTeam.id,
                  role: TeamRole.owner,
                  displayName: TeamService.instance.currentUserName ?? 'Counsel',
                );

            final isOwnerOrLeader = membership.role.canManageTeam;

            final pages = isOwnerOrLeader
                ? [
                    TeamDashboardOwnerScreen(team: activeTeam, membership: membership),
                    CasesMasterDocketScreen(team: activeTeam),
                    TeamChatAnnouncementsScreen(team: activeTeam, membership: membership),
                    GroupsAllGroupsScreen(team: activeTeam, membership: membership),
                    TeamManagementHubScreen(team: activeTeam, membership: membership),
                  ]
                : [
                    TeamOverviewMemberScreen(team: activeTeam, membership: membership),
                    CasesMyCasesScreen(team: activeTeam, membership: membership),
                    TeamChatMemberScreen(team: activeTeam, membership: membership),
                    GroupsMyGroupsScreen(team: activeTeam, membership: membership),
                    TeamManagementMemberScreen(team: activeTeam, membership: membership),
                  ];

            return Scaffold(
              backgroundColor: _bg,
              body: IndexedStack(
                index: _currentIndex,
                children: pages,
              ),
              bottomNavigationBar: TeamBottomNavigation(
                currentIndex: _currentIndex,
                isOwnerOrLeader: isOwnerOrLeader,
                onTap: (idx) => setState(() => _currentIndex = idx),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildNoTeamState(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: AppPalette.cardBackground,
        foregroundColor: AppPalette.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Team & Chamber Practice',
          style: TextStyle(
            color: AppPalette.textPrimary,
            fontFamily: 'serif',
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppPalette.primaryGreen,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppPalette.primaryGreen.withValues(alpha: 0.18),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.groups_rounded, color: AppPalette.accentGold, size: 40),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Collaborative Law Practice',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'serif',
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppPalette.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Establish a firm team to allocate case matters to associates, organize practice groups, share templates, and broadcast chamber announcements.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13.5, color: AppPalette.textMuted, height: 1.5),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CreateTeamScreen(),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppPalette.primaryGreen,
                        foregroundColor: AppPalette.cardBackground,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(Icons.add_rounded, color: AppPalette.accentGold),
                      label: const Text(
                        'Establish Firm Team',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

