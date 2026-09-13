import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lawyers_e_diary/screens/notification_screen.dart';

void main() {
  testWidgets('notifications screen presents its empty state', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: NotificationScreen(notifications: [])),
    );

    expect(find.text('Notifications'), findsOneWidget);
    expect(find.text('No notifications yet'), findsOneWidget);
  });
}
