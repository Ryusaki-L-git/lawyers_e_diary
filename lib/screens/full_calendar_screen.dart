import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../widgets/calendar_components.dart';
import 'calendar_list_screen.dart';
import 'cause_list_screen.dart';
import '../widgets/home_bottom_navigation.dart';

/// Full Calendar Screen (Screen 3 in the PNG design).
/// Displays interactive month grid with case highlights and upcoming month accordions.
class FullCalendarScreen extends StatefulWidget {
  const FullCalendarScreen({
    super.key,
    this.initialDate,
  });

  final DateTime? initialDate;

  @override
  State<FullCalendarScreen> createState() => _FullCalendarScreenState();
}

class _FullCalendarScreenState extends State<FullCalendarScreen> {
  late DateTime _displayedMonth;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    final base = widget.initialDate ?? DateTime(2026, 1, 21);
    _displayedMonth = DateTime(base.year, base.month, 1);
    _selectedDate = base;
  }

  void _openNotifications() {
    Navigator.of(context).pushNamed('/notifications');
  }

  void _navigateToList() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pushReplacement(
        CalendarPageRoute(
          builder: (context) => CalendarListScreen(initialDate: _displayedMonth),
        ),
      );
    }
  }

  void _onDateSelected(DateTime date) {
    setState(() => _selectedDate = date);

    // Navigates smoothly to Cause List for that selected date
    Navigator.of(context).push(
      CalendarPageRoute(
        builder: (context) => CauseListScreen(selectedDate: date),
      ),
    );
  }

  void _prevMonth() {
    setState(() {
      _displayedMonth = DateTime(
        _displayedMonth.year,
        _displayedMonth.month - 1,
        1,
      );
    });
  }

  void _nextMonth() {
    setState(() {
      _displayedMonth = DateTime(
        _displayedMonth.year,
        _displayedMonth.month + 1,
        1,
      );
    });
  }

  void _selectMonth(int monthNumber) {
    setState(() {
      _displayedMonth = DateTime(_displayedMonth.year, monthNumber, 1);
    });
  }

  void _handleNavigate(String route) {
    if (route == '/home') {
      Navigator.of(context).pushNamedAndRemoveUntil('/home', (r) => false);
    } else if (route == '/calendar') {
      _navigateToList();
    } else {
      Navigator.of(context).pushNamed(route);
    }
  }

  @override
  Widget build(BuildContext context) {
    final yearString = _displayedMonth.year.toString();

    return Scaffold(
      backgroundColor: CalendarColors.background,
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              children: [
                // Top Header Section
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 12, 18, 0),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Centered Title & Year Subtitle
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Calendar',
                            style: TextStyle(
                              fontFamily: 'serif',
                              fontSize: 23,
                              fontWeight: FontWeight.w700,
                              color: CalendarColors.textDark,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            yearString,
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w500,
                              color: CalendarColors.textMuted,
                            ),
                          ),
                        ],
                      ),

                      // Notification Bell Icon at right
                      Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                          tooltip: 'Notifications',
                          onPressed: _openNotifications,
                          icon: const Icon(
                            Icons.notifications_none_rounded,
                            size: 24,
                            color: CalendarColors.textDark,
                          ),
                          splashRadius: 20,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // View Switcher Icons: Grid (active) & List (navigates back to list view)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        tooltip: 'Grid view',
                        onPressed: () {},
                        icon: const Icon(
                          Icons.grid_view_rounded,
                          size: 19,
                          color: CalendarColors.primaryGreen,
                        ),
                        splashRadius: 18,
                        padding: const EdgeInsets.all(6),
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 6),
                      IconButton(
                        tooltip: 'List view',
                        onPressed: _navigateToList,
                        icon: const Icon(
                          Icons.format_list_bulleted_rounded,
                          size: 19,
                          color: CalendarColors.textLightMuted,
                        ),
                        splashRadius: 18,
                        padding: const EdgeInsets.all(6),
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // Calendar Grid & Months Accordions with Firestore Stream
                Expanded(
                  child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: FirebaseFirestore.instance
                        .collection('cases')
                        .snapshots(),
                    builder: (context, snapshot) {
                      // Real Firestore dates with scheduled cases
                      final datesWithCases = <DateTime>{};

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

                          if (date != null) {
                            datesWithCases.add(
                              DateTime(date.year, date.month, date.day),
                            );
                          }
                        }
                      }

                      return ListView(
                        padding: const EdgeInsets.fromLTRB(18, 4, 18, 24),
                        physics: const BouncingScrollPhysics(),
                        children: [
                          // Main Month Calendar Card
                          CalendarGridCard(
                            displayedMonth: _displayedMonth,
                            selectedDate: _selectedDate,
                            datesWithCases: datesWithCases,
                            onPreviousMonth: _prevMonth,
                            onNextMonth: _nextMonth,
                            onDateSelected: _onDateSelected,
                          ),

                          const SizedBox(height: 14),

                          // Subsequent Months Accordions (matching PNG: February, March, April)
                          MonthAccordionTile(
                            monthName: 'February',
                            onTap: () => _selectMonth(2),
                          ),
                          MonthAccordionTile(
                            monthName: 'March',
                            onTap: () => _selectMonth(3),
                          ),
                          MonthAccordionTile(
                            monthName: 'April',
                            onTap: () => _selectMonth(4),
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
      bottomNavigationBar: HomeBottomNavigation(
        currentIndex: 1,
        onNavigate: _handleNavigate,
      ),
    );
  }
}
