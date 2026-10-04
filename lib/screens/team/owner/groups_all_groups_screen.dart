import 'package:flutter/material.dart';

import '../../../models/team_model.dart';
import '../../../services/team_service.dart';
import '../../../widgets/app_palette.dart';
import '../widgets/team_header.dart';
import 'create_edit_group_screen.dart';
import 'group_details_leader_screen.dart';

/// Screen 9 (Owner): Groups — All Team Groups
/// Firm-wide practice group administration and creation hub.
class GroupsAllGroupsScreen extends StatelessWidget {
  const GroupsAllGroupsScreen({
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
      appBar: TeamHeader(
        title: 'Firm Practice Groups',
        subtitle: team.name,
        showBack: false,
        actions: [
          IconButton(
            tooltip: 'New Group',
            icon: const Icon(Icons.add_rounded, color: _gold),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CreateEditGroupScreen(team: team),
              ),
            ),
          ),
        ],
      ),
      body: StreamBuilder<List<TeamGroup>>(
        stream: TeamService.instance.watchGroups(team.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final groups = snapshot.data ?? [];
          if (groups.isEmpty) {
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
                        color: const Color(0xFF6750A4).withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.folder_outlined, color: Color(0xFF6750A4), size: 32),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No Practice Groups Established',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'serif',
                        color: AppPalette.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Organize your associates by practice area (Litigation, Criminal, Corporate, etc.).',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: Color(0xFF6B665E)),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CreateEditGroupScreen(team: team),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppPalette.primaryGreen,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.add_rounded, size: 18, color: _gold),
                      label: const Text('Create Practice Group'),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: groups.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final g = groups[index];

              return Container(
                decoration: BoxDecoration(
                  color: _card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppPalette.borderLight),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => GroupDetailsLeaderScreen(
                        group: g,
                        team: team,
                        membership: membership,
                      ),
                    ),
                  ),
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFF6750A4).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.folder_rounded, color: Color(0xFF6750A4), size: 24),
                  ),
                  title: Text(
                    g.name,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                  subtitle: Text(
                    '${g.practiceArea.isNotEmpty ? g.practiceArea : "Practice Circle"} · ${g.memberIds.length} associates',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF6B665E)),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded, color: AppPalette.textMuted),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
