import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/client_model.dart';
import '../../services/client_service.dart';
import '../../widgets/app_palette.dart';
import 'add_edit_client_screen.dart';

/// Comprehensive Client Dossier screen showing contact information,
/// intake notes, direct communication actions, edit, and soft-delete.
class ClientDetailScreen extends StatefulWidget {
  const ClientDetailScreen({super.key, required this.client});

  final ClientModel client;

  @override
  State<ClientDetailScreen> createState() => _ClientDetailScreenState();
}

class _ClientDetailScreenState extends State<ClientDetailScreen> {
  late ClientModel _client;

  @override
  void initState() {
    super.initState();
    _client = widget.client;
  }

  Future<void> _makeCall(String phone) async {
    final clean = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    if (clean.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No phone number recorded for this client.'),
          backgroundColor: AppPalette.textMuted,
        ),
      );
      return;
    }
    final uri = Uri.parse('tel:$clean');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not trigger phone dialer.'),
            backgroundColor: Color(0xFFB3261E),
          ),
        );
      }
    }
  }

  Future<void> _openWhatsApp(String phone, String name) async {
    final clean = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    if (clean.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No phone number recorded for this client.'),
          backgroundColor: AppPalette.textMuted,
        ),
      );
      return;
    }
    final message = Uri.encodeComponent(
      'Dear $name,\n\nRegarding your legal matters with our chamber...\n\nLawyer\'s E-Diary',
    );
    final uri = Uri.parse('https://wa.me/$clean?text=$message');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open WhatsApp. Please verify the phone number.'),
            backgroundColor: Color(0xFFB3261E),
          ),
        );
      }
    }
  }

  Future<void> _archiveClient() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppPalette.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Archive Client',
          style: TextStyle(
            color: AppPalette.textPrimary,
            fontFamily: 'serif',
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'Archive "${_client.name}"? This will hide them from your active directory. All historical cases and billing records will remain completely intact.',
          style: const TextStyle(
            color: AppPalette.textMuted,
            fontSize: 13.5,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppPalette.textMuted),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB3261E),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Archive Client'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final ok = await ClientService.instance.deleteClient(_client.id);
      if (mounted) {
        if (ok) {
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Client "${_client.name}" archived.'),
              backgroundColor: AppPalette.primaryGreen,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to archive client.'),
              backgroundColor: Color(0xFFB3261E),
            ),
          );
        }
      }
    }
  }

  Future<void> _editClient() async {
    final updated = await Navigator.push<ClientModel>(
      context,
      MaterialPageRoute(
        builder: (_) => AddEditClientScreen(client: _client),
      ),
    );
    if (updated != null && mounted) {
      setState(() => _client = updated);
    }
  }

  @override
  Widget build(BuildContext context) {
    final initials = _client.name.trim().isNotEmpty
        ? _client.name.trim().split(' ').map((s) => s.isNotEmpty ? s[0] : '').take(2).join().toUpperCase()
        : 'CL';

    return Scaffold(
      backgroundColor: AppPalette.canvas,
      appBar: AppBar(
        backgroundColor: AppPalette.canvas,
        foregroundColor: AppPalette.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Client Dossier',
          style: TextStyle(
            color: AppPalette.textPrimary,
            fontFamily: 'serif',
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 22),
            tooltip: 'Edit Client',
            onPressed: _editClient,
          ),
          IconButton(
            icon: const Icon(Icons.archive_outlined, size: 22, color: Color(0xFFB3261E)),
            tooltip: 'Archive Client',
            onPressed: _archiveClient,
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            // Profile Card Header
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppPalette.cardBackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppPalette.borderLight),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x06000000),
                    blurRadius: 10,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 34,
                    backgroundColor: AppPalette.primaryGreen,
                    child: Text(
                      initials,
                      style: const TextStyle(
                        color: AppPalette.accentGold,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _client.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppPalette.textPrimary,
                      fontFamily: 'serif',
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppPalette.primaryGreen.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _client.type.toUpperCase(),
                      style: const TextStyle(
                        color: AppPalette.primaryGreen,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Quick Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _client.phone.isNotEmpty ? () => _makeCall(_client.phone) : null,
                          icon: const Icon(Icons.call_rounded, size: 18),
                          label: const Text('Call'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppPalette.primaryGreen,
                            side: const BorderSide(color: AppPalette.borderLight),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _client.phone.isNotEmpty
                              ? () => _openWhatsApp(_client.phone, _client.name)
                              : null,
                          icon: const Icon(Icons.chat_rounded, size: 18),
                          label: const Text('WhatsApp'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF27AE60),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Contact Information Card
            _sectionTitle('CONTACT PARTICULARS'),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppPalette.cardBackground,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppPalette.borderLight),
              ),
              child: Column(
                children: [
                  _infoRow(
                    icon: Icons.phone_outlined,
                    label: 'Telephone',
                    value: _client.phone.isNotEmpty ? _client.phone : 'Not provided',
                  ),
                  const Divider(color: AppPalette.borderLight, height: 16),
                  _infoRow(
                    icon: Icons.email_outlined,
                    label: 'Email Address',
                    value: _client.email.isNotEmpty ? _client.email : 'Not provided',
                  ),
                  const Divider(color: AppPalette.borderLight, height: 16),
                  _infoRow(
                    icon: Icons.location_on_outlined,
                    label: 'Location / Office',
                    value: _client.address.isNotEmpty ? _client.address : 'Not provided',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Intake Notes Card
            _sectionTitle('INTAKE NOTES & OBSERVATIONS'),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppPalette.cardBackground,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppPalette.borderLight),
              ),
              child: _client.notes.isNotEmpty
                  ? Text(
                      _client.notes,
                      style: const TextStyle(
                        color: AppPalette.textPrimary,
                        fontSize: 13.5,
                        height: 1.5,
                      ),
                    )
                  : const Text(
                      'No specific counsel notes entered for this client.',
                      style: TextStyle(
                        color: AppPalette.textMuted,
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
      child: Text(
        title,
        style: const TextStyle(
          color: AppPalette.textMuted,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _infoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppPalette.textMuted),
        const SizedBox(width: 12),
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: const TextStyle(
              color: AppPalette.textMuted,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: AppPalette.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

