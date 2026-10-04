import 'package:flutter/material.dart';

import '../../../models/team_model.dart';
import '../../../widgets/app_palette.dart';
import '../widgets/team_header.dart';

/// Screen 11: Transfer Ownership (Member View)
/// Informational screen explaining owner permissions, firm governance, and boundary checks.
class TransferOwnershipMemberScreen extends StatelessWidget {
  const TransferOwnershipMemberScreen({super.key, required this.team});

  final TeamModel team;

  static const Color _bg = AppPalette.canvas;
  static const Color _card = AppPalette.cardBackground;
  static const Color _gold = AppPalette.accentGold;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: TeamHeader(
        title: 'Firm Governance',
        subtitle: team.name,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                          color: _gold.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.shield_outlined, color: _gold, size: 24),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Text(
                          'Ownership & Authority',
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, fontFamily: 'serif', color: AppPalette.textPrimary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'As an Associate or Team Member, ownership transfer can only be executed by the current Managing Partner or Firm Owner.',
                    style: TextStyle(fontSize: 13, color: AppPalette.textMuted, height: 1.5),
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1, color: AppPalette.borderLight),
                  const SizedBox(height: 16),
                  _PermissionRow(
                    title: 'Managing Partner / Owner',
                    desc: 'Full administrative control, billing, member invites, ownership succession.',
                    color: AppPalette.accentGold,
                  ),
                  const SizedBox(height: 14),
                  const _PermissionRow(
                    title: 'Team Leader',
                    desc: 'Case assignments, practice group leadership, hearings oversight.',
                    color: AppPalette.primaryGreen,
                  ),
                  const SizedBox(height: 14),
                  const _PermissionRow(
                    title: 'Team Member',
                    desc: 'Assigned matters handling, shared document viewing, internal communication.',
                    color: AppPalette.deepGreen,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppPalette.primaryGreen,
                foregroundColor: AppPalette.cardBackground,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Understood'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PermissionRow extends StatelessWidget {
  const _PermissionRow({
    required this.title,
    required this.desc,
    required this.color,
  });

  final String title;
  final String desc;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 4),
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppPalette.textPrimary)),
              const SizedBox(height: 2),
              Text(desc, style: const TextStyle(fontSize: 12, color: AppPalette.textMuted, height: 1.35)),
            ],
          ),
        ),
      ],
    );
  }
}

