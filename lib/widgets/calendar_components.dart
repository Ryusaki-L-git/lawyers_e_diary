import 'package:flutter/material.dart';

/// Design palette specific to the Calendar, Cause List, and Full Calendar screens.
/// Matches the minimal luxury legal aesthetic: #F7F5F2 cream background, #1F3D2B deep green,
/// subtle highlights, crisp off-white cards, and dark grey ink text.
abstract final class CalendarColors {
  static const background = Color(0xFFF7F5F2);
  static const primaryGreen = Color(0xFF1F3D2B);
  static const card = Color(0xFFFFFFFF);
  static const textDark = Color(0xFF1E2A2C);
  static const textMuted = Color(0xFF6B7470);
  static const textLightMuted = Color(0xFF8D9691);
  static const badgeBg = Color(0xFFEBE6DC);
  static const outlineBorder = Color(0xFFCBD3CD);
  static const lightBorder = Color(0xFFE5DFD7);
  static const gold = Color(0xFFC68200);
  static const disabledDay = Color(0xFFB8BEB9);
}

/// Subtle, professional page route transition: fade + slight horizontal slide with easeOutCubic.
class CalendarPageRoute<T> extends PageRouteBuilder<T> {
  CalendarPageRoute({required WidgetBuilder builder})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) =>
              builder(context),
          transitionDuration: const Duration(milliseconds: 200),
          reverseTransitionDuration: const Duration(milliseconds: 200),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curved = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeInCubic,
            );
            return FadeTransition(
              opacity: curved,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.03, 0.0),
                  end: Offset.zero,
                ).animate(curved),
                child: child,
              ),
            );
          },
        );
}

/// Helper methods for dates without external package requirements.
abstract final class CalendarDateHelper {
  static const List<String> monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  static const List<String> weekdayShort = [
    'MON',
    'TUE',
    'WED',
    'THU',
    'FRI',
    'SAT',
    'SUN',
  ];

  static const List<String> weekdayHeaders = [
    'SUN',
    'MON',
    'TUE',
    'WED',
    'THU',
    'FRI',
    'SAT',
  ];

  static String getMonthName(int month) {
    if (month >= 1 && month <= 12) {
      return monthNames[month - 1];
    }
    return '';
  }

  static String getWeekdayShort(DateTime date) {
    return weekdayShort[date.weekday - 1];
  }

  static String formatDateDigits(DateTime date) {
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    final y = date.year.toString();
    return '$d/$m/$y';
  }

  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

/// Calendar Day Card for the Calendar List view.
/// Shows date badge with day number + weekday, case count, and "View Cause List" button.
class CalendarDayCard extends StatelessWidget {
  const CalendarDayCard({
    super.key,
    required this.date,
    required this.caseCount,
    required this.onViewCauseList,
  });

  final DateTime date;
  final int caseCount;
  final VoidCallback onViewCauseList;

  @override
  Widget build(BuildContext context) {
    final weekday = CalendarDateHelper.getWeekdayShort(date);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: CalendarColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: CalendarColors.lightBorder, width: 0.8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x081F3D2B),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onViewCauseList,
          borderRadius: BorderRadius.circular(14),
          splashColor: CalendarColors.primaryGreen.withValues(alpha: 0.05),
          highlightColor: CalendarColors.primaryGreen.withValues(alpha: 0.02),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                // Date badge
                Container(
                  width: 50,
                  height: 58,
                  decoration: BoxDecoration(
                    color: CalendarColors.badgeBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${date.day}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: CalendarColors.textDark,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        weekday,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: CalendarColors.textMuted,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),

                // Case count
                Expanded(
                  child: Text(
                    'Total Cases • $caseCount',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: CalendarColors.textDark,
                    ),
                  ),
                ),

