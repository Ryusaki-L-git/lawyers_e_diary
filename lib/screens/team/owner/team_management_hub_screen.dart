import 'package:flutter/material.dart';

import '../../../models/team_model.dart';
import '../../../services/team_service.dart';
import '../../../widgets/app_palette.dart';
import '../widgets/team_header.dart';
import 'archive_delete_team_screen.dart';
import 'groups_all_groups_screen.dart';
import 'invite_member_screen.dart';
import 'manage_members_roles_screen.dart';
import 'team_settings_screen.dart';
import 'transfer_ownership_owner_screen.dart';

/// Screen 3 (Owner): Team Management Hub
/// Central administration panel for firm roster control, role assignments, and governance.
class TeamManagementHubScreen extends StatelessWidget {
  const TeamManagementHubScreen({
    super.key,
    required this.team,
    required this.membership,
  });

  final TeamModel team;
  final TeamMembership membership;

  static const Color _bg = AppPalette.canvas;
  static const Color _card = AppPalette.cardBackground;
  static const Color _gold = AppPalette.accentGold;
  static const Color _red = AppPalette.unread;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: TeamHeader(
        title: 'Team Management Hub',
        subtitle: '${team.lawFirm} · Administration',
        showBack: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Quick Member Summary Banner
          StreamBuilder<List<TeamMembership>>(
            stream: TeamService.instance.watchMembers(team.id),
            builder: (context, snapshot) {
              final count = snapshot.data?.length ?? 1;

              return Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppPalette.primaryGreen,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: _gold.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.people_alt_rounded, color: _gold, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$count Associates Enrolled',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Active practice roster for this firm',
                            style: TextStyle(color: AppPalette.cardBackground, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => InviteMemberScreen(team: team),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _gold,
                        foregroundColor: AppPalette.textPrimary,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Invite', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 24),

          // Core Management Section
          _SectionLabel('FIRM ROSTER & GROUPS'),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5DFD7)),
            ),
            child: Column(
              children: [
                _HubTile(
                  icon: Icons.manage_accounts_rounded,
                  color: const Color(0xFF1F3D2B),
                  title: 'Manage Members & Roles',
                  subtitle: 'Modify roles, permissions, and designations',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ManageMembersRolesScreen(team: team),
                    ),
                  ),
                ),
                const Divider(height: 1, indent: 64, color: Color(0xFFE5DFD7)),
                _HubTile(
                  icon: Icons.folder_shared_rounded,
                  color: const Color(0xFF6750A4),
                  title: 'Practice Groups Administration',
                  subtitle: 'Organize litigation circles, criminal, corporate, civil groups',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => GroupsAllGroupsScreen(team: team, membership: membership),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Firm Configuration
          _SectionLabel('FIRM SETTINGS & POLICIES'),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5DFD7)),
            ),
            child: Column(
              children: [
                _HubTile(
                  icon: Icons.business_outlined,
                  color: const Color(0xFF00604E),
                  title: 'Team Settings & Chamber Profile',
                  subtitle: 'Firm name, practice details, and preferences',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TeamSettingsScreen(team: team),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Critical Actions
          _SectionLabel('HIGH-RISK GOVERNANCE'),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5DFD7)),
            ),
            child: Column(
              children: [
                _HubTile(
                  icon: Icons.swap_horiz_rounded,
                  color: _gold,
                  title: 'Transfer Practice Ownership',
                  subtitle: 'Succession protocol to hand over managing partner status',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TransferOwnershipOwnerScreen(team: team),
                    ),
                  ),
                ),
                const Divider(height: 1, indent: 64, color: Color(0xFFE5DFD7)),
                _HubTile(
                  icon: Icons.delete_forever_outlined,
                  color: _red,
                  title: 'Archive / Delete Practice Team',
                  subtitle: 'Dissolve team and revoke firm subscriptions',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ArchiveDeleteTeamScreen(team: team),
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

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: AppPalette.textMuted,
        letterSpacing: 0.8,
      ),
    );
  }
}

class _HubTile extends StatelessWidget {
  const _HubTile({
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
        style: const TextStyle(fontSize: 11.5, color: AppPalette.textMuted),
      ),
      trailing: const Icon(Icons.chevron_right_rounded, color: AppPalette.textMuted),
    );
  }
}

