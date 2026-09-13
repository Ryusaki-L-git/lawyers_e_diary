import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'login_screen.dart';
import 'screens/calendar_list_screen.dart';
import 'screens/cause_list_screen.dart';
import 'screens/full_calendar_screen.dart';
import 'screens/home_screen.dart';
import 'screens/module_landing_screen.dart';
import 'screens/notification_screen.dart';
import 'signup_screen.dart';
import 'splash_screen.dart';
import 'welcome_screen.dart';
import 'widgets/app_palette.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lawyers E-Diary',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/welcome': (context) => const WelcomeScreen(),
        '/home': (context) => const HomeScreen(),
        '/cases': (context) => const ModuleLandingScreen(
              title: 'Cases',
              icon: Icons.gavel_rounded,
            ),
        '/clients': (context) => const ModuleLandingScreen(
              title: 'Clients',
              icon: Icons.groups_rounded,
            ),
        '/calendar': (context) => const CalendarListScreen(),
        '/calendar_list': (context) => const CalendarListScreen(),
        '/cause_list': (context) => const CauseListScreen(),
        '/full_calendar': (context) => const FullCalendarScreen(),
        '/juris': (context) => const ModuleLandingScreen(
              title: 'Drafting Studio',
              icon: Icons.auto_awesome_rounded,
            ),
        '/profile': (context) => const ModuleLandingScreen(
              title: 'Settings',
              icon: Icons.settings_outlined,
            ),
        '/fee': (context) => const ModuleLandingScreen(
              title: 'Fee Calculator',
              icon: Icons.calculate_rounded,
            ),
        '/todo': (context) => const ModuleLandingScreen(
              title: 'To-Do List',
              icon: Icons.checklist_rounded,
            ),
        '/reminders': (context) => const ModuleLandingScreen(
              title: 'Reminders',
              icon: Icons.notifications_active_outlined,
            ),
        '/starred': (context) => const ModuleLandingScreen(
              title: 'Starred Cases',
              icon: Icons.star_rounded,
            ),
        '/notifications': (context) => const NotificationScreen(),
      },
    );
  }
}
