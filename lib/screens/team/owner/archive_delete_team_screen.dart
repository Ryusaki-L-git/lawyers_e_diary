import 'package:flutter/material.dart';

import '../../../models/team_model.dart';
import '../../../services/team_service.dart';
import '../../../widgets/app_palette.dart';
import '../widgets/team_header.dart';

/// Screen 16 (Owner): Archive / Delete Team
/// High-risk firm practice dissolution workflow with confirmation.
class ArchiveDeleteTeamScreen extends StatefulWidget {
  const ArchiveDeleteTeamScreen({super.key, required this.team});

  final TeamModel team;

  @override
  State<ArchiveDeleteTeamScreen> createState() =>
      _ArchiveDeleteTeamScreenState();
}

class _ArchiveDeleteTeamScreenState extends State<ArchiveDeleteTeamScreen> {
  final _confirmController = TextEditingController();
  bool _isProcessing = false;

  static const Color _bg = AppPalette.canvas;
  static const Color _card = AppPalette.cardBackground;
  static const Color _red = Color(0xFFB3261E);

  @override
  void dispose() {
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _archiveTeam() async {
    setState(() => _isProcessing = true);
    try {
      await TeamService.instance.archiveTeam(widget.team.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Firm team archived.'),
          backgroundColor: Color(0xFF1F3D2B),
        ),
      );
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: $e'), backgroundColor: _red),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _deleteTeam() async {
    if (_confirmController.text.trim() != widget.team.name.trim()) return;

    setState(() => _isProcessing = true);
    try {
      await TeamService.instance.deleteTeam(widget.team.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Practice team permanently dissolved.'),
          backgroundColor: _red,
        ),
      );
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: $e'), backgroundColor: _red),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final matchesName = _confirmController.text.trim() == widget.team.name.trim();

    return Scaffold(
      backgroundColor: _bg,
      appBar: TeamHeader(
        title: 'Dissolve Practice Team',
        subtitle: widget.team.name,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Archive Option
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
                        Icon(Icons.archive_outlined, color: Color(0xFF1F3D2B), size: 22),
                        SizedBox(width: 10),
                        Text(
                          'Option 1: Soft Archive Team',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Archiving suspends active collaboration. Firm dockets and historical records are preserved and can be reactivated by the managing partner.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF6B665E), height: 1.4),
                    ),
                    const SizedBox(height: 14),
                    OutlinedButton.icon(
                      onPressed: _isProcessing ? null : _archiveTeam,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF1F3D2B),
                        side: const BorderSide(color: Color(0xFF1F3D2B)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(Icons.archive_outlined, size: 18),
                      label: const Text('Archive Team Practice', style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Permanent Deletion Option
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: _card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _red.withValues(alpha: 0.4)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.delete_forever_rounded, color: _red, size: 22),
                        SizedBox(width: 10),
                        Text(
                          'Option 2: Permanent Dissolution',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: _red),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Irreversible action: Dissolving "${widget.team.name}" deletes all practice groups, group conversations, and revocations for all associates.',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF6B665E), height: 1.4),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Type "${widget.team.name}" to confirm permanent deletion:',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _confirmController,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: widget.team.name,
                        hintStyle: const TextStyle(fontSize: 12, color: Color(0xFFA09B93)),
                        filled: true,
                        fillColor: const Color(0xFFF9F8F6),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE5DFD7))),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _red)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: (matchesName && !_isProcessing) ? _deleteTeam : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _red,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: _red.withValues(alpha: 0.25),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: _isProcessing
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : const Text('Dissolve Team Permanently', style: TextStyle(fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

