import 'package:flutter/material.dart';

import '../../../models/team_model.dart';
import '../../../services/team_service.dart';
import '../../../widgets/app_palette.dart';
import '../widgets/team_header.dart';

/// Screen 5 (Owner): Member Profile & Permissions Control
/// Detailed edit screen for associate permissions and role alterations.
class MemberProfilePermissionsScreen extends StatefulWidget {
  const MemberProfilePermissionsScreen({
    super.key,
    required this.member,
    required this.team,
  });

  final TeamMembership member;
  final TeamModel team;

  @override
  State<MemberProfilePermissionsScreen> createState() =>
      _MemberProfilePermissionsScreenState();
}

class _MemberProfilePermissionsScreenState
    extends State<MemberProfilePermissionsScreen> {
  late TeamRole _role;
  late bool _canCreateCases;
  late bool _canDeleteCases;
  late bool _canInviteMembers;
  late bool _canExportAudit;
  bool _isSaving = false;

  static const Color _bg = AppPalette.canvas;
  static const Color _card = AppPalette.cardBackground;
  static const Color _black = AppPalette.primaryGreen;
  static const Color _gold = AppPalette.accentGold;
  static const Color _red = Color(0xFFB3261E);

  @override
  void initState() {
    super.initState();
    _role = widget.member.role;
    _canCreateCases = widget.member.permissions.canCreateCases;
    _canDeleteCases = widget.member.permissions.canDeleteCases;
    _canInviteMembers = widget.member.permissions.canInviteMembers;
    _canExportAudit = widget.member.permissions.canExportAudit;
  }

  Future<void> _saveChanges() async {
    setState(() => _isSaving = true);
    try {
      final memberDocumentId =
          widget.member.membershipDocumentId ?? widget.member.userId;
      if (_role != widget.member.role) {
        await TeamService.instance.updateMemberRole(
          widget.team.id,
          memberDocumentId,
          _role,
        );
      }

      await TeamService.instance.updateMemberPermissions(
        widget.team.id,
        memberDocumentId,
        MemberPermissions(
          canCreateCases: _canCreateCases,
          canDeleteCases: _canDeleteCases,
          canInviteMembers: _canInviteMembers,
          canExportAudit: _canExportAudit,
        ),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Member permissions updated successfully.'),
          backgroundColor: Color(0xFF1F3D2B),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update: $e'), backgroundColor: _red),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _removeMember() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove from Team'),
        content: Text(
          'Are you sure you want to remove ${widget.member.displayName} from ${widget.team.name}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: _red, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await TeamService.instance.removeMember(
        widget.team.id,
        widget.member.membershipDocumentId ?? widget.member.userId,
        widget.member.displayName,
      );
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOwner = widget.member.role == TeamRole.owner;

    return Scaffold(
      backgroundColor: _bg,
      appBar: TeamHeader(
        title: 'Permissions & Access',
        subtitle: widget.member.displayName,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Profile preview
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5DFD7)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: _black,
                  child: Text(
                    widget.member.initials,
                    style: const TextStyle(color: _gold, fontWeight: FontWeight.w700, fontSize: 18),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.member.displayName,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppPalette.textPrimary),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.member.email,
                        style: const TextStyle(fontSize: 12, color: Color(0xFF6B665E)),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.member.advocateType.isNotEmpty ? widget.member.advocateType : 'Counsel',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF888888)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Role selection
          if (!isOwner) ...[
            const Text(
              'TEAM ROLE',
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
                  RadioListTile<TeamRole>(
                    value: TeamRole.member,
                    // ignore: deprecated_member_use
                    groupValue: _role,
                    // ignore: deprecated_member_use
                    onChanged: (val) => setState(() => _role = val!),
                    fillColor: WidgetStateProperty.all(_gold),
                    title: const Text('Associate Member', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    subtitle: const Text('Handles assigned cases and view permissions', style: TextStyle(fontSize: 12, color: Color(0xFF6B665E))),
                  ),
                  const Divider(height: 1, indent: 64, color: Color(0xFFE5DFD7)),
                  RadioListTile<TeamRole>(
                    value: TeamRole.leader,
                    // ignore: deprecated_member_use
                    groupValue: _role,
                    // ignore: deprecated_member_use
                    onChanged: (val) => setState(() => _role = val!),
                    fillColor: WidgetStateProperty.all(_gold),
                    title: const Text('Team Leader', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    subtitle: const Text('Supervises groups, assigns matters, invites counsel', style: TextStyle(fontSize: 12, color: Color(0xFF6B665E))),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Permissions toggles
          const Text(
            'GRANULAR PRIVILEGES',
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
                SwitchListTile(
                  value: _canCreateCases,
                  onChanged: isOwner ? null : (v) => setState(() => _canCreateCases = v),
                  activeThumbColor: _gold,
                  title: const Text('Create New Cases', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
                  subtitle: const Text('Permit filing new matters under the firm name', style: TextStyle(fontSize: 11.5, color: Color(0xFF6B665E))),
                ),
                const Divider(height: 1, indent: 16, color: Color(0xFFE5DFD7)),
                SwitchListTile(
                  value: _canDeleteCases,
                  onChanged: isOwner ? null : (v) => setState(() => _canDeleteCases = v),
                  activeThumbColor: _gold,
                  title: const Text('Delete / Archive Matters', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
                  subtitle: const Text('Permit soft-deleting and closing firm cases', style: TextStyle(fontSize: 11.5, color: Color(0xFF6B665E))),
                ),
                const Divider(height: 1, indent: 16, color: Color(0xFFE5DFD7)),
                SwitchListTile(
                  value: _canInviteMembers,
                  onChanged: isOwner ? null : (v) => setState(() => _canInviteMembers = v),
                  activeThumbColor: _gold,
                  title: const Text('Invite Associates', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
                  subtitle: const Text('Permit issuing firm roster invitations', style: TextStyle(fontSize: 11.5, color: Color(0xFF6B665E))),
                ),
                const Divider(height: 1, indent: 16, color: Color(0xFFE5DFD7)),
                SwitchListTile(
                  value: _canExportAudit,
                  onChanged: isOwner ? null : (v) => setState(() => _canExportAudit = v),
                  activeThumbColor: _gold,
                  title: const Text('Export Audit Log', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
                  subtitle: const Text('Permit generating firm compliance reports', style: TextStyle(fontSize: 11.5, color: Color(0xFF6B665E))),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Save button
          SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _saveChanges,
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
                  : const Text('Save Permissions', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            ),
          ),

          if (!isOwner) ...[
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _removeMember,
              style: OutlinedButton.styleFrom(
                foregroundColor: _red,
                side: const BorderSide(color: _red),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.person_remove_outlined, size: 18),
              label: const Text('Remove from Firm Roster', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ],
        ],
      ),
    );
  }
}
