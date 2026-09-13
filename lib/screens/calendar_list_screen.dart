import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../widgets/calendar_components.dart';
import 'cause_list_screen.dart';
import 'full_calendar_screen.dart';
import '../widgets/home_bottom_navigation.dart';

/// Calendar List Screen (Screen 1 in the PNG design).
/// Displays days of the month with total cases per day and navigation to Cause List.
class CalendarListScreen extends StatefulWidget {
  const CalendarListScreen({
    super.key,
    this.initialDate,
  });

  final DateTime? initialDate;

  @override
  State<CalendarListScreen> createState() => _CalendarListScreenState();
}

class _CalendarListScreenState extends State<CalendarListScreen> {
  late DateTime _currentMonth;

  @override
  void initState() {
    super.initState();
    final base = widget.initialDate ?? DateTime(2026, 1, 1);
    _currentMonth = DateTime(base.year, base.month, 1);
  }

  void _openNotifications() {
    Navigator.of(context).pushNamed('/notifications');
  }

  void _openFullCalendar() {
    Navigator.of(context).push(
      CalendarPageRoute(
        builder: (context) => FullCalendarScreen(initialDate: _currentMonth),
      ),
    );
  }

  void _openCauseList(DateTime date) {
    Navigator.of(context).push(
      CalendarPageRoute(
        builder: (context) => CauseListScreen(selectedDate: date),
      ),
    );
  }

  void _handleNavigate(String route) {
    if (route == '/home') {
      Navigator.of(context).pushNamedAndRemoveUntil('/home', (r) => false);
    } else if (route != '/calendar') {
      Navigator.of(context).pushNamed(route);
    }
  }

  @override
  Widget build(BuildContext context) {
    final yearString = _currentMonth.year.toString();
    final monthName = CalendarDateHelper.getMonthName(_currentMonth.month);
    final daysInMonth =
        DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;

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

                const SizedBox(height: 12),

                // Month row and Grid/List view toggle icons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        monthName,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: CalendarColors.textDark,
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Grid View Icon (taps to FullCalendarScreen)
                          IconButton(
                            tooltip: 'Grid view',
                            onPressed: _openFullCalendar,
                            icon: const Icon(
                              Icons.grid_view_rounded,
                              size: 19,
                              color: CalendarColors.textLightMuted,
                            ),
                            splashRadius: 18,
                            padding: const EdgeInsets.all(6),
                            constraints: const BoxConstraints(),
                          ),
                          const SizedBox(width: 6),
                          // List View Icon (current active view)
                          IconButton(
                            tooltip: 'List view',
                            onPressed: () {},
                            icon: const Icon(
                              Icons.format_list_bulleted_rounded,
                              size: 19,
                              color: CalendarColors.primaryGreen,
                            ),
                            splashRadius: 18,
                            padding: const EdgeInsets.all(6),
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // Firestore Stream of Cases & List of Day Cards
                Expanded(
                  child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: FirebaseFirestore.instance
                        .collection('cases')
                        .snapshots(),
                    builder: (context, snapshot) {
                      // Map each day to real Firestore case count
                      final caseCountsByDay = <int, int>{};

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
                              date.year == _currentMonth.year &&
                              date.month == _currentMonth.month) {
                            caseCountsByDay[date.day] =
                                (caseCountsByDay[date.day] ?? 0) + 1;
                          }
                        }
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.fromLTRB(18, 6, 18, 24),
                        physics: const BouncingScrollPhysics(),
                        itemCount: daysInMonth,
                        itemBuilder: (context, index) {
                          final dayNumber = index + 1;
                          final date = DateTime(
                            _currentMonth.year,
                            _currentMonth.month,
                            dayNumber,
                          );

                          // Real Firestore count (0 if no cases scheduled)
                          final count = caseCountsByDay[dayNumber] ?? 0;

                          return CalendarDayCard(
                            date: date,
                            caseCount: count,
                            onViewCauseList: () => _openCauseList(date),
                          );
                        },
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
