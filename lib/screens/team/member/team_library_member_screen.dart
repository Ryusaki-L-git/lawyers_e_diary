import 'package:flutter/material.dart';

import '../../../models/team_model.dart';
import '../../../widgets/app_palette.dart';
import '../widgets/team_header.dart';
import 'cases_all_team_cases_screen.dart';

/// Screen 2: Team Library (Member View)
/// Permitted resources: Shared templates, court documents, pleading banks, firm guidelines.
class TeamLibraryMemberScreen extends StatelessWidget {
  const TeamLibraryMemberScreen({super.key, required this.team});

  final TeamModel team;

  static const Color _bg = AppPalette.canvas;
  static const Color _card = AppPalette.cardBackground;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: TeamHeader(
        title: 'Team Library',
        subtitle: team.name,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _SectionTitle('FIRM REPOSITORIES'),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppPalette.borderLight),
            ),
            child: Column(
              children: [
                _RepoTile(
                  icon: Icons.gavel_rounded,
                  color: AppPalette.primaryGreen,
                  title: 'All Firm Cases',
                  subtitle: 'Central docket repository',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CasesAllTeamCasesScreen(team: team),
                    ),
                  ),
                ),
                const Divider(height: 1, indent: 64, color: AppPalette.borderLight),
                _RepoTile(
                  icon: Icons.description_outlined,
                  color: AppPalette.accentGold,
                  title: 'Drafting Studio Templates',
                  subtitle: 'Shared legal notices, petitions & affidavits',
                  onTap: () => Navigator.of(context).pushNamed('/juris'),
                ),
                const Divider(height: 1, indent: 64, color: AppPalette.borderLight),
                _RepoTile(
                  icon: Icons.folder_shared_outlined,
                  color: AppPalette.deepGreen,
                  title: 'Chamber Document Vault',
                  subtitle: 'Standard contracts, vakalatnamas & forms',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Chamber Document Vault is synced with Cloud.'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _SectionTitle('PRACTICE DIRECTIVES'),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppPalette.borderLight),
            ),
            child: const Column(
              children: [
                ListTile(
                  leading: Icon(Icons.bookmark_border_rounded, color: AppPalette.textMuted),
                  title: Text(
                    'Court Filing Guidelines',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppPalette.textPrimary),
                  ),
                  subtitle: Text(
                    'District, High Court and Tribunal protocols',
                    style: TextStyle(fontSize: 12, color: AppPalette.textMuted),
                  ),
                ),
                Divider(height: 1, indent: 64, color: AppPalette.borderLight),
                ListTile(
                  leading: Icon(Icons.shield_outlined, color: AppPalette.textMuted),
                  title: Text(
                    'Confidentiality & Ethics Policy',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppPalette.textPrimary),
                  ),
                  subtitle: Text(
                    'Bar Council norms & client privacy standards',
                    style: TextStyle(fontSize: 12, color: AppPalette.textMuted),
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

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);
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

class _RepoTile extends StatelessWidget {
  const _RepoTile({
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
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppPalette.textPrimary),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 12, color: AppPalette.textMuted),
      ),
      trailing: const Icon(Icons.chevron_right_rounded, color: AppPalette.textMuted),
    );
  }
}

