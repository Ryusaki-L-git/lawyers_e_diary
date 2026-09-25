import 'package:flutter/material.dart';

import '../../../models/team_model.dart';
import '../../../services/team_service.dart';
import '../../../widgets/app_palette.dart';
import '../widgets/team_header.dart';
import 'group_details_member_screen.dart';

/// Screen 7: Groups — My Groups (Member View)
/// Practice circles/groups to which the logged-in member belongs.
class GroupsMyGroupsScreen extends StatelessWidget {
  const GroupsMyGroupsScreen({
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
        title: 'My Practice Groups',
        subtitle: team.name,
        showBack: false,
      ),
      body: StreamBuilder<List<TeamGroup>>(
        stream: TeamService.instance.watchGroups(
          team.id,
          memberId: membership.userId,
        ),
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
                        color: AppPalette.primaryGreen.withValues(alpha: 0.10),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.folder_outlined,
                        color: AppPalette.primaryGreen,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No Practice Groups',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'serif',
                        color: AppPalette.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'You are not currently enrolled in any dedicated practice circles. Team leaders can assign you to groups.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: AppPalette.textMuted),
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
                      builder: (_) => GroupDetailsMemberScreen(
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
                      color: AppPalette.primaryGreen.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.folder_rounded, color: AppPalette.primaryGreen, size: 24),
                  ),
                  title: Text(
                    g.name,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppPalette.textPrimary),
                  ),
                  subtitle: Text(
                    g.practiceArea.isNotEmpty ? g.practiceArea : 'General Practice',
                    style: const TextStyle(fontSize: 12, color: AppPalette.textMuted),
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

