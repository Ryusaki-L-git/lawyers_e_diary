import 'package:flutter/material.dart';

import '../../models/client_model.dart';
import '../../services/client_service.dart';
import '../../widgets/app_palette.dart';

/// Form screen for creating a new client or editing an existing client entity.
class AddEditClientScreen extends StatefulWidget {
  const AddEditClientScreen({super.key, this.client});

  final ClientModel? client;

  @override
  State<AddEditClientScreen> createState() => _AddEditClientScreenState();
}

class _AddEditClientScreenState extends State<AddEditClientScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _addressController;
  late final TextEditingController _notesController;

  late String _selectedType;
  bool _isSaving = false;

  bool get _isEditing => widget.client != null;

  static const List<String> _clientTypes = [
    'Individual',
    'Corporate',
    'Government',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    final c = widget.client;
    _nameController = TextEditingController(text: c?.name ?? '');
    _phoneController = TextEditingController(text: c?.phone ?? '');
    _emailController = TextEditingController(text: c?.email ?? '');
    _addressController = TextEditingController(text: c?.address ?? '');
    _notesController = TextEditingController(text: c?.notes ?? '');
    _selectedType = c != null && _clientTypes.contains(c.type)
        ? c.type
        : _clientTypes.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final name = _nameController.text.trim();
      final phone = _phoneController.text.trim();
      final email = _emailController.text.trim();
      final address = _addressController.text.trim();
      final notes = _notesController.text.trim();

      if (_isEditing) {
        final updated = widget.client!.copyWith(
          name: name,
          type: _selectedType,
          phone: phone,
          email: email,
          address: address,
          notes: notes,
        );
        final ok = await ClientService.instance.updateClient(updated);
        if (mounted) {
          setState(() => _isSaving = false);
          if (ok) {
            Navigator.pop(context, updated);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Client profile updated.'),
                backgroundColor: AppPalette.primaryGreen,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Failed to update client. Please try again.'),
                backgroundColor: Color(0xFFB3261E),
              ),
            );
          }
        }
      } else {
        final newClient = ClientModel(
          id: '',
          userId: ClientService.instance.currentUserId ?? '',
          name: name,
          type: _selectedType,
          phone: phone,
          email: email,
          address: address,
          notes: notes,
        );
        final newId = await ClientService.instance.addClient(newClient);
        if (mounted) {
          setState(() => _isSaving = false);
          if (newId != null) {
            Navigator.pop(context, newClient.copyWith(id: newId));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Client added successfully.'),
                backgroundColor: AppPalette.primaryGreen,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Failed to add client. Please try again.'),
                backgroundColor: Color(0xFFB3261E),
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: const Color(0xFFB3261E),
          ),
        );
      }
    }
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
        title: Text(
          _isEditing ? 'Edit Client' : 'Add New Client',
          style: const TextStyle(
            color: AppPalette.textPrimary,
            fontFamily: 'serif',
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            children: [
              // Client Type Dropdown
              _fieldLabel('Client Entity Type'),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: AppPalette.cardBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppPalette.borderLight),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedType,
                    isExpanded: true,
                    icon: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppPalette.textMuted,
                    ),
                    items: _clientTypes.map((type) {
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
                      if (val != null) setState(() => _selectedType = val);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Name Field (Required)
              _fieldLabel('Full Name / Entity Name *'),
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                style: const TextStyle(
                  color: AppPalette.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                decoration: _inputDecoration(
                  hint: 'e.g., Jonathan Vance or Apex Industries Ltd.',
                  icon: Icons.person_outline_rounded,
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter client name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 18),

              // Phone Number Field
              _fieldLabel('Phone Number'),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                style: const TextStyle(
                  color: AppPalette.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                decoration: _inputDecoration(
                  hint: '+1 (555) 000-0000',
                  icon: Icons.phone_outlined,
                ),
              ),
              const SizedBox(height: 18),

              // Email Address Field
              _fieldLabel('Email Address'),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(
                  color: AppPalette.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                decoration: _inputDecoration(
                  hint: 'client@example.com',
                  icon: Icons.email_outlined,
                ),
              ),
              const SizedBox(height: 18),

              // Physical Address Field
              _fieldLabel('Address / Office Location'),
              TextFormField(
                controller: _addressController,
                textCapitalization: TextCapitalization.sentences,
                maxLines: 2,
                style: const TextStyle(
                  color: AppPalette.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                decoration: _inputDecoration(
                  hint: 'Chamber, Street, City, State, ZIP',
                  icon: Icons.location_on_outlined,
                ),
              ),
              const SizedBox(height: 18),

              // Intake Notes Field
              _fieldLabel('Intake Notes / Counsel Observations'),
              TextFormField(
                controller: _notesController,
                textCapitalization: TextCapitalization.sentences,
                maxLines: 4,
                style: const TextStyle(
                  color: AppPalette.textPrimary,
                  fontSize: 14,
                ),
                decoration: _inputDecoration(
                  hint: 'Initial consultation summary, retainer details, representation scope...',
                  icon: Icons.edit_note_rounded,
                ),
              ),
              const SizedBox(height: 28),

              // Save Action Button
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppPalette.primaryGreen,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        AppPalette.primaryGreen.withValues(alpha: 0.5),
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
                      : Text(
                          _isEditing ? 'Save Changes' : 'Register Client',
                          style: const TextStyle(
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

