import 'package:flutter/material.dart';

import '../../../models/team_model.dart';
import '../../../services/team_service.dart';
import '../../../widgets/app_palette.dart';
import '../widgets/team_header.dart';

/// Screen 12: Leave Team (Member View)
/// Formal exit workflow confirming that assigned cases will be unassigned and access revoked.
class LeaveTeamScreen extends StatefulWidget {
  const LeaveTeamScreen({super.key, required this.team});

  final TeamModel team;

  @override
  State<LeaveTeamScreen> createState() => _LeaveTeamScreenState();
}

class _LeaveTeamScreenState extends State<LeaveTeamScreen> {
  bool _confirmed = false;
  bool _isProcessing = false;

  static const Color _bg = AppPalette.canvas;
  static const Color _card = AppPalette.cardBackground;
  static const Color _red = AppPalette.unread;

  Future<void> _leaveTeam() async {
    if (!_confirmed) return;

    setState(() => _isProcessing = true);
    try {
      await TeamService.instance.leaveTeam(widget.team.id);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You have left the team practice.'),
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to leave team: $e'), backgroundColor: _red),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: TeamHeader(
        title: 'Leave Team Practice',
        subtitle: widget.team.name,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _red.withValues(alpha: 0.30)),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: _red.withValues(alpha: 0.10),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.warning_amber_rounded, color: _red, size: 28),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Confirm Firm Departure',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'serif',
                        color: AppPalette.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Leaving "${widget.team.name}" will immediately remove your access to the firm\'s master docket, practice groups, and team chat. Any matters assigned to you will need to be reallocated by firm leadership.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 13, color: AppPalette.textMuted, height: 1.45),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              CheckboxListTile(
                value: _confirmed,
                onChanged: (val) => setState(() => _confirmed = val ?? false),
                fillColor: WidgetStateProperty.all(_red),
                title: const Text(
                  'I understand that my access to this firm team will be revoked.',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppPalette.textPrimary),
                ),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
              const Spacer(),

              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: (_confirmed && !_isProcessing) ? _leaveTeam : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _red,
                    foregroundColor: AppPalette.cardBackground,
                    disabledBackgroundColor: _red.withValues(alpha: 0.30),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isProcessing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: AppPalette.cardBackground, strokeWidth: 2),
                        )
                      : const Text(
                          'Confirm & Leave Team',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                        ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel, Stay on Team', style: TextStyle(color: AppPalette.textMuted)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

