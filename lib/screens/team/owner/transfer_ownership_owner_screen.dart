import 'package:flutter/material.dart';

import '../../../models/team_model.dart';
import '../../../services/team_service.dart';
import '../../../widgets/app_palette.dart';
import '../widgets/team_header.dart';

/// Screen 15 (Owner): Transfer Team Ownership
/// Owner succession protocol with 2-step verification and role demotion to Leader.
class TransferOwnershipOwnerScreen extends StatefulWidget {
  const TransferOwnershipOwnerScreen({super.key, required this.team});

  final TeamModel team;

  @override
  State<TransferOwnershipOwnerScreen> createState() =>
      _TransferOwnershipOwnerScreenState();
}

class _TransferOwnershipOwnerScreenState
    extends State<TransferOwnershipOwnerScreen> {
  TeamMembership? _selectedSuccessor;
  bool _confirmed = false;
  bool _isProcessing = false;

  static const Color _bg = AppPalette.canvas;
  static const Color _card = AppPalette.cardBackground;
  static const Color _black = AppPalette.primaryGreen;
  static const Color _gold = AppPalette.accentGold;
  static const Color _red = Color(0xFFB3261E);

  Future<void> _executeTransfer() async {
    if (_selectedSuccessor == null || !_confirmed) return;

    setState(() => _isProcessing = true);
    try {
      await TeamService.instance.transferOwnership(
        teamId: widget.team.id,
        newOwnerId: _selectedSuccessor!.userId,
        newOwnerName: _selectedSuccessor!.displayName,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Firm ownership transferred to ${_selectedSuccessor!.displayName}.'),
          backgroundColor: const Color(0xFF1F3D2B),
        ),
      );
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Transfer failed: $e'), backgroundColor: _red),
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
        title: 'Transfer Practice Ownership',
        subtitle: widget.team.name,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Warning card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: _card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _red.withValues(alpha: 0.4)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: _red, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Owner Succession Protocol',
                            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: _red),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Transferring ownership of "${widget.team.name}" will promote the selected counsel to Managing Partner / Owner. Your status will be demoted to Team Leader. This action cannot be unilaterally reversed.',
                            style: const TextStyle(fontSize: 12, color: Color(0xFF6B665E), height: 1.4),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Select successor
              const Text(
                'SELECT NEW MANAGING PARTNER',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF6B665E), letterSpacing: 0.8),
              ),
              const SizedBox(height: 8),

              StreamBuilder<List<TeamMembership>>(
                stream: TeamService.instance.watchMembers(widget.team.id),
                builder: (context, snapshot) {
                  final all = snapshot.data ?? [];
                  final candidates = all
                      .where(
                        (m) =>
                            m.hasFirebaseIdentity && m.role != TeamRole.owner,
                      )
                      .toList();

                  if (candidates.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _card,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE5DFD7)),
                      ),
                      child: const Text(
                        'No other associates found on the roster to receive ownership. Invite counsel first.',
                        style: TextStyle(fontSize: 13, color: Color(0xFF888888)),
                      ),
                    );
                  }

                  return Container(
                    decoration: BoxDecoration(
                      color: _card,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE5DFD7)),
                    ),
                    child: Column(
                      children: candidates.map((m) {
                        final isSelected = _selectedSuccessor?.userId == m.userId;

                        return RadioListTile<TeamMembership>(
                          value: m,
                          // ignore: deprecated_member_use
                          groupValue: _selectedSuccessor,
                          // ignore: deprecated_member_use
                          onChanged: (val) => setState(() => _selectedSuccessor = val),
                          fillColor: WidgetStateProperty.all(_gold),
                          title: Text(m.displayName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                          subtitle: Text('${m.role.label} · ${m.advocateType}', style: const TextStyle(fontSize: 12, color: Color(0xFF6B665E))),
                          secondary: CircleAvatar(
                            backgroundColor: isSelected ? _gold : _black,
                            radius: 16,
                            child: Text(
                              m.initials,
                              style: TextStyle(color: isSelected ? _black : _gold, fontWeight: FontWeight.w700, fontSize: 11),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),

              // Confirmation checkbox
              CheckboxListTile(
                value: _confirmed,
                onChanged: (val) => setState(() => _confirmed = val ?? false),
                fillColor: WidgetStateProperty.all(_red),
                title: const Text(
                  'I solemnly confirm that I am transferring primary authority and ownership of this practice team.',
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                ),
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
              ),
              const SizedBox(height: 24),

              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: (_selectedSuccessor != null && _confirmed && !_isProcessing)
                      ? _executeTransfer
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _red,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: _red.withValues(alpha: 0.3),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isProcessing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          'Execute Ownership Succession',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
