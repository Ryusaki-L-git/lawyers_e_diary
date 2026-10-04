import 'package:flutter/material.dart';

import '../../../models/team_model.dart';
import '../../../services/team_service.dart';
import '../../../widgets/app_palette.dart';
import '../widgets/team_header.dart';
import 'create_edit_group_screen.dart';

/// Screen 11 (Owner): Group Details (Leader / Owner View)
/// Group roster manipulation, group privacy settings, and group deletion.
class GroupDetailsLeaderScreen extends StatelessWidget {
  const GroupDetailsLeaderScreen({
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
  static const Color _red = Color(0xFFB3261E);

  Future<void> _deleteGroup(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Practice Group'),
        content: Text('Are you sure you want to delete "${group.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: _red, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      await TeamService.instance.deleteGroup(team.id, group.id, group.name);
      if (context.mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: TeamHeader(
        title: group.name,
        subtitle: group.practiceArea.isNotEmpty ? group.practiceArea : team.name,
        actions: [
          IconButton(
            tooltip: 'Edit Group',
            icon: const Icon(Icons.edit_outlined, color: Colors.white),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CreateEditGroupScreen(
                  team: team,
                  existingGroup: group,
                ),
              ),
            ),
          ),
          IconButton(
            tooltip: 'Delete Group',
            icon: const Icon(Icons.delete_outline_rounded, color: Colors.white),
            onPressed: () => _deleteGroup(context),
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
              border: Border.all(color: const Color(0xFFE5DFD7)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6750A4).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.folder_rounded, color: Color(0xFF6750A4), size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            group.name,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, fontFamily: 'serif'),
                          ),
                          if (group.practiceArea.isNotEmpty)
                            Text(
                              group.practiceArea,
                              style: const TextStyle(fontSize: 13, color: Color(0xFF6B665E), fontWeight: FontWeight.w600),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (group.description.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  const Divider(height: 1, color: Color(0xFFE5DFD7)),
                  const SizedBox(height: 10),
                  Text(group.description, style: const TextStyle(fontSize: 13, color: Color(0xFF6B665E), height: 1.4)),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Enrolled Members
          const Text(
            'ENROLLED COUNSEL',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF6B665E), letterSpacing: 0.8),
          ),
          const SizedBox(height: 8),

          StreamBuilder<List<TeamMembership>>(
            stream: TeamService.instance.watchMembers(team.id),
            builder: (context, snapshot) {
              final allMembers = snapshot.data ?? [];
              final enrolled = group.memberIds.isEmpty
                  ? allMembers
                  : allMembers.where((m) => group.memberIds.contains(m.userId)).toList();

              if (enrolled.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No associates enrolled in this group yet.', style: TextStyle(color: Color(0xFF888888))),
                );
              }

              return Container(
                decoration: BoxDecoration(
                  color: _card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE5DFD7)),
                ),
                child: Column(
                  children: enrolled.asMap().entries.map((entry) {
                    final isLast = entry.key == enrolled.length - 1;
                    final m = entry.value;

                    return Column(
                      children: [
                        ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppPalette.primaryGreen,
                            child: Text(m.initials, style: const TextStyle(color: AppPalette.accentGold, fontSize: 13, fontWeight: FontWeight.w700)),
                          ),
                          title: Text(m.displayName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                          subtitle: Text('${m.role.label} · ${m.advocateType}', style: const TextStyle(fontSize: 12, color: Color(0xFF6B665E))),
                        ),
                        if (!isLast)
                          const Divider(height: 1, indent: 64, color: Color(0xFFE5DFD7)),
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

