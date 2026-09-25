import 'package:flutter/material.dart';

import '../../../models/team_model.dart';
import '../../../services/team_service.dart';
import '../../../widgets/app_palette.dart';
import '../widgets/team_header.dart';
import 'archive_delete_team_screen.dart';
import 'transfer_ownership_owner_screen.dart';

/// Screen 14 (Owner): Team Settings & Access Policy
/// Firm profile, chamber branding, cloud storage quota, and external sharing policies.
class TeamSettingsScreen extends StatefulWidget {
  const TeamSettingsScreen({super.key, required this.team});

  final TeamModel team;

  @override
  State<TeamSettingsScreen> createState() => _TeamSettingsScreenState();
}

class _TeamSettingsScreenState extends State<TeamSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _firmController;
  late final TextEditingController _descController;
  bool _isSaving = false;

  static const Color _bg = AppPalette.canvas;
  static const Color _card = AppPalette.cardBackground;
  static const Color _black = AppPalette.primaryGreen;
  static const Color _gold = AppPalette.accentGold;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.team.name);
    _firmController = TextEditingController(text: widget.team.lawFirm);
    _descController = TextEditingController(text: widget.team.description);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _firmController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      await TeamService.instance.updateTeam(
        widget.team.id,
        name: _nameController.text.trim(),
        lawFirm: _firmController.text.trim(),
        description: _descController.text.trim(),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Team settings updated successfully.'),
          backgroundColor: Color(0xFF1F3D2B),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: TeamHeader(
        title: 'Team Settings',
        subtitle: widget.team.name,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // General Settings Card
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
                      const Text(
                        'Team Name *',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _nameController,
                        decoration: _inputDecoration(),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Name required' : null,
                      ),
                      const SizedBox(height: 16),

                      const Text(
                        'Firm or Chamber Name *',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _firmController,
                        decoration: _inputDecoration(),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Firm required' : null,
                      ),
                      const SizedBox(height: 16),

                      const Text(
                        'Practice Description',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _descController,
                        maxLines: 3,
                        decoration: _inputDecoration(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Cloud Storage & Sync Status
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: _card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE5DFD7)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.cloud_done_rounded, color: Color(0xFF1F3D2B), size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Firm Cloud Storage Quota',
                            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'This firm is connected to Firestore real-time cloud sync. All filings, hearings, and fee records are encrypted and backed up.',
                        style: TextStyle(fontSize: 12, color: Color(0xFF6B665E), height: 1.4),
                      ),
                      const SizedBox(height: 14),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: const LinearProgressIndicator(
                          value: 0.15,
                          minHeight: 6,
                          backgroundColor: Color(0xFFE5DFD7),
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1F3D2B)),
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        '0.75 GB used of 5 GB Cloud Tier',
                        style: TextStyle(fontSize: 11, color: Color(0xFF888888)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Save button
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveSettings,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _black,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: _gold, strokeWidth: 2),
                          )
                        : const Text('Save Firm Settings', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                  ),
                ),
                const SizedBox(height: 24),

                // Fast links to succession & archive
                const Text(
                  'GOVERNANCE CONTROLS',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF6B665E), letterSpacing: 0.8),
                ),
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
                        leading: const Icon(Icons.swap_horiz_rounded, color: _gold),
                        title: const Text('Transfer Ownership', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600)),
                        subtitle: const Text('Hand over practice authority to a partner', style: TextStyle(fontSize: 11.5, color: Color(0xFF888888))),
                        trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF888888)),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TransferOwnershipOwnerScreen(team: widget.team),
                          ),
                        ),
                      ),
                      const Divider(height: 1, indent: 64, color: Color(0xFFE5DFD7)),
                      ListTile(
                        leading: const Icon(Icons.delete_outline_rounded, color: Color(0xFFB3261E)),
                        title: const Text('Archive or Dissolve Team', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: Color(0xFFB3261E))),
                        subtitle: const Text('Firm team retirement and data export', style: TextStyle(fontSize: 11.5, color: Color(0xFF888888))),
                        trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFFB3261E)),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ArchiveDeleteTeamScreen(team: widget.team),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: const Color(0xFFF9F8F6),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE5DFD7))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE5DFD7))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _gold)),
    );
  }
}

