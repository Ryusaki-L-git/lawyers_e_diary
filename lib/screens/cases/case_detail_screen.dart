import 'package:flutter/material.dart';

import '../../models/case_model.dart';
import '../../services/firestore_service.dart';
import '../../utils/case_actions_helper.dart';
import '../../widgets/app_bottom_navigation.dart';
import '../../widgets/app_nav_controller.dart';
import 'transfer_case_screen.dart';

/// Case Detail Screen — full case docket view.
/// Back button is allowed (deep screen rule).
/// Accepts [caseItem] from parent screen.
class CaseDetailScreen extends StatefulWidget {
  const CaseDetailScreen({super.key, required this.caseItem});

  final CaseModel caseItem;

  @override
  State<CaseDetailScreen> createState() => _CaseDetailScreenState();
}

class _CaseDetailScreenState extends State<CaseDetailScreen> {
  late bool _isStarred;

  @override
  void initState() {
    super.initState();
    _isStarred = widget.caseItem.isStarred;
  }

  CaseModel get caseItem => widget.caseItem;

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
    if (date == null) return 'To be announced';
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
            color: textDark,
          ),
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
            style: TextButton.styleFrom(
              foregroundColor: textMuted,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB3261E),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            ),
            child: const Text('Delete', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      await FirestoreService().softDeleteCase(caseItem.id);

      if (!context.mounted) return;

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('"${caseItem.caseTitle}" moved to deleted.'),
          backgroundColor: primaryGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.fromLTRB(18, 0, 18, 12),
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: const Color(0xFFB3261E),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.fromLTRB(18, 0, 18, 12),
        ),
      );
    }
  }

  Future<void> _toggleStar() async {
    final newVal = !_isStarred;
    setState(() => _isStarred = newVal);
    try {
      await FirestoreService().toggleCaseStarred(caseItem.id, newVal);
    } catch (_) {
      // Revert on failure
      if (mounted) setState(() => _isStarred = !newVal);
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = caseItem.status.trim();
    final statusLabel = status.isNotEmpty
        ? status[0].toUpperCase() + status.substring(1)
        : 'Active';
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
                // ── Header ──────────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 10, 14, 8),
                  child: Row(
                    children: [
                      IconButton(
                        tooltip: 'Back',
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.arrow_back_rounded,
                          size: 23,
                          color: textDark,
                        ),
                      ),
                      const Expanded(
                        child: Text(
                          'Case Detail',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'serif',
                            fontSize: 21,
                            fontWeight: FontWeight.w700,
                            color: textDark,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                      // Star toggle
                      IconButton(
                        tooltip: _isStarred ? 'Unstar Case' : 'Star Case',
                        onPressed: _toggleStar,
                        icon: Icon(
                          _isStarred ? Icons.star_rounded : Icons.star_outline_rounded,
                          size: 24,
                          color: _isStarred ? gold : textMuted,
                        ),
                      ),
                      // 3-dot menu
                      PopupMenuButton<String>(
                        icon: const Icon(
                          Icons.more_vert_rounded,
                          size: 22,
                          color: textDark,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        color: cardBg,
                        elevation: 4,
                        onSelected: (value) async {
                          switch (value) {
                            case 'share_full':
                              await CaseActionsHelper.shareCase(
                                caseItem: caseItem,
                                fullDetails: true,
                              );
                              break;
                            case 'share_summary':
                              await CaseActionsHelper.shareCase(
                                caseItem: caseItem,
                                fullDetails: false,
                              );
                              break;
                            case 'whatsapp':
                              if (caseItem.clientPhone != null &&
                                  caseItem.clientPhone!.trim().isNotEmpty) {
                                await CaseActionsHelper.openWhatsAppClient(
                                  context: context,
                                  caseItem: caseItem,
                                );
                              }
                              break;
                            case 'print':
                              await CaseActionsHelper.printCaseDetails(
                                context: context,
                                caseItem: caseItem,
                              );
                              break;
                          }
                        },
                        itemBuilder: (ctx) => [
                          _popupItem('share_full', Icons.share_outlined, 'Share Full Details'),
                          _popupItem('share_summary', Icons.summarize_outlined, 'Share Summary'),
                          if (caseItem.clientPhone != null &&
                              caseItem.clientPhone!.trim().isNotEmpty)
                            _popupItem('whatsapp', Icons.chat_outlined, 'WhatsApp Client'),
                          _popupItem('print', Icons.print_outlined, 'Print Case'),
                        ],
                      ),
                    ],
                  ),
                ),

                // ── Scrollable Body ──────────────────────────────────────────
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Title Card ───────────────────────────────────────
                        _sectionCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      caseItem.caseTitle,
                                      style: const TextStyle(
                                        fontFamily: 'serif',
                                        fontSize: 19,
                                        fontWeight: FontWeight.w700,
                                        color: textDark,
                                        height: 1.3,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  _statusBadge(statusLabel, statusColor),
                                ],
                              ),
                              const SizedBox(height: 8),
                              _infoRow(Icons.tag_rounded, caseItem.caseNumber),
                              const SizedBox(height: 5),
                              _infoRow(Icons.folder_open_rounded, caseItem.caseType),
                            ],
                          ),
                        ),

                        const SizedBox(height: 12),

                        // ── Parties ──────────────────────────────────────────
                        _sectionLabel('Parties'),
                        _sectionCard(
                          child: Column(
                            children: [
                              _detailRow('Client', caseItem.clientName),
                              if (caseItem.opponentName.isNotEmpty) ...[
                                _divider(),
                                _detailRow('Opponent', caseItem.opponentName),
                              ],
                            ],
                          ),
                        ),

                        const SizedBox(height: 12),

                        // ── Court & Hearing ──────────────────────────────────
                        _sectionLabel('Court & Hearing'),
                        _sectionCard(
                          child: Column(
                            children: [
                              _detailRow('Court', caseItem.courtName),
                              _divider(),
                              _detailRow(
                                'Next Hearing',
                                _formatDate(caseItem.nextHearingDate),
                              ),
                              _divider(),
                              _detailRow('Handled By', caseItem.handledBy),
                            ],
                          ),
                        ),

                        if (caseItem.notes.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          _sectionLabel('Notes'),
                          _sectionCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: caseItem.notes
                                  .map(
                                    (note) => Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Padding(
                                            padding: EdgeInsets.only(top: 5),
                                            child: CircleAvatar(
                                              radius: 3,
                                              backgroundColor: textMuted,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              note,
                                              style: const TextStyle(
                                                fontSize: 13.5,
                                                color: textDark,
                                                height: 1.5,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                        ],

                        if (caseItem.documents.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          _sectionLabel('Documents'),
                          _sectionCard(
                            child: Column(
                              children: caseItem.documents
                                  .map((doc) => _documentTile(doc))
                                  .toList(),
                            ),
                          ),
                        ],

                        const SizedBox(height: 24),

                        // ── Action Buttons ───────────────────────────────────
                        _sectionLabel('Actions'),
                        const SizedBox(height: 8),

                        // Discuss with Juris
                        _actionButton(
                          context: context,
                          icon: Icons.auto_awesome_rounded,
                          label: 'Discuss with Juris AI',
                          color: primaryGreen,
                          onTap: () => Navigator.of(context).pushNamed('/juris'),
                        ),

                        const SizedBox(height: 8),

                        // Transfer Case
                        _actionButton(
                          context: context,
                          icon: Icons.swap_horiz_rounded,
                          label: 'Transfer Case',
                          color: const Color(0xFF3D6B4F),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  TransferCaseScreen(caseItem: caseItem),
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Update Case
                        _actionButton(
                          context: context,
                          icon: Icons.update_rounded,
                          label: 'Update Case',
                          color: gold,
                          onTap: () {},
                        ),

                        const SizedBox(height: 8),

                        // Delete (soft)
                        _actionButton(
                          context: context,
                          icon: Icons.delete_outline_rounded,
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

      bottomNavigationBar: AppBottomNavigation(
        mode: NavMode.caseSection,
        currentIndex: 1,
        onNavigate: (route) {
          if (route == '/home') {
            AppNavController.instance.switchToHome(context, index: 0, route: '/home');
          } else {
            Navigator.of(context).pushNamed(route);
          }
        },
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  static Widget _sectionCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border, width: 0.8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08111716),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  static Widget _sectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: textMuted,
          letterSpacing: 0.6,
        ),
      ),
    );
  }

  static Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: textMuted,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '—' : value,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _divider() {
    return Container(
      height: 0.8,
      color: border,
      margin: const EdgeInsets.symmetric(vertical: 4),
    );
  }

  static Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: textMuted),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 12.5, color: textMuted),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  static Widget _statusBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  static Widget _documentTile(CaseDocumentModel doc) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFF7F5F2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.description_outlined, size: 19, color: primaryGreen),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doc.name,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: textDark,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${doc.type} · ${doc.size}',
                  style: const TextStyle(fontSize: 11.5, color: textMuted),
                ),
              ],
            ),
          ),
          const Icon(Icons.open_in_new_rounded, size: 17, color: textMuted),
        ],
      ),
    );
  }

  static PopupMenuItem<String> _popupItem(
    String value,
    IconData icon,
    String label,
  ) {
    return PopupMenuItem(
      value: value,
      height: 42,
      child: Row(
        children: [
          Icon(icon, size: 18, color: textMuted),
          const SizedBox(width: 10),
          Text(label, style: const TextStyle(fontSize: 13.5, color: textDark)),
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
        label: Text(
          label,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: color.withValues(alpha: 0.35), width: 1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
      ),
    );
  }
}