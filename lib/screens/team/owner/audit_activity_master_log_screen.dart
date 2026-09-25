import 'package:flutter/material.dart';

import '../../../models/team_model.dart';
import '../../../services/team_service.dart';
import '../../../widgets/app_palette.dart';
import '../widgets/team_header.dart';

/// Screen 13 (Owner): Audit & Activity Master Log
/// Comprehensive, unalterable event stream of all system changes, case assignments, deletions, and roles.
class AuditActivityMasterLogScreen extends StatelessWidget {
  const AuditActivityMasterLogScreen({super.key, required this.team});

  final TeamModel team;

  static const Color _bg = AppPalette.canvas;
  static const Color _card = AppPalette.cardBackground;
  static const Color _black = AppPalette.primaryGreen;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: TeamHeader(
        title: 'Audit & Activity Log',
        subtitle: '${team.lawFirm} · Immutable Records',
      ),
      body: StreamBuilder<List<TeamActivity>>(
        stream: TeamService.instance.watchActivityLogs(team.id, limit: 100),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final logs = snapshot.data ?? [];
          if (logs.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text('No logged audit events recorded yet.', style: TextStyle(color: Color(0xFF888888))),
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
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _card,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE5DFD7)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 2),
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: _black.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(_actionIcon(act.action), size: 18, color: _black),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            act.description,
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                'By: ${act.actorName}',
                                style: const TextStyle(fontSize: 11, color: Color(0xFF6B665E), fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                act.timestamp != null
                                    ? '${act.timestamp!.day}/${act.timestamp!.month}/${act.timestamp!.year} · ${act.timestamp!.hour.toString().padLeft(2, '0')}:${act.timestamp!.minute.toString().padLeft(2, '0')}'
                                    : 'Recorded',
                                style: const TextStyle(fontSize: 11, color: Color(0xFF888888)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  IconData _actionIcon(String action) {
    switch (action) {
      case 'assigned_case':
      case 'unassigned_case':
        return Icons.assignment_outlined;
      case 'added_member':
      case 'removed_member':
        return Icons.person_outline_rounded;
      case 'promoted_member':
        return Icons.military_tech_outlined;
      case 'created_group':
      case 'deleted_group':
        return Icons.folder_outlined;
      default:
        return Icons.history_rounded;
    }
  }
}

