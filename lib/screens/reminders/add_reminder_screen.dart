import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/reminder_model.dart';
import '../../services/firestore_service.dart';
import '../../widgets/app_palette.dart';
import 'case_picker_sheet.dart';

/// Screen for creating a new reminder with optional case linkage.
class AddReminderScreen extends StatefulWidget {
  const AddReminderScreen({super.key});

  @override
  State<AddReminderScreen> createState() => _AddReminderScreenState();
}

class _AddReminderScreenState extends State<AddReminderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _service = FirestoreService();

  DateTime _dueDate = DateTime.now().add(const Duration(hours: 1));
  ReminderRepeat _repeat = ReminderRepeat.none;
  String? _linkedCaseId;
  String? _linkedCaseTitle;
  String? _linkedClientName;
  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: now.subtract(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 365 * 5)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppPalette.teal,
            onPrimary: Colors.white,
            onSurface: AppPalette.ink,
          ),
        ),
        child: child!,
      ),
    );
    if (picked == null) return;
    if (!mounted) return;
    // Pick time next
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_dueDate),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppPalette.teal,
            onPrimary: Colors.white,
            onSurface: AppPalette.ink,
          ),
        ),
        child: child!,
      ),
    );
    if (pickedTime == null || !mounted) return;
    setState(() {
      _dueDate = DateTime(
        picked.year,
        picked.month,
        picked.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    });
  }

  Future<void> _pickCase() async {
    final caseModel = await CasePickerSheet.show(context);
    if (caseModel != null && mounted) {
      setState(() {
        _linkedCaseId = caseModel.id;
        _linkedCaseTitle = caseModel.caseTitle;
        _linkedClientName = caseModel.clientName;
      });
    }
  }

  void _clearCase() {
    setState(() {
      _linkedCaseId = null;
      _linkedCaseTitle = null;
      _linkedClientName = null;
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    final id = await _service.addReminder(
      title: _titleController.text.trim(),
      dueDateTime: _dueDate,
      description: _descController.text.trim().isEmpty
          ? null
          : _descController.text.trim(),
      caseId: _linkedCaseId,
      caseTitle: _linkedCaseTitle,
      clientName: _linkedClientName,
      repeatRule: _repeat,
    );
    if (!mounted) return;
    setState(() => _isSaving = false);
    if (id != null) {
      Navigator.pop(context, true); // signals success to caller
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to save reminder. Please try again.'),
          backgroundColor: AppPalette.unread,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateLabel = DateFormat('EEE, dd MMM yyyy · hh:mm a').format(_dueDate);

    return Scaffold(
      backgroundColor: AppPalette.background,
      appBar: AppBar(
        title: const Text(
          'New Reminder',
          style: TextStyle(
            color: AppPalette.ink,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
          color: AppPalette.ink,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: _isSaving
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppPalette.teal,
                    ),
                  )
                : TextButton(
                    onPressed: _save,
                    child: const Text(
                      'Save',
                      style: TextStyle(
                        color: AppPalette.teal,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Title field
            _SectionLabel('Reminder Title'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _titleController,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              maxLength: 120,
              decoration: _fieldDecoration('e.g. File petition for Ali Hassan'),
              style: const TextStyle(color: AppPalette.ink, fontSize: 15),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Title is required' : null,
            ),
            const SizedBox(height: 16),
            // Description field
            _SectionLabel('Description (optional)'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _descController,
              textCapitalization: TextCapitalization.sentences,
              maxLines: 3,
              maxLength: 300,
              decoration: _fieldDecoration('Add notes or instructions...'),
              style: const TextStyle(color: AppPalette.ink, fontSize: 15),
            ),
            const SizedBox(height: 16),
            // Date & Time picker
            _SectionLabel('Date & Time'),
            const SizedBox(height: 8),
            _PickerTile(
              icon: Icons.calendar_today_rounded,
              label: dateLabel,
              onTap: _pickDate,
            ),
            const SizedBox(height: 16),
            // Repeat rule
            _SectionLabel('Repeat'),
            const SizedBox(height: 8),
            _RepeatSelector(
              current: _repeat,
              onChanged: (v) => setState(() => _repeat = v),
            ),
            const SizedBox(height: 16),
            // Case link
            _SectionLabel('Link to Case (optional)'),
            const SizedBox(height: 8),
            if (_linkedCaseId == null)
              _PickerTile(
                icon: Icons.gavel_rounded,
                label: 'Select a case',
                isPlaceholder: true,
                onTap: _pickCase,
              )
            else
              _LinkedCaseTile(
                caseTitle: _linkedCaseTitle ?? '',
                clientName: _linkedClientName ?? '',
                onClear: _clearCase,
              ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  InputDecoration _fieldDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppPalette.mutedInk, fontSize: 14),
      filled: true,
      fillColor: AppPalette.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppPalette.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppPalette.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppPalette.teal, width: 1.5),
      ),
      counterStyle: const TextStyle(color: AppPalette.mutedInk, fontSize: 11),
    );
  }
}

// ─────────────────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppPalette.mutedInk,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.4,
      ),
    );
  }
}

class _PickerTile extends StatelessWidget {
  const _PickerTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isPlaceholder = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isPlaceholder;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppPalette.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppPalette.border),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isPlaceholder ? AppPalette.border : AppPalette.teal,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: isPlaceholder ? AppPalette.mutedInk : AppPalette.ink,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: AppPalette.mutedInk, size: 20),
          ],
        ),
      ),
    );
  }
}

class _LinkedCaseTile extends StatelessWidget {
  const _LinkedCaseTile({
    required this.caseTitle,
    required this.clientName,
    required this.onClear,
  });

  final String caseTitle;
  final String clientName;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFE2F0EC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppPalette.teal.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.gavel_rounded, color: AppPalette.teal, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  caseTitle,
                  style: const TextStyle(
                    color: AppPalette.ink,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  clientName,
                  style: const TextStyle(
                    color: AppPalette.mutedInk,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onClear,
            icon: const Icon(Icons.close_rounded,
                color: AppPalette.mutedInk, size: 18),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ],
      ),
    );
  }
}

class _RepeatSelector extends StatelessWidget {
  const _RepeatSelector({required this.current, required this.onChanged});

  final ReminderRepeat current;
  final ValueChanged<ReminderRepeat> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: ReminderRepeat.values.map((r) {
        final isSelected = r == current;
        return GestureDetector(
          onTap: () => onChanged(r),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? AppPalette.teal : AppPalette.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? AppPalette.teal : AppPalette.border,
              ),
            ),
            child: Text(
              r.label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppPalette.mutedInk,
                fontSize: 13,
                fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
