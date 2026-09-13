import 'package:flutter/material.dart';

import 'app_palette.dart';

class HeaderSection extends StatelessWidget {
  const HeaderSection({
    super.key,
    required this.userName,
    required this.taskCount,
    required this.date,
  });

  final String userName;
  final int taskCount;
  final DateTime date;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Good ${_timeGreeting()}, $userName',
          style: const TextStyle(
            color: AppPalette.ink,
            fontFamily: 'serif',
            fontSize: 30,
            fontWeight: FontWeight.w700,
            height: 1.12,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          _formattedDate(date),
          style: const TextStyle(
            color: AppPalette.mutedInk,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'You have $taskCount ${taskCount == 1 ? 'task' : 'tasks'} today',
          style: const TextStyle(
            color: AppPalette.teal,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  String _timeGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Morning';
    if (hour < 17) return 'Afternoon';
    return 'Evening';
  }

  String _formattedDate(DateTime value) {
    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    const months = [
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
    return '${weekdays[value.weekday - 1]}, ${value.day} ${months[value.month - 1]}';
  }
}
