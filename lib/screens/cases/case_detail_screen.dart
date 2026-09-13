import 'package:flutter/material.dart';

import '../../models/case_model.dart';
import '../../services/firestore_service.dart';
import '../../utils/case_actions_helper.dart';
import '../../widgets/app_bottom_navigation.dart';
import '../../widgets/app_nav_controller.dart';
import 'transfer_case_screen.dart';

class CaseDetailScreen extends StatelessWidget {
  const CaseDetailScreen({super.key, required this.caseItem});

  final CaseModel caseItem;

  static const Color background = Color(0xFFF7F5F2);
  static const Color primaryGreen = Color(0xFF1F3D2B);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF1A1A1A);
  static const Color textMuted = Color(0xFF6B665E);
  static const Color border = Color(0xFFE5DFD7);
  static const Color gold = Color(0xFFCCA046);

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'urgent':
        return const Color(0xFFB3261E);
      case 'completed':
        return primaryGreen;
      case 'upcoming':
        return const Color(0xFF6750A4);
      default:
        return textMuted;
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '—';
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  Future<void> _softDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: const Color(0x59000000),
      builder: (ctx) => AlertDialog(
        backgroundColor: cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
        contentPadding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
        actionsPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        title: const Text(
          'Delete Case',
          style: TextStyle(
              fontFamily: 'serif',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: textDark),
        ),
        content: RichText(
          text: TextSpan(
            style: const TextStyle(fontSize: 13.5, color: textMuted, height: 1.5),
            children: [
              const TextSpan(text: 'Move '),
              TextSpan(
                text: '"${caseItem.caseTitle}"',
                style: const TextStyle(color: textDark, fontWeight: FontWeight.w700),
              ),
              const TextSpan(text: ' to the deleted docket? You can restore it later.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB3261E),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      await FirestoreService().softDeleteCase(caseItem.id);

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('"${caseItem.caseTitle}" moved to deleted.'),
          backgroundColor: primaryGreen,
        ),
      );

      await Future.delayed(const Duration(milliseconds: 300)); // FIX

      Navigator.pop(context);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: const Color(0xFFB3261E),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = caseItem.status.trim();
    final statusLabel = status.isNotEmpty
        ? status[0].toUpperCase() + status.substring(1)
        : 'Unknown'; // FIX

    final statusColor = _statusColor(caseItem.status);

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              children: [
                // HEADER
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 10, 14, 8),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_rounded),
                      ),
                      const Expanded(
                        child: Text(
                          'Case Detail',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'serif',
                            fontSize: 21,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      PopupMenuButton<String>(
                        onSelected: (value) async {
                          switch (value) {
                            case 'share_full':
                              await CaseActionsHelper.shareCase(
                                  context: context,
                                  caseItem: caseItem,
                                  summary: false);
                              break;
                            case 'share_summary':
                              await CaseActionsHelper.shareCase(
                                  context: context,
                                  caseItem: caseItem,
                                  summary: true);
                              break;
                            case 'whatsapp':
                              if (caseItem.clientPhone != null &&
                                  caseItem.clientPhone!.trim().isNotEmpty) { // FIX
                                final phone = caseItem.clientPhone!
                                    .replaceAll(RegExp(r'\D'), ''); // FIX
                                await CaseActionsHelper.openWhatsAppClient(
                                  context: context,
                                  phone: phone,
                                  caseTitle: caseItem.caseTitle,
                                );
                              }
                              break;
                            case 'print':
                              await CaseActionsHelper.printCaseDetails(
                                  context: context, caseItem: caseItem);
                              break;
                          }
                        },
                        itemBuilder: (ctx) => [
                          _popupItem('share_full', Icons.share, 'Share Full'),
                          _popupItem('share_summary', Icons.summarize, 'Summary'),
                          if (caseItem.clientPhone != null &&
                              caseItem.clientPhone!.trim().isNotEmpty)
                            _popupItem('whatsapp', Icons.chat, 'WhatsApp'),
                          _popupItem('print', Icons.print, 'Print'),
                        ],
                      ),
                    ],
                  ),
                ),

                // BODY
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(caseItem.caseTitle),
                              const SizedBox(height: 6),
                              _statusBadge(statusLabel, statusColor),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // ACTIONS
                        _actionButton(
                          context: context,
                          icon: Icons.auto_awesome,
                          label: 'Discuss with Juris AI',
                          color: primaryGreen,
                          onTap: () => Navigator.pushNamed(context, '/juris'),
                        ),

                        const SizedBox(height: 8),

                        _actionButton(
                          context: context,
                          icon: Icons.swap_horiz,
                          label: 'Transfer Case',
                          color: primaryGreen,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  TransferCaseScreen(caseItem: caseItem),
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),

                        // FIX: UPDATE BUTTON
                        _actionButton(
                          context: context,
                          icon: Icons.update_rounded,
                          label: 'Update Case',
                          color: gold,
                          onTap: () {},
                        ),

                        const SizedBox(height: 8),

                        _actionButton(
                          context: context,
                          icon: Icons.delete,
                          label: 'Delete Case',
                          color: const Color(0xFFB3261E),
                          onTap: () => _softDelete(context),
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

      // FIX: NAVIGATION STACK
      bottomNavigationBar: AppBottomNavigation(
        mode: NavMode.caseSection,
        currentIndex: 1,
        onNavigate: (route) {
          if (route == '/home') {
            AppNavController.instance
                .switchToHome(context, index: 0, route: '/home');
          } else {
            Navigator.of(context).pushReplacementNamed(route); // FIX
          }
        },
      ),
    );
  }

  static Widget _sectionCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
      ),
      child: child,
    );
  }

  static Widget _statusBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1), // FIX
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label, style: TextStyle(color: color)),
    );
  }

  static PopupMenuItem<String> _popupItem(
      String value, IconData icon, String label) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 10),
          Text(label),
        ],
      ),
    );
  }

  static Widget _actionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 46,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18, color: color),
        label: Text(label, style: TextStyle(color: color)),
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: color.withValues(alpha: 0.35), // FIX
          ),
        ),
      ),
    );
  }
}