                // View Cause List Button
                OutlinedButton(
                  onPressed: onViewCauseList,
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: CalendarColors.primaryGreen,
                    side: const BorderSide(
                      color: CalendarColors.outlineBorder,
                      width: 1.0,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    minimumSize: const Size(0, 32),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'View Cause List',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: CalendarColors.primaryGreen,
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
}

/// Case Card for the Cause List screen.
/// Displays case title, share/bookmark actions, scheduled details, and dual buttons.
class CaseCard extends StatelessWidget {
  const CaseCard({
    super.key,
    required this.caseTitle,
    required this.scheduledDateText,
    required this.caseType,
    required this.handledBy,
    this.onDiscussJuris,
    this.onOpenCase,
    this.onShare,
    this.onBookmark,
    this.isBookmarked = false,
  });

  final String caseTitle;
  final String scheduledDateText;
  final String caseType;
  final String handledBy;
  final VoidCallback? onDiscussJuris;
  final VoidCallback? onOpenCase;
  final VoidCallback? onShare;
  final VoidCallback? onBookmark;
  final bool isBookmarked;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CalendarColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: CalendarColors.lightBorder, width: 0.8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x081F3D2B),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Title & Action icons
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  'Case name - $caseTitle',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: CalendarColors.textDark,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: onShare,
                borderRadius: BorderRadius.circular(12),
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(
                    Icons.share_outlined,
                    size: 18,
                    color: CalendarColors.textMuted,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              InkWell(
                onTap: onBookmark,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                    size: 19,
                    color: isBookmarked ? CalendarColors.primaryGreen : CalendarColors.textMuted,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Metadata lines (consistent 4-6 spacing rhythm)
          Text(
            'Next scheduled date - $scheduledDateText',
            style: const TextStyle(
              fontSize: 12.5,
              color: CalendarColors.textMuted,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Case type - $caseType',
            style: const TextStyle(
              fontSize: 12.5,
              color: CalendarColors.textMuted,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Case handled by - $handledBy',
            style: const TextStyle(
              fontSize: 12.5,
              color: CalendarColors.textMuted,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 12),

          // Action Buttons: Discuss with Juris & Open case
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: onDiscussJuris,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CalendarColors.primaryGreen,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    minimumSize: const Size(0, 38),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                  ),
                  child: const Text(
                    'Discuss with Juris',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  onPressed: onOpenCase,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: CalendarColors.primaryGreen,
                    side: const BorderSide(
                      color: CalendarColors.outlineBorder,
                      width: 1.0,
                    ),
                    elevation: 0,
                    minimumSize: const Size(0, 38),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                  ),
                  child: const Text(
                    'Open case',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: CalendarColors.primaryGreen,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Action Buttons Section at the bottom of the Cause List screen.
class CauseListActionButtons extends StatelessWidget {
  const CauseListActionButtons({
    super.key,
    required this.selectedDateFormatted,
    this.onPrintSelected,
    this.onPrintCauseList,
    this.onEditUpdateCase,
  });

  final String selectedDateFormatted;
  final VoidCallback? onPrintSelected;
  final VoidCallback? onPrintCauseList;
  final VoidCallback? onEditUpdateCase;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Primary filled button: Print selected cases
        SizedBox(
          width: double.infinity,
          height: 44,
          child: ElevatedButton.icon(
            onPressed: onPrintSelected,
            icon: const Icon(Icons.print_outlined, size: 18),
            label: const Text(
              'Print selected cases',
              style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: CalendarColors.primaryGreen,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Outlined button: Print date cause list
        SizedBox(
          width: double.infinity,
          height: 44,
          child: OutlinedButton.icon(
            onPressed: onPrintCauseList,
            icon: const Icon(Icons.print_outlined, size: 18),
            label: Text(
              'Print $selectedDateFormatted cause list',
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: CalendarColors.primaryGreen,
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: CalendarColors.primaryGreen,
              side: const BorderSide(
                color: CalendarColors.outlineBorder,
                width: 1.0,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Outlined button: Edit/update case
        SizedBox(
          width: double.infinity,
          height: 44,
          child: OutlinedButton.icon(
            onPressed: onEditUpdateCase,
            icon: const Icon(Icons.edit_outlined, size: 18),
            label: const Text(
              'Edit/update case',
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: CalendarColors.primaryGreen,
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: CalendarColors.primaryGreen,
              side: const BorderSide(
                color: CalendarColors.outlineBorder,
                width: 1.0,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Main Month Calendar Grid Card for FullCalendarScreen.
class CalendarGridCard extends StatelessWidget {
  const CalendarGridCard({
    super.key,
    required this.displayedMonth,
    required this.selectedDate,
    required this.datesWithCases,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.onDateSelected,
  });

  final DateTime displayedMonth;
  final DateTime selectedDate;
  final Set<DateTime> datesWithCases;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final ValueChanged<DateTime> onDateSelected;

  @override
  Widget build(BuildContext context) {
    final monthName = CalendarDateHelper.getMonthName(displayedMonth.month);
    final year = displayedMonth.year;

    final firstDayOfMonth = DateTime(year, displayedMonth.month, 1);
    final lastDayOfMonth = DateTime(year, displayedMonth.month + 1, 0);
    final daysInMonth = lastDayOfMonth.day;
    final startDayIndex = firstDayOfMonth.weekday % 7;
    final prevMonthLastDay = DateTime(year, displayedMonth.month, 0).day;
    final totalCells = ((startDayIndex + daysInMonth) > 35) ? 42 : 35;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: CalendarColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: CalendarColors.lightBorder, width: 0.8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x081F3D2B),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Dark green month header banner
          Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: CalendarColors.primaryGreen,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: onPreviousMonth,
                  icon: const Icon(
                    Icons.chevron_left_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  splashRadius: 18,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                Text(
                  monthName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15.5,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
                IconButton(
                  onPressed: onNextMonth,
                  icon: const Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  splashRadius: 18,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Weekday header row: SUN MON TUE WED THU FRI SAT
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: CalendarDateHelper.weekdayHeaders.map((day) {
              return Expanded(
                child: Center(
                  child: Text(
                    day,
                    style: const TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: CalendarColors.textMuted,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),

          // Calendar grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: totalCells,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 6,
              crossAxisSpacing: 4,
              childAspectRatio: 1.0,
            ),
            itemBuilder: (context, index) {
              final isPrevMonth = index < startDayIndex;
              final dayNumber = isPrevMonth
                  ? (prevMonthLastDay - startDayIndex + index + 1)
                  : (index - startDayIndex + 1);
              final isNextMonth = !isPrevMonth && (dayNumber > daysInMonth);

              if (isPrevMonth) {
                return Center(
                  child: Text(
                    '$dayNumber',
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: CalendarColors.disabledDay,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                );
              }

              if (isNextMonth) {
                final nextDayNumber = dayNumber - daysInMonth;
                return Center(
                  child: Text(
                    '$nextDayNumber',
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: CalendarColors.disabledDay,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                );
              }

              final cellDate = DateTime(year, displayedMonth.month, dayNumber);
              final isSelected = CalendarDateHelper.isSameDay(cellDate, selectedDate);
              final hasCases = datesWithCases.any(
                (d) => CalendarDateHelper.isSameDay(d, cellDate),
              );

              return Center(
                child: InkWell(
                  onTap: () => onDateSelected(cellDate),
                  borderRadius: BorderRadius.circular(18),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? CalendarColors.primaryGreen
                              : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '$dayNumber',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected
                                  ? Colors.white
                                  : CalendarColors.textDark,
                            ),
                          ),
                        ),
                      ),
                      if (hasCases && !isSelected)
                        Positioned(
                          bottom: 2,
                          child: Container(
                            width: 3.5,
                            height: 3.5,
                            decoration: const BoxDecoration(
                              color: CalendarColors.primaryGreen,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Month Accordion Tile for FullCalendarScreen.
class MonthAccordionTile extends StatelessWidget {
  const MonthAccordionTile({
    super.key,
    required this.monthName,
    required this.onTap,
  });

  final String monthName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: CalendarColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: CalendarColors.lightBorder, width: 0.8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x081F3D2B),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  monthName,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: CalendarColors.textDark,
                  ),
                ),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: CalendarColors.textMuted,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Clean empty state card for days with no scheduled cases.
class CalendarEmptyState extends StatelessWidget {
  const CalendarEmptyState({
    super.key,
    required this.dateFormatted,
    this.onSelectAnotherDate,
  });

  final String dateFormatted;
  final VoidCallback? onSelectAnotherDate;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
      decoration: BoxDecoration(
        color: CalendarColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: CalendarColors.lightBorder, width: 0.8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x081F3D2B),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: CalendarColors.badgeBg,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.event_busy_rounded,
              color: CalendarColors.primaryGreen,
              size: 24,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'No cases scheduled for $dateFormatted',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: CalendarColors.textDark,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Your court diary is clear for this date. Use the date selector above to inspect other dates.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.5,
              color: CalendarColors.textMuted,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
