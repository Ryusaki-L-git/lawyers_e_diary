import 'package:flutter/material.dart';

import '../../../models/team_model.dart';
import '../../../services/team_service.dart';
import '../../../widgets/app_palette.dart';
import '../widgets/team_header.dart';
import 'team_chat_member_screen.dart';

/// Screen 8: Group Details (Member View)
/// Shows practice group description, group roster, and shortcut to group communication.
class GroupDetailsMemberScreen extends StatelessWidget {
  const GroupDetailsMemberScreen({
    super.key,
    required this.group,
    required this.team,
    required this.membership,
  });

  final TeamGroup group;
  final TeamModel team;
  final TeamMembership membership;

  static const Color _bg = AppPalette.canvas;
  static const Color _card = AppPalette.cardBackground;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: TeamHeader(
        title: group.name,
        subtitle: group.practiceArea.isNotEmpty ? group.practiceArea : team.name,
        actions: [
          IconButton(
            tooltip: 'Group Chat',
            icon: const Icon(Icons.chat_bubble_outline_rounded, color: AppPalette.primaryGreen),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => TeamChatMemberScreen(team: team, membership: membership),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppPalette.borderLight),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppPalette.primaryGreen.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.folder_rounded, color: AppPalette.primaryGreen, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            group.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'serif',
                              color: AppPalette.textPrimary,
                            ),
                          ),
                          if (group.practiceArea.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              group.practiceArea,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppPalette.textMuted,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                if (group.description.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  const Divider(height: 1, color: AppPalette.borderLight),
                  const SizedBox(height: 12),
                  Text(
                    group.description,
                    style: const TextStyle(fontSize: 13, color: AppPalette.textMuted, height: 1.4),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),

          const Text(
            'GROUP MEMBERS',
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
              final allMembers = snapshot.data ?? [];
              final groupMembers = group.memberIds.isEmpty
                  ? allMembers
                  : allMembers.where((m) => group.memberIds.contains(m.userId)).toList();

              if (groupMembers.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No members assigned to this group yet.', style: TextStyle(color: AppPalette.textMuted)),
                );
              }

              return Container(
                decoration: BoxDecoration(
                  color: _card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppPalette.borderLight),
                ),
                child: Column(
                  children: groupMembers.asMap().entries.map((entry) {
                    final isLast = entry.key == groupMembers.length - 1;
                    final m = entry.value;

                    return Column(
                      children: [
                        ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppPalette.primaryGreen.withValues(alpha: 0.10),
                            child: Text(
                              m.initials,
                              style: const TextStyle(color: AppPalette.primaryGreen, fontSize: 13, fontWeight: FontWeight.w700),
                            ),
                          ),
                          title: Text(
                            m.displayName,
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppPalette.textPrimary),
                          ),
                          subtitle: Text(
                            m.role.label,
                            style: const TextStyle(fontSize: 12, color: AppPalette.textMuted),
                          ),
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
        ],
      ),
    );
  }
}

