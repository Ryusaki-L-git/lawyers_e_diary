import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../widgets/app_palette.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _degreesController = TextEditingController();
  final _addressController = TextEditingController();
  final _courtAddressController = TextEditingController();

  String _advocateType = 'Junior';
  bool _isLoading = true;
  bool _isSaving = false;

  static const _advocateTypes = <String>[
    'Junior',
    'Senior',
    'Corporate',
    'Independent',
  ];

  @override
  void initState() {
    super.initState();
    _loadCurrentProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _degreesController.dispose();
    _addressController.dispose();
    _courtAddressController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentProfile() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final data = doc.data() ?? {};

      if (mounted) {
        setState(() {
          _nameController.text = data['name'] as String? ?? '';
          _phoneController.text = data['phone'] as String? ?? '';
          _degreesController.text = data['degrees'] as String? ?? '';
          _addressController.text = data['address'] as String? ??
              data['officeAddress'] as String? ??
              '';
          _courtAddressController.text =
              data['courtAddress'] as String? ?? '';

          final loadedType = data['advocateType'] as String?;
          if (loadedType != null && _advocateTypes.contains(loadedType)) {
            _advocateType = loadedType;
          }
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    setState(() => _isSaving = true);

    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'degrees': _degreesController.text.trim(),
        'address': _addressController.text.trim(),
        'officeAddress': _addressController.text.trim(),
        'courtAddress': _courtAddressController.text.trim(),
        'advocateType': _advocateType,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: AppPalette.teal,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile: $e'),
            backgroundColor: AppPalette.unread,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.background,
      appBar: AppBar(
        title: const Text(
          'Edit Profile',
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
                ? const Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppPalette.teal,
                      ),
                    ),
                  )
                : TextButton(
                    onPressed: _saveProfile,
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _fieldLabel('Full Name *'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _nameController,
                    textCapitalization: TextCapitalization.words,
                    decoration: _inputDecoration('e.g. Adv. Jane Doe'),
                    validator: (val) =>
                        val == null || val.trim().isEmpty ? 'Name is required' : null,
                  ),
                  const SizedBox(height: 18),

                  _fieldLabel('Phone Number'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: _inputDecoration('e.g. +92 300 1234567'),
                  ),
                  const SizedBox(height: 18),

                  _fieldLabel('Advocate Category'),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: _advocateType,
                    decoration: _inputDecoration('Select category'),
                    dropdownColor: AppPalette.surface,
                    items: _advocateTypes
                        .map(
                          (type) => DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          ),
                        )
                        .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _advocateType = val);
                      }
                    },
                  ),
                  const SizedBox(height: 18),

                  _fieldLabel('Degrees & Credentials'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _degreesController,
                    textCapitalization: TextCapitalization.words,
                    decoration: _inputDecoration('e.g. B.A., LL.B., LL.M.'),
                  ),
                  const SizedBox(height: 18),

                  _fieldLabel('Chamber / Office Address'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _addressController,
                    maxLines: 2,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: _inputDecoration('Office location details'),
                  ),
                  const SizedBox(height: 18),

                  _fieldLabel('Court / Bar Council Address'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _courtAddressController,
                    maxLines: 2,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: _inputDecoration('Court or chamber room address'),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _fieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        color: AppPalette.mutedInk,
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.4,
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
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
    );
  }
}
