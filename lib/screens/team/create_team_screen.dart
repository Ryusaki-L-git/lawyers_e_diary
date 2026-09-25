import 'package:flutter/material.dart';

import '../../services/team_service.dart';
import '../../widgets/app_palette.dart';

/// Screen allowing an advocate to establish a new Firm / Team practice.
class CreateTeamScreen extends StatefulWidget {
  const CreateTeamScreen({super.key});

  @override
  State<CreateTeamScreen> createState() => _CreateTeamScreenState();
}

class _CreateTeamScreenState extends State<CreateTeamScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _firmController = TextEditingController();
  final _descController = TextEditingController();
  bool _isLoading = false;

  static const Color _bg = AppPalette.canvas;
  static const Color _black = AppPalette.primaryGreen;
  static const Color _gold = AppPalette.accentGold;
  static const Color _card = AppPalette.cardBackground;

  @override
  void dispose() {
    _nameController.dispose();
    _firmController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final teamId = await TeamService.instance.createTeam(
        name: _nameController.text.trim(),
        lawFirm: _firmController.text.trim(),
        description: _descController.text.trim(),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Firm team established successfully!'),
          backgroundColor: Color(0xFF1F3D2B),
        ),
      );
      Navigator.of(context).pop(teamId);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create team: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: AppPalette.cardBackground,
        foregroundColor: AppPalette.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: AppPalette.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Establish Law Practice Team',
          style: TextStyle(
            color: AppPalette.textPrimary,
            fontFamily: 'serif',
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top header card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppPalette.primaryGreen,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: _gold.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _gold.withValues(alpha: 0.4)),
                        ),
                        child: const Icon(Icons.groups_rounded, color: _gold, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Team Practice Hub',
                              style: TextStyle(
                                color: AppPalette.cardBackground,
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Collaborate with associates, assign cases, and share real-time dockets.',
                              style: TextStyle(
                                color: AppPalette.cardBackground.withValues(alpha: 0.72),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Form fields card
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
                        'Team / Department Name *',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF333333),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _nameController,
                        decoration: _inputDecoration(
                          hint: 'e.g. Litigation Team Alpha / Criminal Defense Group',
                          icon: Icons.badge_outlined,
                        ),
                        validator: (v) =>
                            v == null || v.trim().isEmpty ? 'Please enter a team name' : null,
                      ),
                      const SizedBox(height: 20),

                      const Text(
                        'Firm or Chamber Name *',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF333333),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _firmController,
                        decoration: _inputDecoration(
                          hint: 'e.g. Zafarullah & Associates, Advocates',
                          icon: Icons.business_outlined,
                        ),
                        validator: (v) => v == null || v.trim().isEmpty
                            ? 'Please enter your law firm / chamber name'
                            : null,
                      ),
                      const SizedBox(height: 20),

                      const Text(
                        'Practice Description (Optional)',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF333333),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _descController,
                        maxLines: 3,
                        decoration: _inputDecoration(
                          hint: 'Brief summary of matters handled, jurisdictions, courts...',
                          icon: Icons.notes_outlined,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Submit button
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _black,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 2,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: _gold,
                              strokeWidth: 2,
                            ),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_circle_outline_rounded, color: _gold, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Establish Team',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
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

  InputDecoration _inputDecoration({required String hint, required IconData icon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFFA09B93), fontSize: 13),
      prefixIcon: Icon(icon, color: const Color(0xFF6B665E), size: 20),
      filled: true,
      fillColor: const Color(0xFFF9F8F6),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE5DFD7)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE5DFD7)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _gold, width: 1.5),
      ),
    );
  }
}

