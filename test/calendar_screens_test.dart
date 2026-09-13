import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lawyers_e_diary/widgets/home_bottom_navigation.dart';
import 'package:lawyers_e_diary/widgets/calendar_components.dart';

void main() {
  testWidgets('CalendarDayCard renders date, cases count, and button', (tester) async {
    bool tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CalendarDayCard(
            date: DateTime(2026, 1, 1),
            caseCount: 4,
            onViewCauseList: () => tapped = true,
          ),
        ),
      ),
    );

    expect(find.text('1'), findsOneWidget);
    expect(find.text('THU'), findsOneWidget);
    expect(find.text('Total Cases • 4'), findsOneWidget);
    expect(find.text('View Cause List'), findsOneWidget);

    await tester.tap(find.text('View Cause List'));
    expect(tapped, isTrue);
  });

  testWidgets('CaseCard renders case information and action buttons', (tester) async {
    bool discussed = false;
    bool opened = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CaseCard(
            caseTitle: 'Xyzx VS ZXYz',
            scheduledDateText: '21/01/2026',
            caseType: 'Commercial Appeal',
            handledBy: 'Adv. Counsel',
            onDiscussJuris: () => discussed = true,
            onOpenCase: () => opened = true,
          ),
        ),
      ),
    );

    expect(find.text('Case name - Xyzx VS ZXYz'), findsOneWidget);
    expect(find.text('Next scheduled date - 21/01/2026'), findsOneWidget);
    expect(find.text('Case type - Commercial Appeal'), findsOneWidget);
    expect(find.text('Case handled by - Adv. Counsel'), findsOneWidget);
    expect(find.text('Discuss with Juris'), findsOneWidget);
    expect(find.text('Open case'), findsOneWidget);

    await tester.tap(find.text('Discuss with Juris'));
    expect(discussed, isTrue);

    await tester.tap(find.text('Open case'));
    expect(opened, isTrue);
  });

  testWidgets('HomeBottomNavigation renders with Calendar selected', (tester) async {
    String? navigatedRoute;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: HomeBottomNavigation(
            currentIndex: 1,
            onNavigate: (route) => navigatedRoute = route,
          ),
        ),
      ),
    );

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Calendar'), findsOneWidget);
    expect(find.text('Cases'), findsOneWidget);
    expect(find.text('Juris'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);

    await tester.tap(find.text('Cases'));
    expect(navigatedRoute, equals('/cases'));
  });

  testWidgets('CalendarEmptyState renders message and clear docket advice', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: CalendarEmptyState(dateFormatted: '21/01/2026'),
        ),
      ),
    );

    expect(find.text('No cases scheduled for 21/01/2026'), findsOneWidget);
  });
}
