import 'package:flutter/material.dart';

import 'app_palette.dart';

class Reminder {
  const Reminder({required this.title, required this.time, this.isImportant = false});

  final String title;
  final String time;
  final bool isImportant;
}

class ReminderTile extends StatelessWidget {
  const ReminderTile({super.key, required this.reminder, this.onTap});

  final Reminder reminder;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppPalette.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: reminder.isImportant
                      ? const Color(0xFFFFE3D9)
                      : const Color(0xFFE2F0EC),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  reminder.isImportant
                      ? Icons.priority_high_rounded
                      : Icons.notifications_none_rounded,
                  color: reminder.isImportant ? AppPalette.unread : AppPalette.teal,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  reminder.title,
                  style: const TextStyle(
                    color: AppPalette.ink,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                reminder.time,
                style: const TextStyle(
                  color: AppPalette.mutedInk,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
