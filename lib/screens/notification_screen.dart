import 'package:flutter/material.dart';

import '../widgets/app_palette.dart';

class AppNotification {
  const AppNotification({
    required this.title,
    required this.description,
    required this.time,
    this.isUnread = false,
  });

  final String title;
  final String description;
  final String time;
  final bool isUnread;
}

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key, this.notifications = _demoNotifications});

  static const _demoNotifications = <AppNotification>[
    AppNotification(
      title: 'Hearing reminder',
      description: 'Sharma v. State is scheduled for review at 11:00 AM.',
      time: 'Just now',
      isUnread: true,
    ),
    AppNotification(
      title: 'Draft ready to review',
      description: 'Your anticipatory bail draft has been saved to Drafting Studio.',
      time: '28 min ago',
      isUnread: true,
    ),
    AppNotification(
      title: 'Fee estimate updated',
      description: 'The estimate for Mehta & Partners has been recalculated.',
      time: 'Yesterday',
    ),
  ];

  final List<AppNotification> notifications;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(fontFamily: 'serif', fontWeight: FontWeight.w700),
        ),
      ),
      body: notifications.isEmpty
          ? const _NotificationsEmptyState()
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
              itemCount: notifications.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) => _NotificationTile(
                notification: notifications[index],
              ),
            ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.notification});

  final AppNotification notification;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: notification.isUnread ? const Color(0xFFFFFCF5) : AppPalette.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: notification.isUnread ? const Color(0xFFE5CB93) : AppPalette.border,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: notification.isUnread ? const Color(0xFFF6E4B8) : const Color(0xFFE5F0EC),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              notification.isUnread ? Icons.notifications_active_rounded : Icons.notifications_none_rounded,
              color: notification.isUnread ? AppPalette.gold : AppPalette.teal,
              size: 21,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        notification.title,
                        style: const TextStyle(
                          color: AppPalette.ink,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (notification.isUnread)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppPalette.unread,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  notification.description,
                  style: const TextStyle(
                    color: AppPalette.mutedInk,
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  notification.time,
                  style: const TextStyle(
                    color: AppPalette.teal,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationsEmptyState extends StatelessWidget {
  const _NotificationsEmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.notifications_off_outlined, size: 54, color: AppPalette.mutedInk),
            SizedBox(height: 14),
            Text(
              'No notifications yet',
              style: TextStyle(
                color: AppPalette.ink,
                fontFamily: 'serif',
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Important case and reminder updates will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppPalette.mutedInk),
            ),
          ],
        ),
      ),
    );
  }
}
