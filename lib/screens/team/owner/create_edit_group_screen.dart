import 'package:flutter/material.dart';

import '../../../models/team_model.dart';
import '../../../services/team_service.dart';
import '../../../widgets/app_palette.dart';
import '../widgets/team_header.dart';

/// Screen 10 (Owner): Create / Edit Practice Group
/// Group creation (e.g., Corporate Litigation, Criminal Defense) and membership allocation.
class CreateEditGroupScreen extends StatefulWidget {
  const CreateEditGroupScreen({
    super.key,
    required this.team,
    this.existingGroup,
  });

  final TeamModel team;
  final TeamGroup? existingGroup;

  @override
  State<CreateEditGroupScreen> createState() => _CreateEditGroupScreenState();
}

class _CreateEditGroupScreenState extends State<CreateEditGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _areaController;
  late final TextEditingController _descController;
  late List<String> _selectedMemberIds;
  bool _isLoading = false;

  static const Color _bg = AppPalette.canvas;
  static const Color _card = AppPalette.cardBackground;
  static const Color _black = AppPalette.primaryGreen;
  static const Color _gold = AppPalette.accentGold;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.existingGroup?.name ?? '');
    _areaController = TextEditingController(text: widget.existingGroup?.practiceArea ?? '');
    _descController = TextEditingController(text: widget.existingGroup?.description ?? '');
    _selectedMemberIds = List.from(widget.existingGroup?.memberIds ?? []);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _areaController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _saveGroup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      if (widget.existingGroup == null) {
        await TeamService.instance.createGroup(
          teamId: widget.team.id,
          name: _nameController.text.trim(),
          practiceArea: _areaController.text.trim(),
          description: _descController.text.trim(),
          memberIds: _selectedMemberIds,
        );
      } else {
        await TeamService.instance.updateGroup(
          widget.team.id,
          widget.existingGroup!.id,
          name: _nameController.text.trim(),
          practiceArea: _areaController.text.trim(),
          description: _descController.text.trim(),
          memberIds: _selectedMemberIds,
        );
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.existingGroup == null
                ? 'Practice group created.'
                : 'Practice group updated.',
          ),
          backgroundColor: const Color(0xFF1F3D2B),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save group: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingGroup != null;

    return Scaffold(
      backgroundColor: _bg,
      appBar: TeamHeader(
        title: isEditing ? 'Edit Practice Group' : 'New Practice Group',
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
                        'Practice Group Name *',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _nameController,
                        decoration: _inputDecoration(hint: 'e.g. Criminal Appellate Division'),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Name required' : null,
                      ),
                      const SizedBox(height: 16),

                      const Text(
                        'Practice Area / Specialization',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _areaController,
                        decoration: _inputDecoration(hint: 'e.g. Commercial Litigation, Real Estate, Family Law'),
                      ),
                      const SizedBox(height: 16),

                      const Text(
                        'Group Description (Optional)',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _descController,
                        maxLines: 3,
                        decoration: _inputDecoration(hint: 'Scope of work, senior oversight, courts covered...'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Member enrollment
                const Text(
                  'ENROLL ASSOCIATES',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF6B665E), letterSpacing: 0.8),
                ),
                const SizedBox(height: 8),

                StreamBuilder<List<TeamMembership>>(
                  stream: TeamService.instance.watchMembers(widget.team.id),
                  builder: (context, snapshot) {
                    final members = snapshot.data ?? [];
                    if (members.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(12),
                        child: Text('No colleagues available to enroll.', style: TextStyle(color: Color(0xFF888888))),
                      );
                    }

                    return Container(
                      decoration: BoxDecoration(
                        color: _card,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE5DFD7)),
                      ),
                      child: Column(
                        children: members.map((m) {
                          final isSelected = _selectedMemberIds.contains(m.userId);

                          return CheckboxListTile(
                            value: isSelected,
                            onChanged: (val) {
                              setState(() {
                                if (val == true) {
                                  _selectedMemberIds.add(m.userId);
                                } else {
                                  _selectedMemberIds.remove(m.userId);
                                }
                              });
                            },
                            fillColor: WidgetStateProperty.all(_gold),
                            title: Text(m.displayName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
                            subtitle: Text('${m.role.label} · ${m.advocateType}', style: const TextStyle(fontSize: 11.5, color: Color(0xFF6B665E))),
                          );
                        }).toList(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 28),

                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveGroup,
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
                            isEditing ? 'Update Group' : 'Create Practice Group',
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
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

