import 'package:flutter/material.dart';

import '../../../models/team_model.dart';
import '../../../services/team_service.dart';
import '../../../widgets/app_palette.dart';
import '../widgets/team_header.dart';
import 'invite_member_screen.dart';
import 'member_profile_permissions_screen.dart';

/// Screen 4 (Owner): Manage Members & Roles
/// Granular role modification and firm privilege overview.
class ManageMembersRolesScreen extends StatelessWidget {
  const ManageMembersRolesScreen({super.key, required this.team});

  final TeamModel team;

  static const Color _bg = AppPalette.canvas;
  static const Color _card = AppPalette.cardBackground;
  static const Color _black = AppPalette.primaryGreen;
  static const Color _gold = AppPalette.accentGold;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: TeamHeader(
        title: 'Manage Members & Roles',
        subtitle: team.name,
        actions: [
          IconButton(
            tooltip: 'Invite Member',
            icon: const Icon(Icons.person_add_alt_1_rounded, color: _gold),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => InviteMemberScreen(team: team),
              ),
            ),
          ),
        ],
      ),
      body: StreamBuilder<List<TeamMembership>>(
        stream: TeamService.instance.watchMembers(team.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final members = snapshot.data ?? [];
          if (members.isEmpty) {
            return const Center(
              child: Text('No active members found.'),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: members.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final m = members[index];

              return Container(
                decoration: BoxDecoration(
                  color: _card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE5DFD7)),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MemberProfilePermissionsScreen(
                        member: m,
                        team: team,
                      ),
                    ),
                  ),
                  leading: CircleAvatar(
                    backgroundColor: _black,
                    radius: 22,
                    child: Text(
                      m.initials,
                      style: const TextStyle(color: _gold, fontWeight: FontWeight.w700),
                    ),
                  ),
                  title: Row(
                    children: [
                      Flexible(
                        child: Text(
                          m.displayName,
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: _roleColor(m.role).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          m.role.label.toUpperCase(),
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: _roleColor(m.role),
                          ),
                        ),
                      ),
                    ],
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '${m.advocateType.isNotEmpty ? m.advocateType : "Counsel"} · ${m.email}',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF6B665E)),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  trailing: const Icon(Icons.tune_rounded, color: Color(0xFF888888), size: 20),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Color _roleColor(TeamRole role) {
    switch (role) {
      case TeamRole.owner:
        return _gold;
      case TeamRole.leader:
        return const Color(0xFF4CAF50);
      case TeamRole.member:
        return const Color(0xFF64B5F6);
    }
  }
}

