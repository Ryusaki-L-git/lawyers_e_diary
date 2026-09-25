import 'package:flutter/material.dart';

import '../../../models/team_model.dart';
import '../../../services/team_service.dart';
import '../../../widgets/app_palette.dart';
import '../widgets/team_header.dart';

/// Screen 6 (Owner): Invite New Member
/// Email/phone invitation dispatch with role pre-selection and permission boundaries.
class InviteMemberScreen extends StatefulWidget {
  const InviteMemberScreen({super.key, required this.team});

  final TeamModel team;

  @override
  State<InviteMemberScreen> createState() => _InviteMemberScreenState();
}

class _InviteMemberScreenState extends State<InviteMemberScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _typeController = TextEditingController(text: 'Associate Advocate');
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
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _typeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await TeamService.instance.inviteMember(
        teamId: widget.team.id,
        email: _emailController.text.trim(),
        displayName: _nameController.text.trim(),
        role: _selectedRole,
        advocateType: _typeController.text.trim(),
        phone: _phoneController.text.trim(),
        permissions: MemberPermissions(
          canCreateCases: _canCreateCases,
          canDeleteCases: _canDeleteCases,
          canInviteMembers: _canInviteMembers,
          canExportAudit: _canExportAudit,
        ),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_nameController.text.trim()} added to firm roster.'),
          backgroundColor: const Color(0xFF1F3D2B),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding member: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: TeamHeader(
        title: 'Invite Associate',
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
                      const Text(
                        'Full Legal Name *',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _nameController,
                        decoration: _inputDecoration(hint: 'e.g. Adv. R. K. Sharma'),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Name required' : null,
                      ),
                      const SizedBox(height: 16),

                      const Text(
                        'Email Address *',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: _inputDecoration(hint: 'advocate@lawfirm.com'),
                        validator: (v) => v == null || !v.contains('@') ? 'Valid email required' : null,
                      ),
                      const SizedBox(height: 16),

                      const Text(
                        'Phone / Chamber Extension (Optional)',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: _inputDecoration(hint: '+91 98765 43210'),
                      ),
                      const SizedBox(height: 16),

                      const Text(
                        'Firm Designation / Title',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _typeController,
                        decoration: _inputDecoration(hint: 'e.g. Senior Associate, Junior Counsel'),
                      ),
                      const SizedBox(height: 20),

                      const Text(
                        'Assign Team Role',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
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
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Permissions
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
                    onPressed: _isLoading ? null : _submit,
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
                        : const Text('Confirm & Add Member', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
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

