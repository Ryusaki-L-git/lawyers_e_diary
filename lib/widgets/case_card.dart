import 'package:flutter/material.dart';

import '../models/case_model.dart';
import '../utils/case_actions_helper.dart';

enum CaseCardActionStyle {
  standard, // Open Case + Discuss with Juris
  deleted, // Restore only
}

/// Production Case Card strictly following the Case Section blueprint.
/// Supports multi-select, 3-dot actions (WhatsApp, Share, Print), and status tags.
class CaseCard extends StatelessWidget {
  const CaseCard({
    super.key,
    required this.caseItem,
    this.actionStyle = CaseCardActionStyle.standard,
    this.isSelectionMode = false,
    this.isSelected = false,
    this.onTap,
    this.onLongPress,
    this.onOpenCase,
    this.onDiscussJuris,
    this.onRestore,
    this.onToggleStar,
  });

  final CaseModel caseItem;
  final CaseCardActionStyle actionStyle;
  final bool isSelectionMode;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onOpenCase;
  final VoidCallback? onDiscussJuris;
  final VoidCallback? onRestore;
  final VoidCallback? onToggleStar;

  static const Color primaryGreen = Color(0xFF1F3D2B);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF1A1A1A);
  static const Color textMuted = Color(0xFF6B665E);
  static const Color border = Color(0xFFE5DFD7);

  @override
  Widget build(BuildContext context) {
    final hearingText = caseItem.nextHearingDate != null
        ? '${caseItem.nextHearingDate!.day} ${_monthShort(caseItem.nextHearingDate!.month)} ${caseItem.nextHearingDate!.year}'
        : 'To be scheduled';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSelected ? primaryGreen : border,
          width: isSelected ? 1.5 : 0.8,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A111716),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: isSelectionMode ? onTap : onOpenCase,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Selection Checkbox (if active), Title, Status Tag, and 3-dot Menu
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isSelectionMode) ...[
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Icon(
                          isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                          color: isSelected ? primaryGreen : textMuted,
                          size: 22,
                        ),
                      ),
                    ],
                    Expanded(
                      child: Text(
                        caseItem.caseTitle,
                        style: const TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                          color: textDark,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (actionStyle != CaseCardActionStyle.deleted) ...[
                      _statusBadge(caseItem.status),
                      const SizedBox(width: 2),
                    ],
                    // Star toggle button
                    if (onToggleStar != null && actionStyle != CaseCardActionStyle.deleted)
                      GestureDetector(
                        onTap: onToggleStar,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                          child: Icon(
                            caseItem.isStarred
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            size: 20,
                            color: caseItem.isStarred
                                ? const Color(0xFFCCA046)
                                : textMuted,
                          ),
                        ),
                      ),
                    _buildThreeDotMenu(context),
                  ],
                ),
                const SizedBox(height: 8),

                // Metadata Details
                if (actionStyle == CaseCardActionStyle.deleted) ...[
                  Text(
                    'Deleted on: ${_formatDeletedDate(caseItem.deletedAt)}',
                    style: const TextStyle(fontSize: 12.5, color: textMuted),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Type: ${caseItem.caseType}  •  ${caseItem.caseNumber}',
                    style: const TextStyle(fontSize: 12.5, color: textMuted),
                  ),
                ] else ...[
                  Text(
                    'Next Hearing: $hearingText',
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: textDark,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Client: ${caseItem.clientName}',
                    style: const TextStyle(fontSize: 12.5, color: textMuted),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Type: ${caseItem.caseType}  •  ${caseItem.caseNumber}',
                    style: const TextStyle(fontSize: 12.5, color: textMuted),
                  ),
                  if (caseItem.courtName.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      'Court: ${caseItem.courtName}',
                      style: const TextStyle(fontSize: 12.5, color: textMuted),
                    ),
                  ],
                ],
                const SizedBox(height: 12),

                // Bottom Action Buttons
                if (actionStyle == CaseCardActionStyle.deleted) ...[
                  Align(
                    alignment: Alignment.centerRight,
                    child: SizedBox(
                      height: 36,
                      child: ElevatedButton(
                        onPressed: onRestore,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryGreen,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Restore',
                          style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ),
                ] else ...[
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: onDiscussJuris,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryGreen,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            minimumSize: const Size(0, 38),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(9),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                          ),
                          child: const Text(
                            'Discuss with Juris',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: onOpenCase,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: primaryGreen,
                            side: const BorderSide(color: Color(0xFFCBD3CD), width: 1.0),
                            elevation: 0,
                            minimumSize: const Size(0, 38),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(9),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                          ),
                          child: const Text(
                            'Open Case',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThreeDotMenu(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert_rounded, size: 20, color: textMuted),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      onSelected: (value) async {
        switch (value) {
          case 'share_full':
            await CaseActionsHelper.shareCase(caseItem: caseItem, fullDetails: true);
            break;
          case 'share_summary':
            await CaseActionsHelper.shareCase(caseItem: caseItem, fullDetails: false);
            break;
          case 'whatsapp':
            await CaseActionsHelper.openWhatsAppClient(context: context, caseItem: caseItem);
            break;
          case 'print':
            await CaseActionsHelper.printCaseDetails(context: context, caseItem: caseItem);
            break;
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'share_full',
          child: Row(
            children: [
              Icon(Icons.share_rounded, size: 18, color: primaryGreen),
              SizedBox(width: 10),
              Text('Share Full Details', style: TextStyle(fontSize: 13)),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'share_summary',
          child: Row(
            children: [
              Icon(Icons.short_text_rounded, size: 18, color: primaryGreen),
              SizedBox(width: 10),
              Text('Share Summary', style: TextStyle(fontSize: 13)),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'whatsapp',
          child: Row(
            children: [
              Icon(Icons.chat_bubble_outline_rounded, size: 18, color: Color(0xFF27AE60)),
              SizedBox(width: 10),
              Text('WhatsApp Client', style: TextStyle(fontSize: 13)),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'print',
          child: Row(
            children: [
              Icon(Icons.print_outlined, size: 18, color: textDark),
              SizedBox(width: 10),
              Text('Print Case', style: TextStyle(fontSize: 13)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _statusBadge(String status) {
    Color bg;
    Color fg;
    String label;

    switch (status.toLowerCase()) {
      case 'urgent':
        bg = const Color(0xFFFDE8E8);
        fg = const Color(0xFFDE3138);
        label = 'Urgent';
        break;
      case 'upcoming':
        bg = const Color(0xFFFEF3E6);
        fg = const Color(0xFFE67A20);
        label = 'Upcoming';
        break;
      case 'completed':
        bg = const Color(0xFFEAF5EF);
        fg = const Color(0xFF13382E);
        label = 'Completed';
        break;
      case 'active':
      default:
        bg = const Color(0xFFEAF5EF);
        fg = const Color(0xFF27AE60);
        label = 'Active';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          color: fg,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  static String _monthShort(int month) {
    const m = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return (month >= 1 && month <= 12) ? m[month - 1] : '';
  }

  static String _formatDeletedDate(DateTime? date) {
    if (date == null) return 'Recently';
    return '${date.day} ${_monthShort(date.month)} ${date.year}, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
