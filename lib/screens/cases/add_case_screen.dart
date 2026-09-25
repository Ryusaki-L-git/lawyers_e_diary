import 'package:flutter/material.dart';

import '../../models/client_model.dart';
import '../../services/client_service.dart';
import '../../services/firestore_service.dart';
import '../../widgets/app_palette.dart';

/// Screen to create and register a new case docket in Lawyer's E-Diary.
class AddCaseScreen extends StatefulWidget {
  const AddCaseScreen({super.key});

  @override
  State<AddCaseScreen> createState() => _AddCaseScreenState();
}

class _AddCaseScreenState extends State<AddCaseScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _caseNumberController = TextEditingController();
  final _courtNameController = TextEditingController();
  final _clientNameController = TextEditingController();
  final _clientPhoneController = TextEditingController();
  final _opponentNameController = TextEditingController();
  final _notesController = TextEditingController();

  static const List<String> _caseTypes = [
    'Civil Case',
    'Criminal',
    'Corporate',
    'Family',
    'Constitutional',
    'Tax',
    'Labor',
    'Appellate',
  ];

  static const List<String> _statusOptions = [
    'Active',
    'Upcoming',
    'Urgent',
  ];

  String _selectedCaseType = 'Civil Case';
  String _selectedStatus = 'Active';
  DateTime? _selectedHearingDate;
  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _caseNumberController.dispose();
    _courtNameController.dispose();
    _clientNameController.dispose();
    _clientPhoneController.dispose();
    _opponentNameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickHearingDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedHearingDate ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 10),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppPalette.primaryGreen,
              onPrimary: Colors.white,
              surface: AppPalette.cardBackground,
              onSurface: AppPalette.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _selectedHearingDate = picked);
    }
  }

  void _showClientPicker() {
    showModalBottomSheet<ClientModel>(
      context: context,
      backgroundColor: AppPalette.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  child: Text(
                    'Select Saved Client',
                    style: TextStyle(
                      fontFamily: 'serif',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppPalette.textPrimary,
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 2),
                  child: Text(
                    'Tap a client to auto-fill name and contact phone.',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: AppPalette.textMuted,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Divider(height: 1, color: AppPalette.borderLight),
                Flexible(
                  child: StreamBuilder<List<ClientModel>>(
                    stream: ClientService.instance.watchClients(),
                    builder: (context, snapshot) {
                      final clients = snapshot.data ?? [];
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: CircularProgressIndicator(
                              color: AppPalette.primaryGreen,
                            ),
                          ),
                        );
                      }

                      if (clients.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(28),
                          child: Center(
                            child: Text(
                              'No saved clients found.\nYou can enter client details manually.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                color: AppPalette.textMuted,
                              ),
                            ),
                          ),
                        );
                      }

                      return ListView.separated(
                        shrinkWrap: true,
                        itemCount: clients.length,
                        separatorBuilder: (_, _) => const Divider(
                          height: 1,
                          indent: 20,
                          endIndent: 20,
                          color: AppPalette.borderLight,
                        ),
                        itemBuilder: (context, i) {
                          final c = clients[i];
                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 2,
                            ),
                            leading: CircleAvatar(
                              radius: 18,
                              backgroundColor:
                                  AppPalette.primaryGreen.withValues(alpha: 0.1),
                              child: Text(
                                c.name.isNotEmpty
                                    ? c.name[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppPalette.primaryGreen,
                                ),
                              ),
                            ),
                            title: Text(
                              c.name,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppPalette.textPrimary,
                              ),
                            ),
                            subtitle: Text(
                              c.phone.isNotEmpty
                                  ? '${c.type} · ${c.phone}'
                                  : c.type,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppPalette.textMuted,
                              ),
                            ),
                            trailing: const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 14,
                              color: AppPalette.textMuted,
                            ),
                            onTap: () {
                              Navigator.pop(ctx, c);
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ).then((selected) {
      if (selected != null) {
        setState(() {
          _clientNameController.text = selected.name;
          if (selected.phone.isNotEmpty) {
            _clientPhoneController.text = selected.phone;
          }
        });
      }
    });
  }

  Future<void> _submitCase() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final title = _titleController.text.trim();
      final cnr = _caseNumberController.text.trim();
      final court = _courtNameController.text.trim();
      final client = _clientNameController.text.trim();
      final phone = _clientPhoneController.text.trim();
      final opponent = _opponentNameController.text.trim();
      final note = _notesController.text.trim();

      final caseId = await FirestoreService().addCase(
        caseTitle: title,
        clientName: client,
        courtName: court,
        cnrNumber: cnr,
        status: _selectedStatus.toLowerCase(),
        opponentName: opponent.isNotEmpty ? opponent : null,
        caseType: _selectedCaseType,
        nextHearingDate: _selectedHearingDate,
        clientPhone: phone.isNotEmpty ? phone : null,
        initialNote: note.isNotEmpty ? note : null,
      );

      if (!mounted) return;

      setState(() => _isSaving = false);

      if (caseId != null) {
        Navigator.pop(context, caseId);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Case "$title" registered successfully.'),
            backgroundColor: AppPalette.primaryGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.fromLTRB(18, 0, 18, 12),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to save case. Please try again.'),
            backgroundColor: const Color(0xFFB3261E),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.fromLTRB(18, 0, 18, 12),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving case: $e'),
          backgroundColor: const Color(0xFFB3261E),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.fromLTRB(18, 0, 18, 12),
        ),
      );
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.canvas,
      appBar: AppBar(
        backgroundColor: AppPalette.canvas,
        foregroundColor: AppPalette.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'New Case Docket',
          style: TextStyle(
            color: AppPalette.textPrimary,
            fontFamily: 'serif',
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
                physics: const BouncingScrollPhysics(),
                children: [
                  // SECTION 1: Docket Details
                  _sectionHeader(
                    title: 'Docket Details',
                    subtitle: 'Core matter & identification',
                  ),
                  const SizedBox(height: 12),

                  _fieldLabel('Case Title / Matter *'),
                  TextFormField(
                    controller: _titleController,
                    textCapitalization: TextCapitalization.words,
                    style: const TextStyle(
                      color: AppPalette.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: _inputDecoration(
                      hint: 'e.g., Smith vs. Johnson & Associates',
                      icon: Icons.gavel_rounded,
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Please enter case title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  _fieldLabel('CNR / Case Number *'),
                  TextFormField(
                    controller: _caseNumberController,
                    textCapitalization: TextCapitalization.characters,
                    style: const TextStyle(
                      color: AppPalette.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: _inputDecoration(
                      hint: 'e.g., DLHC01-002841-2024 or WP 1042/2024',
                      icon: Icons.tag_rounded,
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Please enter CNR or case number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  _fieldLabel('Case Type *'),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: AppPalette.cardBackground,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppPalette.borderLight),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedCaseType,
                        isExpanded: true,
                        icon: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: AppPalette.textMuted,
                        ),
                        items: _caseTypes.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(
                              type,
                              style: const TextStyle(
                                color: AppPalette.textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _selectedCaseType = val);
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // SECTION 2: Court & Forum
                  _sectionHeader(
                    title: 'Court & Forum',
                    subtitle: 'Judicial body & bench details',
                  ),
                  const SizedBox(height: 12),

                  _fieldLabel('Court Name / Forum *'),
                  TextFormField(
                    controller: _courtNameController,
                    textCapitalization: TextCapitalization.words,
                    style: const TextStyle(
                      color: AppPalette.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: _inputDecoration(
                      hint: 'e.g., High Court of Delhi - Room 4',
                      icon: Icons.account_balance_rounded,
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Please enter court or forum name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // SECTION 3: Parties
                  _sectionHeader(
                    title: 'Parties',
                    subtitle: 'Client and opposing party information',
                  ),
                  const SizedBox(height: 12),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _fieldLabel('Client Name *'),
                      InkWell(
                        onTap: _showClientPicker,
                        borderRadius: BorderRadius.circular(6),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          child: Row(
                            children: [
                              Icon(
                                Icons.contacts_outlined,
                                size: 14,
                                color: AppPalette.primaryGreen,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Select Saved Client',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppPalette.primaryGreen,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  TextFormField(
                    controller: _clientNameController,
                    textCapitalization: TextCapitalization.words,
                    style: const TextStyle(
                      color: AppPalette.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: _inputDecoration(
                      hint: 'e.g., Jonathan Vance',
                      icon: Icons.person_outline_rounded,
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Please enter client name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  _fieldLabel('Client Phone (for WhatsApp / Updates)'),
                  TextFormField(
                    controller: _clientPhoneController,
                    keyboardType: TextInputType.phone,
                    style: const TextStyle(
                      color: AppPalette.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: _inputDecoration(
                      hint: '+1 (555) 019-2834',
                      icon: Icons.phone_outlined,
                    ),
                  ),
                  const SizedBox(height: 16),

                  _fieldLabel('Opponent / Respondent Name'),
                  TextFormField(
                    controller: _opponentNameController,
                    textCapitalization: TextCapitalization.words,
                    style: const TextStyle(
                      color: AppPalette.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: _inputDecoration(
                      hint: 'e.g., Robert Johnson',
                      icon: Icons.group_outlined,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // SECTION 4: Schedule & Status
                  _sectionHeader(
                    title: 'Schedule & Status',
                    subtitle: 'Docket timeline and priority classification',
                  ),
                  const SizedBox(height: 12),

                  _fieldLabel('Case Status *'),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: AppPalette.cardBackground,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppPalette.borderLight),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedStatus,
                        isExpanded: true,
                        icon: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: AppPalette.textMuted,
                        ),
                        items: _statusOptions.map((st) {
                          return DropdownMenuItem(
                            value: st,
                            child: Text(
                              st,
                              style: const TextStyle(
                                color: AppPalette.textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _selectedStatus = val);
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  _fieldLabel('Next Hearing Date'),
                  InkWell(
                    onTap: _pickHearingDate,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppPalette.cardBackground,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppPalette.borderLight),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_month_outlined,
                            size: 20,
                            color: AppPalette.textMuted,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _selectedHearingDate != null
                                  ? _formatDate(_selectedHearingDate!)
                                  : 'Select hearing date (optional)',
                              style: TextStyle(
                                color: _selectedHearingDate != null
                                    ? AppPalette.textPrimary
                                    : AppPalette.textMuted,
                                fontSize: 14,
                                fontWeight: _selectedHearingDate != null
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                          if (_selectedHearingDate != null)
                            IconButton(
                              icon: const Icon(
                                Icons.close_rounded,
                                size: 18,
                                color: AppPalette.textMuted,
                              ),
                              onPressed: () {
                                setState(() => _selectedHearingDate = null);
                              },
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // SECTION 5: Initial Docket Notes
                  _sectionHeader(
                    title: 'Initial Docket Notes',
                    subtitle: 'First hearing notes or case overview',
                  ),
                  const SizedBox(height: 12),

                  _fieldLabel('Notes / Summary'),
                  TextFormField(
                    controller: _notesController,
                    maxLines: 3,
                    textCapitalization: TextCapitalization.sentences,
                    style: const TextStyle(
                      color: AppPalette.textPrimary,
                      fontSize: 14,
                    ),
                    decoration: _inputDecoration(
                      hint: 'Enter initial case notes, retainer info, or notes from counsel...',
                      icon: Icons.notes_rounded,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // SUBMIT BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _submitCase,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppPalette.primaryGreen,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor:
                            AppPalette.primaryGreen.withValues(alpha: 0.6),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Register Case Docket',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader({required String title, required String subtitle}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'serif',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppPalette.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 12,
            color: AppPalette.textMuted,
          ),
        ),
      ],
    );
  }

  Widget _fieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: const TextStyle(
          color: AppPalette.textMuted,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: AppPalette.textMuted,
        fontSize: 13,
        fontWeight: FontWeight.normal,
      ),
      prefixIcon: Icon(icon, color: AppPalette.textMuted, size: 20),
      filled: true,
      fillColor: AppPalette.cardBackground,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppPalette.borderLight),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppPalette.borderLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppPalette.primaryGreen, width: 1.5),
      ),
    );
  }
}

