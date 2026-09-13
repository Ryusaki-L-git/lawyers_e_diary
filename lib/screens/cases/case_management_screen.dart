import 'package:flutter/material.dart';

import '../../services/firestore_service.dart';
import '../../widgets/app_bottom_navigation.dart';
import '../../widgets/app_nav_controller.dart';
import 'completed_cases_screen.dart';
import 'deleted_cases_screen.dart';
import 'transfer_case_screen.dart';

/// Case Management Screen matching the Case Section blueprint.
/// Displays live Firestore stats (Total, Active, Completed, Deleted) and management actions.
class CaseManagementScreen extends StatelessWidget {
  const CaseManagementScreen({super.key});

  static const Color background = Color(0xFFF7F5F2);
  static const Color primaryGreen = Color(0xFF1F3D2B);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF1A1A1A);
  static const Color textMuted = Color(0xFF6B665E);
  static const Color border = Color(0xFFE5DFD7);

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 90),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header (NO back button)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'Case Management',
                      style: TextStyle(
                        fontFamily: 'serif',
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: textDark,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 4 Stats Cards in Row
                  StreamBuilder<CaseStats>(
                    stream: firestoreService.watchCaseStats(),
                    builder: (context, snapshot) {
                      final stats = snapshot.data ?? const CaseStats();

                      return Container(
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: border, width: 0.8),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x08111716),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            _statColumn('Total Cases', stats.total),
                            _verticalDivider(),
                            _statColumn('Active Cases', stats.active),
                            _verticalDivider(),
                            _statColumn('Completed', stats.completed),
                            _verticalDivider(),
                            _statColumn('Deleted', stats.deleted),
                          ],
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // Management Actions Header
                  const Text(
                    'Management Actions',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: textDark,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Action Tile 1: View All Cases
                  _actionTile(
                    icon: Icons.folder_open_rounded,
                    title: 'View All Cases',
                    subtitle: 'Browse all your cases',
                    onTap: () {
                      AppNavController.instance.switchToCaseSection(context, index: 1, route: '/cases');
                    },
                  ),

                  // Action Tile 2: Edit / Update Case
                  _actionTile(
                    icon: Icons.edit_note_rounded,
                    title: 'Edit / Update Case',
                    subtitle: 'Update case information',
                    onTap: () {
                      AppNavController.instance.switchToCaseSection(context, index: 1, route: '/cases');
                    },
                  ),

                  // Action Tile 3: Transfer Cases
                  _actionTile(
                    icon: Icons.swap_horiz_rounded,
                    title: 'Transfer Cases',
                    subtitle: 'Transfer case to another lawyer',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const TransferCaseScreen()),
                      );
                    },
                  ),

                  // Action Tile 4: Completed Cases
                  _actionTile(
                    icon: Icons.check_circle_outline_rounded,
                    title: 'Completed Cases',
                    subtitle: 'View completed cases',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const CompletedCasesScreen()),
                      );
                    },
                  ),

                  // Action Tile 5: Deleted Cases
                  _actionTile(
                    icon: Icons.delete_outline_rounded,
                    title: 'Deleted Cases',
                    subtitle: 'View deleted cases',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const DeletedCasesScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNavigation(
        mode: NavMode.caseSection,
        currentIndex: 2,
        onNavigate: (route) {
          if (route == '/home') {
            AppNavController.instance.switchToHome(context, index: 0, route: '/home');
          } else if (route != '/case_management') {
            Navigator.of(context).pushNamed(route);
          }
        },
      ),
    );
  }

  static Widget _statColumn(String label, int value) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: textMuted,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$value',
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: textDark,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _verticalDivider() {
    return Container(
      width: 1,
      height: 32,
      color: border,
    );
  }

  static Widget _actionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border, width: 0.8),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: const Color(0xFFF7F5F2),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, color: primaryGreen, size: 21),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: textDark,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 11.5, color: textMuted),
        ),
        trailing: const Icon(Icons.chevron_right_rounded, color: textMuted, size: 22),
      ),
    );
  }
}
