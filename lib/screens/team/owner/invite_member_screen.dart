import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../../models/team_model.dart';
import '../../../services/team_service.dart';
import '../../../widgets/app_palette.dart';
import '../widgets/team_header.dart';

/// Screen 6 (Owner): Add an LED member or prepare an invitation for a new user.
class InviteMemberScreen extends StatefulWidget {
  const InviteMemberScreen({super.key, required this.team});

  final TeamModel team;

  @override
  State<InviteMemberScreen> createState() => _InviteMemberScreenState();
}

class _InviteMemberScreenState extends State<InviteMemberScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ledIdController = TextEditingController();
  final _recipientController = TextEditingController();
  LedUserProfile? _foundUser;
  bool _inviteSomeone = false;
  bool _inviteByEmail = true;
  TeamRole _selectedRole = TeamRole.member;

  bool _canCreateCases = true;
  bool _canDeleteCases = false;
  bool _canInviteMembers = false;
  bool _canExportAudit = false;
  bool _isLoading = false;

  static const Color _bg = AppPalette.canvas;
  static const Color _card = AppPalette.cardBackground;
  static const Color _black = AppPalette.primaryGreen;
  static const Color _gold = AppPalette.accentGold;

  @override
  void dispose() {
    _ledIdController.dispose();
    _recipientController.dispose();
    super.dispose();
  }

  Future<void> _findLedUser() async {
    final ledId = _ledIdController.text.trim();
    if (ledId.isEmpty) {
      _showMessage('Enter the user\'s LED ID.');
      return;
    }
    setState(() => _isLoading = true);
    try {
      final user = await TeamService.instance.findLedUserById(ledId);
      if (!mounted) return;
      setState(() => _foundUser = user);
      _showMessage(
        user == null
            ? 'No LED profile found for that ID.'
            : 'Verified LED profile found.',
      );
    } catch (error) {
      if (mounted) _showMessage('Could not find that LED profile: $error');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _addLedUser() async {
    final user = _foundUser;
    if (user == null) {
      _showMessage('Find a user by LED ID before adding them.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await TeamService.instance.addExistingLedUser(
        teamId: widget.team.id,
        user: user,
        role: _selectedRole,
        permissions: MemberPermissions(
          canCreateCases: _canCreateCases,
          canDeleteCases: _canDeleteCases,
          canInviteMembers: _canInviteMembers,
          canExportAudit: _canExportAudit,
        ),
      );

      if (!mounted) return;
      _showMessage('${user.name} added to the team.');
      Navigator.pop(context);
    } catch (e) {
      if (mounted) _showMessage('Could not add this LED user: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _prepareInvitation() async {
    final contact = _recipientController.text.trim();
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final message =
          await TeamService.instance.buildTeamInvitationMessage(
        teamId: widget.team.id,
        recipient: contact,
      );
      await SharePlus.instance.share(
        ShareParams(
          text: message,
          subject: 'Lawyer\'s E-Diary team invitation',
        ),
      );
      if (mounted) {
        _showMessage('Invitation text is ready to share. No team member was added.');
      }
    } catch (error) {
      if (mounted) {
        _showMessage('Could not prepare the invitation: $error', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            isError ? Colors.red : const Color(0xFF1F3D2B),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: TeamHeader(
        title: 'Add Team Member',
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
                      Wrap(
                        spacing: 8,
                        children: [
                          ChoiceChip(
                            label: const Text('Add existing LED user'),
                            selected: !_inviteSomeone,
                            onSelected: _isLoading
                                ? null
                                : (_) => setState(() {
                                      _inviteSomeone = false;
                                      _foundUser = null;
                                    }),
                          ),
                          ChoiceChip(
                            label: const Text('Invite someone to LED'),
                            selected: _inviteSomeone,
                            onSelected: _isLoading
                                ? null
                                : (_) => setState(() {
                                      _inviteSomeone = true;
                                      _foundUser = null;
                                    }),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      if (!_inviteSomeone) ...[
                        const Text(
                          'LED ID',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _ledIdController,
                          textCapitalization: TextCapitalization.characters,
                          decoration: _inputDecoration(hint: 'e.g. 0043-2026'),
                          onChanged: (_) => setState(() => _foundUser = null),
                        ),
                        const SizedBox(height: 10),
                        OutlinedButton.icon(
                          onPressed: _isLoading ? null : _findLedUser,
                          icon: const Icon(Icons.search_rounded),
                          label: const Text('Find LED user'),
                        ),
                        if (_foundUser != null) ...[
                          const SizedBox(height: 12),
                          _FoundLedUserCard(user: _foundUser!),
                        ],
                        const SizedBox(height: 24),
                        const Text(
                          'Assign Team Role',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: _RoleChoiceCard(
                                title: 'Member',
                                desc: 'Assigned matters',
                                isSelected: _selectedRole == TeamRole.member,
                                onTap: () => setState(() {
                                  _selectedRole = TeamRole.member;
                                  _canDeleteCases = false;
                                  _canInviteMembers = false;
                                }),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _RoleChoiceCard(
                                title: 'Leader',
                                desc: 'Group & allocation oversight',
                                isSelected: _selectedRole == TeamRole.leader,
                                onTap: () => setState(() {
                                  _selectedRole = TeamRole.leader;
                                  _canInviteMembers = true;
                                }),
                              ),
                            ),
                          ],
                        ),
                      ] else ...[
                        const Text(
                          'Invite by',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SegmentedButton<bool>(
                          segments: const [
                            ButtonSegment(
                              value: true,
                              label: Text('Email'),
                              icon: Icon(Icons.email_outlined),
                            ),
                            ButtonSegment(
                              value: false,
                              label: Text('Phone / WhatsApp'),
                              icon: Icon(Icons.phone_outlined),
                            ),
                          ],
                          selected: {_inviteByEmail},
                          onSelectionChanged: _isLoading
                              ? null
                              : (selection) => setState(() {
                                    _inviteByEmail = selection.first;
                                    _recipientController.clear();
                                  }),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _recipientController,
                          keyboardType: _inviteByEmail
                              ? TextInputType.emailAddress
                              : TextInputType.phone,
                          decoration: _inputDecoration(
                            hint: _inviteByEmail
                                ? 'advocate@lawfirm.com'
                                : '+91 98765 43210',
                          ),
                          validator: (value) {
                            if (!_inviteSomeone) return null;
                            final contact = value?.trim() ?? '';
                            if (_inviteByEmail) {
                              return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                                      .hasMatch(contact)
                                  ? null
                                  : 'Enter a valid email address';
                            }
                            final digits =
                                contact.replaceAll(RegExp(r'\D'), '');
                            return digits.length >= 7
                                ? null
                                : 'Enter a valid phone number';
                          },
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'This prepares shareable invitation text only. It does not '
                          'create a Team member record or send an email/SMS.',
                          style: TextStyle(
                            color: Color(0xFF6B665E),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Permissions
                if (!_inviteSomeone) Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: _card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE5DFD7)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'PERMISSION PRESETS',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF6B665E), letterSpacing: 0.8),
                      ),
                      SwitchListTile(
                        value: _canCreateCases,
                        onChanged: (v) => setState(() => _canCreateCases = v),
                        title: const Text('Can File New Cases', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                        contentPadding: EdgeInsets.zero,
                        activeThumbColor: _gold,
                      ),
                      SwitchListTile(
                        value: _canDeleteCases,
                        onChanged: (v) => setState(() => _canDeleteCases = v),
                        title: const Text('Can Delete / Close Cases', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                        contentPadding: EdgeInsets.zero,
                        activeThumbColor: _gold,
                      ),
                      SwitchListTile(
                        value: _canInviteMembers,
                        onChanged: (v) => setState(() => _canInviteMembers = v),
                        title: const Text('Can Invite Associates', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                        contentPadding: EdgeInsets.zero,
                        activeThumbColor: _gold,
                      ),
                      SwitchListTile(
                        value: _canExportAudit,
                        onChanged: (v) => setState(() => _canExportAudit = v),
                        title: const Text('Can Export Audit Reports', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                        contentPadding: EdgeInsets.zero,
                        activeThumbColor: _gold,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : _inviteSomeone
                            ? _prepareInvitation
                            : _addLedUser,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _black,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: _gold, strokeWidth: 2),
                          )
                        : Text(
                            _inviteSomeone
                                ? 'Prepare & Share Invitation'
                                : 'Add LED User to Team',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({required String hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFFA09B93), fontSize: 13),
      filled: true,
      fillColor: const Color(0xFFF9F8F6),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE5DFD7))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE5DFD7))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _gold)),
    );
  }
}

class _FoundLedUserCard extends StatelessWidget {
  const _FoundLedUserCard({required this.user});

  final LedUserProfile user;

  @override
  Widget build(BuildContext context) {
    final details = <String>[
      if (user.email.isNotEmpty) user.email,
      if (user.phone.isNotEmpty) user.phone,
      if (user.advocateType.isNotEmpty) user.advocateType,
    ];
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF7F0),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFB8D8BE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            user.name,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          ),
          const SizedBox(height: 4),
          Text('LED ID: ${user.ledId}'),
          if (details.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(details.join(' · ')),
          ],
        ],
      ),
    );
  }
}

class _RoleChoiceCard extends StatelessWidget {
  const _RoleChoiceCard({
    required this.title,
    required this.desc,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final String desc;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AppPalette.primaryGreen : AppPalette.canvas,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppPalette.primaryGreen : AppPalette.borderLight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: isSelected ? AppPalette.cardBackground : AppPalette.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              desc,
              style: TextStyle(
                fontSize: 11,
                color: isSelected ? AppPalette.accentGold : AppPalette.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
