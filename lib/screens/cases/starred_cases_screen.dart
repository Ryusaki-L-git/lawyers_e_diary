import 'package:flutter/material.dart';

import '../../models/case_model.dart';
import '../../services/firestore_service.dart';
import '../../widgets/app_bottom_navigation.dart';
import '../../widgets/app_nav_controller.dart';
import '../../widgets/case_card.dart';
import 'case_detail_screen.dart';

/// Starred Cases Screen — shows only cases where isStarred == true.
class StarredCasesScreen extends StatelessWidget {
  const StarredCasesScreen({super.key});

  static const Color background = Color(0xFFF7F5F2);
  static const Color primaryGreen = Color(0xFF1F3D2B);
  static const Color textDark = Color(0xFF1A1A1A);
  static const Color textMuted = Color(0xFF6B665E);
  static const Color gold = Color(0xFFCCA046);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              children: [
                // ── Header ──────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 10, 14, 8),
                  child: Row(
                    children: [
                      IconButton(
                        tooltip: 'Back',
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.arrow_back_rounded,
                          size: 23,
                          color: textDark,
                        ),
                      ),
                      const Expanded(
                        child: Text(
                          'Starred Cases',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'serif',
                            fontSize: 21,
                            fontWeight: FontWeight.w700,
                            color: textDark,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.star_rounded,
                        color: gold,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                ),

                // ── Divider ──────────────────────────────────────────────
                const Divider(height: 1, thickness: 0.5, color: Color(0xFFE5DFD7)),

                // ── Body ─────────────────────────────────────────────────
                Expanded(
                  child: StreamBuilder<List<CaseModel>>(
                    stream: FirestoreService().watchCases(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: primaryGreen,
                            strokeWidth: 2,
                          ),
                        );
                      }

                      if (snapshot.hasError) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Text(
                              'Error loading starred cases.\n${snapshot.error}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: textMuted, fontSize: 13.5),
                            ),
                          ),
                        );
                      }

                      final allCases = snapshot.data ?? [];
                      final starred = allCases
                          .where((c) => c.isStarred && !c.isDeleted)
                          .toList();

                      if (starred.isEmpty) {
                        return _EmptyStarredState();
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 100),
                        itemCount: starred.length,
                        itemBuilder: (context, i) {
                          final c = starred[i];
                          return CaseCard(
                            caseItem: c,
                            onOpenCase: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CaseDetailScreen(caseItem: c),
                              ),
                            ),
                            onDiscussJuris: () {},
                            onToggleStar: () =>
                                FirestoreService().toggleCaseStarred(c.id, !c.isStarred),
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
      bottomNavigationBar: AppBottomNavigation(
        mode: NavMode.caseSection,
        currentIndex: 1,
        onNavigate: (route) => Navigator.of(context).pushNamed(route),
      ),
    );
  }
}

class _EmptyStarredState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E7),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFCCA046), width: 1.5),
              ),
              child: const Icon(
                Icons.star_outline_rounded,
                size: 34,
                color: Color(0xFFCCA046),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No Starred Cases',
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tap the ★ icon on any case to mark it as starred and find it here quickly.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.5,
                color: Color(0xFF6B665E),
                height: 1.55,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
