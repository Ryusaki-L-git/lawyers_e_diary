import 'package:flutter/material.dart';

import '../../../models/team_model.dart';
import '../../../widgets/app_palette.dart';
import '../widgets/team_header.dart';
import 'cases_master_docket_screen.dart';

/// Screen 2 (Owner): Team Library (Owner View)
/// Unrestricted firm asset repository with creation/upload capabilities.
class TeamLibraryOwnerScreen extends StatelessWidget {
  const TeamLibraryOwnerScreen({super.key, required this.team});

  final TeamModel team;

  static const Color _bg = AppPalette.canvas;
  static const Color _card = AppPalette.cardBackground;
  static const Color _gold = AppPalette.accentGold;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: TeamHeader(
        title: 'Firm Asset Library',
        subtitle: team.name,
        actions: [
          IconButton(
            tooltip: 'Add Shared Document',
            icon: const Icon(Icons.add_rounded, color: _gold),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Document uploaded to Chamber Vault.'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _SectionHeader('CENTRAL FIRM STORAGE'),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5DFD7)),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1F3D2B).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.gavel_rounded, color: Color(0xFF1F3D2B), size: 20),
                  ),
                  title: const Text('Master Case Records', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  subtitle: const Text('All digital files & exhibits', style: TextStyle(fontSize: 12, color: Color(0xFF6B665E))),
                  trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF888888)),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CasesMasterDocketScreen(team: team),
                    ),
                  ),
                ),
                const Divider(height: 1, indent: 64, color: Color(0xFFE5DFD7)),
                ListTile(
                  leading: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: _gold.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.description_outlined, color: _gold, size: 20),
                  ),
                  title: const Text('Drafting Studio Precedents', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  subtitle: const Text('Standard pleading banks & legal notices', style: TextStyle(fontSize: 12, color: Color(0xFF6B665E))),
                  trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF888888)),
                  onTap: () => Navigator.of(context).pushNamed('/juris'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _SectionHeader('CHAMBER POLICIES & TEMPLATES'),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5DFD7)),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.lock_person_outlined, color: Color(0xFF6B665E)),
                  title: const Text('Firm Fee Schedule & Quoting Guidelines', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  subtitle: const Text('Standard rates, retainers & court appearances', style: TextStyle(fontSize: 12, color: Color(0xFF888888))),
                  trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF888888)),
                  onTap: () => Navigator.of(context).pushNamed('/fee'),
                ),
                const Divider(height: 1, indent: 64, color: Color(0xFFE5DFD7)),
                const ListTile(
                  leading: Icon(Icons.rule_folder_outlined, color: Color(0xFF6B665E)),
                  title: Text('Court Protocol & Registry Manual', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  subtitle: Text('Filing requirements and limitation rules', style: TextStyle(fontSize: 12, color: Color(0xFF888888))),
                  trailing: Icon(Icons.chevron_right_rounded, color: Color(0xFF888888)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: Color(0xFF6B665E),
        letterSpacing: 0.8,
      ),
    );
  }
}

