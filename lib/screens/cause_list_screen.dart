import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../widgets/app_bottom_navigation.dart';
import '../widgets/app_nav_controller.dart';
import '../widgets/calendar_components.dart';
import '../widgets/team_switcher_sheet.dart';

/// Cause List Screen (Screen 2 in the PNG design).
/// Displays daily scheduled cases with actions, filter selectors, and print utilities.
class CauseListScreen extends StatefulWidget {
  const CauseListScreen({
    super.key,
    this.selectedDate,
  });

  final DateTime? selectedDate;

  @override
  State<CauseListScreen> createState() => _CauseListScreenState();
}

class _CauseListScreenState extends State<CauseListScreen> {
  late DateTime _selectedDate;
  final Set<String> _bookmarkedCaseIds = <String>{};
  String _lawyerFilter = 'Advocate (You)';
  String _selectedMemberId = 'all';

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate ?? DateTime(2026, 1, 21);

    final user = FirebaseAuth.instance.currentUser;
    if (user?.displayName != null && user!.displayName!.trim().isNotEmpty) {
      _lawyerFilter = '${user.displayName} (You)';
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: CalendarColors.primaryGreen,
              onPrimary: Colors.white,
              surface: CalendarColors.card,
              onSurface: CalendarColors.textDark,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && mounted) {
      setState(() => _selectedDate = picked);
    }
  }

  void _openTeamSwitcher() {
    TeamSwitcherSheet.show(
      context,
      selectedMemberId: _selectedMemberId,
      onSelected: (member) {
        setState(() {
          if (member == null) {
            _selectedMemberId = 'all';
            _lawyerFilter = 'All Firm Associates';
          } else {
            _selectedMemberId = member.id;
            _lawyerFilter = member.name;
          }
        });
      },
    );
  }

  void _openJuris() {
    Navigator.of(context).pushNamed('/juris');
  }

  void _openCaseDetails(String caseTitle) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: CalendarColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text(
          caseTitle,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: CalendarColors.textDark,
          ),
        ),
        content: const Text(
          'Case docket synchronized with Firestore.',
          style: TextStyle(color: CalendarColors.textMuted, fontSize: 13.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(
              'Close',
              style: TextStyle(color: CalendarColors.primaryGreen),
            ),
          ),
        ],
      ),
    );
  }

  void _showFeedback(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: CalendarColors.primaryGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _handleNavigate(String route) {
    if (route == '/home') {
      Navigator.of(context).pushNamedAndRemoveUntil('/home', (r) => false);
    } else if (route == '/calendar') {
      Navigator.pop(context);
    } else {
      Navigator.of(context).pushNamed(route);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormatted = CalendarDateHelper.formatDateDigits(_selectedDate);

    return Scaffold(
      backgroundColor: CalendarColors.background,
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              children: [
                // Top Header: Title, Team Switcher (Briefcase), Filter & Search (NO back button per rules)
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 12, 14, 8),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Cause List',
                          style: TextStyle(
                            fontFamily: 'serif',
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: CalendarColors.textDark,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Switch Counsel',
                        onPressed: _openTeamSwitcher,
                        icon: const Icon(
                          Icons.business_center_outlined,
                          size: 21,
                          color: CalendarColors.textDark,
                        ),
                        splashRadius: 18,
                        padding: const EdgeInsets.all(6),
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        tooltip: 'Filter',
                        onPressed: _openTeamSwitcher,
                        icon: const Icon(
                          Icons.tune_rounded,
                          size: 21,
                          color: CalendarColors.textDark,
                        ),
                        splashRadius: 18,
                        padding: const EdgeInsets.all(6),
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        tooltip: 'Search',
                        onPressed: () =>
                            Navigator.of(context).pushNamed('/search_cases'),
                        icon: const Icon(
                          Icons.search_rounded,
                          size: 21,
                          color: CalendarColors.textDark,
                        ),
                        splashRadius: 18,
                        padding: const EdgeInsets.all(6),
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),

                // Filter / Selector Row: <username> (You) & XX/XX/XXXX
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                  child: Row(
                    children: [
                      // Lawyer / User pill
                      Expanded(
                        child: InkWell(
                          onTap: _openTeamSwitcher,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            height: 38,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: CalendarColors.card,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: CalendarColors.lightBorder,
                                width: 0.8,
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    _lawyerFilter,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w500,
                                      color: CalendarColors.textDark,
                                    ),
                                  ),
                                ),
                                const Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  size: 18,
                                  color: CalendarColors.textMuted,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Date selector pill: XX/XX/XXXX with calendar icon
                      InkWell(
                        onTap: _pickDate,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          height: 38,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: CalendarColors.card,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: CalendarColors.lightBorder,
                              width: 0.8,
                            ),
                          ),
                          child: Row(
                            children: [
                              Text(
                                dateFormatted,
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w500,
                                  color: CalendarColors.textDark,
                                  letterSpacing: 0.4,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(
                                Icons.calendar_today_outlined,
                                size: 15,
                                color: CalendarColors.textDark,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 6),

                // Cases List & Bottom Actions (StreamBuilder connected to Firestore)
                Expanded(
                  child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: FirebaseFirestore.instance
                        .collection('cases')
                        .snapshots(),
                    builder: (context, snapshot) {
                      final casesForDay = <Map<String, dynamic>>[];

                      if (snapshot.hasData) {
                        for (final doc in snapshot.data!.docs) {
                          final data = doc.data();
                          final rawDate = data['nextHearingDate'];
                          DateTime? date;

                          if (rawDate is Timestamp) {
                            date = rawDate.toDate();
                          } else if (rawDate is DateTime) {
                            date = rawDate;
                          } else if (rawDate is String) {
                            date = DateTime.tryParse(rawDate);
                          }

                          if (date != null &&
                              CalendarDateHelper.isSameDay(
                                  date, _selectedDate)) {
                            final item = Map<String, dynamic>.from(data);
                            item['id'] = doc.id;
                            final handled = (item['handledBy'] as String? ?? '').toLowerCase();
                            final filter = _lawyerFilter.toLowerCase().replaceAll(' (you)', '').trim();
                            if (_selectedMemberId == 'all' || _lawyerFilter == 'All Firm Associates' || handled.contains(filter)) {
                              casesForDay.add(item);
                            }
                          }
                        }
                      }

                      return ListView(
                        padding: const EdgeInsets.fromLTRB(18, 6, 18, 24),
                        physics: const BouncingScrollPhysics(),
                        children: [
                          if (casesForDay.isEmpty)
                            CalendarEmptyState(
                              dateFormatted: dateFormatted,
                              onSelectAnotherDate: _pickDate,
                            )
                          else
                            ...casesForDay.map((c) {
                              final id = c['id'] as String? ?? '';
                              final title = c['caseTitle'] as String? ??
                                  'Untitled Case';
                              final type = c['caseType'] as String? ??
                                  c['status'] as String? ??
                                  'Civil Matter';
                              final handled = c['handledBy'] as String? ??
                                  c['clientName'] as String? ??
                                  'Adv. Counsel';

                              return CaseCard(
                                caseTitle: title,
                                scheduledDateText: dateFormatted,
                                caseType: type,
                                handledBy: handled,
                                isBookmarked: _bookmarkedCaseIds.contains(id),
                                onBookmark: () {
                                  setState(() {
                                    if (_bookmarkedCaseIds.contains(id)) {
                                      _bookmarkedCaseIds.remove(id);
                                      _showFeedback('Removed bookmark');
                                    } else {
                                      _bookmarkedCaseIds.add(id);
                                      _showFeedback('Case bookmarked');
                                    }
                                  });
                                },
                                onShare: () => _showFeedback(
                                    'Share case link for "$title"'),
                                onDiscussJuris: _openJuris,
                                onOpenCase: () => _openCaseDetails(title),
                              );
                            }),

                          const SizedBox(height: 14),

                          // Three Action Buttons matching PNG
                          CauseListActionButtons(
                            selectedDateFormatted: dateFormatted,
                            onPrintSelected: () => _showFeedback(
                                'Preparing print for selected cases...'),
                            onPrintCauseList: () => _showFeedback(
                                'Generating $dateFormatted Cause List PDF...'),
                            onEditUpdateCase: () =>
                                _showFeedback('Select case to edit/update'),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNavigation(
        mode: NavMode.home,
        currentIndex: 1,
        onNavigate: _handleNavigate,
      ),
    );
  }
}
