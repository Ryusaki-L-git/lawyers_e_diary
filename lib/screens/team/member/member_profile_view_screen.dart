import 'package:flutter/material.dart';

import '../../../models/team_model.dart';
import '../../../widgets/app_palette.dart';
import '../widgets/team_header.dart';

/// Screen 4: Member Profile (View Only)
/// Detailed profile of a team colleague with contact actions.
class MemberProfileViewScreen extends StatelessWidget {
  const MemberProfileViewScreen({
    super.key,
    required this.membership,
    required this.team,
  });

  final TeamMembership membership;
  final TeamModel team;

  static const Color _bg = AppPalette.canvas;
  static const Color _card = AppPalette.cardBackground;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: TeamHeader(
        title: 'Member Profile',
        subtitle: team.name,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: _card,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppPalette.borderLight),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: AppPalette.primaryGreen.withValues(alpha: 0.10),
                    child: Text(
                      membership.initials,
                      style: const TextStyle(
                        color: AppPalette.primaryGreen,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    membership.displayName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'serif',
                      color: AppPalette.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    membership.advocateType.isNotEmpty
                        ? membership.advocateType
                        : 'Advocate',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppPalette.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppPalette.primaryGreen.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      membership.role.label.toUpperCase(),
                      style: const TextStyle(
                        color: AppPalette.primaryGreen,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'CHAMBER & CONTACT',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppPalette.textMuted,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: _card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppPalette.borderLight),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.email_outlined, color: AppPalette.textMuted),
                    title: const Text('Email', style: TextStyle(fontSize: 12, color: AppPalette.textMuted)),
                    subtitle: Text(
                      membership.email.isNotEmpty ? membership.email : 'Not provided',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppPalette.textPrimary),
                    ),
                  ),
                  const Divider(height: 1, indent: 64, color: AppPalette.borderLight),
                  ListTile(
                    leading: const Icon(Icons.phone_outlined, color: AppPalette.textMuted),
                    title: const Text('Phone', style: TextStyle(fontSize: 12, color: AppPalette.textMuted)),
                    subtitle: Text(
                      membership.phone.isNotEmpty ? membership.phone : 'Not provided',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppPalette.textPrimary),
                    ),
                  ),
                  const Divider(height: 1, indent: 64, color: AppPalette.borderLight),
                  ListTile(
                    leading: const Icon(Icons.calendar_today_outlined, color: AppPalette.textMuted),
                    title: const Text('Joined Team', style: TextStyle(fontSize: 12, color: AppPalette.textMuted)),
                    subtitle: Text(
                      membership.joinedAt != null
                          ? '${membership.joinedAt!.day}/${membership.joinedAt!.month}/${membership.joinedAt!.year}'
                          : 'Active Member',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppPalette.textPrimary),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

