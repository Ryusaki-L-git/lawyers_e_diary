import 'package:flutter/material.dart';

import '../../../models/team_model.dart';
import '../../../services/team_service.dart';
import '../../../widgets/app_palette.dart';
import '../widgets/team_header.dart';

/// Screen 10: Activity Log (Member View)
/// Audited event stream of actions relevant to cases, assignments, and team notices.
class ActivityLogMemberScreen extends StatelessWidget {
  const ActivityLogMemberScreen({super.key, required this.team});

  final TeamModel team;

  static const Color _bg = AppPalette.canvas;
  static const Color _card = AppPalette.cardBackground;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: TeamHeader(
        title: 'Team Activity Log',
        subtitle: team.name,
      ),
      body: StreamBuilder<List<TeamActivity>>(
        stream: TeamService.instance.watchActivityLogs(team.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final logs = snapshot.data ?? [];
          if (logs.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text('No recorded team activity yet.', style: TextStyle(color: AppPalette.textMuted)),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: logs.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final act = logs[index];
              return Container(
                decoration: BoxDecoration(
                  color: _card,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppPalette.borderLight),
                ),
                child: ListTile(
                  leading: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppPalette.primaryGreen.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.history_rounded, color: AppPalette.primaryGreen, size: 20),
                  ),
                  title: Text(
                    act.description,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5, color: AppPalette.textPrimary),
                  ),
                  subtitle: Text(
                    act.timestamp != null
                        ? '${act.timestamp!.day}/${act.timestamp!.month} ${act.timestamp!.hour.toString().padLeft(2, '0')}:${act.timestamp!.minute.toString().padLeft(2, '0')}'
                        : 'Recent',
                    style: const TextStyle(fontSize: 11, color: AppPalette.textMuted),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

