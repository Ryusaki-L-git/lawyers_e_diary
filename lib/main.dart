import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'login_screen.dart';
import 'screens/calendar_list_screen.dart';
import 'screens/cases/add_case_screen.dart';
import 'screens/cases/all_cases_screen.dart';
import 'screens/cases/case_management_screen.dart';
import 'screens/cases/completed_cases_screen.dart';
import 'screens/cases/deleted_cases_screen.dart';
import 'screens/cases/search_cases_screen.dart';
import 'screens/cases/transfer_case_screen.dart';
import 'screens/cause_list_screen.dart';
import 'screens/full_calendar_screen.dart';
import 'screens/home_screen.dart';
import 'screens/module_landing_screen.dart';
import 'screens/notification_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/fees/fee_list_screen.dart';
import 'screens/cases/starred_cases_screen.dart';
import 'screens/reminders/reminders_list_screen.dart';
import 'screens/settings/app_settings_screen.dart';
import 'screens/settings/cloud_storage_screen.dart';
import 'screens/settings/upgrade_prompt_screen.dart';
import 'screens/clients/client_list_screen.dart';
import 'screens/support/help_support_screen.dart';
import 'screens/team/team_entry_screen.dart';
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
        '/cases': (context) => const AllCasesScreen(),
        '/add_case': (context) => const AddCaseScreen(),
        '/search_cases': (context) => const SearchCasesScreen(),
        '/case_management': (context) => const CaseManagementScreen(),
        '/completed_cases': (context) => const CompletedCasesScreen(),
        '/deleted_cases': (context) => const DeletedCasesScreen(),
        '/transfer_case': (context) => const TransferCaseScreen(),
        '/clients': (context) => const ClientListScreen(),
        '/support': (context) => const HelpSupportScreen(),
        '/team': (context) => const TeamEntryScreen(),
        '/calendar': (context) => const CalendarListScreen(),
        '/calendar_list': (context) => const CalendarListScreen(),
        '/cause_list': (context) => const CauseListScreen(),
        '/full_calendar': (context) => const FullCalendarScreen(),
        '/juris': (context) => const ModuleLandingScreen(
              title: 'Drafting Studio',
              icon: Icons.auto_awesome_rounded,
            ),
        '/profile': (context) => const ProfileScreen(),
        '/fee': (context) => const FeeListScreen(),
        '/todo': (context) => const ModuleLandingScreen(
              title: 'To-Do List',
              icon: Icons.checklist_rounded,
            ),
        '/reminders': (context) => const RemindersListScreen(),
        '/starred': (context) => const StarredCasesScreen(),
        '/settings': (context) => const AppSettingsScreen(),
        '/cloud_storage': (context) => const CloudStorageScreen(),
        '/upgrade': (context) => const UpgradePromptScreen(),
        '/notifications': (context) => const NotificationScreen(),
      },
    );
  }
}
