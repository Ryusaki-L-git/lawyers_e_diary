import 'package:flutter/material.dart';

import '../../models/case_model.dart';
import '../../services/firestore_service.dart';
import '../../widgets/app_bottom_navigation.dart';
import '../../widgets/app_nav_controller.dart';
import '../../widgets/calendar_components.dart' hide CaseCard;
import '../../widgets/case_card.dart';
import '../../widgets/case_empty_state.dart';
import 'case_detail_screen.dart';

/// Deleted Cases Screen — soft-deleted docket with restore capability.
/// Back button is allowed (deep screen rule).
class DeletedCasesScreen extends StatefulWidget {
  const DeletedCasesScreen({super.key});

  @override
  State<DeletedCasesScreen> createState() => _DeletedCasesScreenState();
}

class _DeletedCasesScreenState extends State<DeletedCasesScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final Set<String> _selectedCaseIds = <String>{};

  bool get _isSelectionMode => _selectedCaseIds.isNotEmpty;

  static const Color background = Color(0xFFF7F5F2);
  static const Color primaryGreen = Color(0xFF1F3D2B);
  static const Color textDark = Color(0xFF1A1A1A);
  static const Color textMuted = Color(0xFF6B665E);

  void _toggleSelect(String id) {
    setState(() {
      if (_selectedCaseIds.contains(id)) {
        _selectedCaseIds.remove(id);
      } else {
        _selectedCaseIds.add(id);
      }
    });
  }

  void _openCaseDetail(CaseModel caseItem) {
    Navigator.of(context).push(
      CalendarPageRoute(
        builder: (_) => CaseDetailScreen(caseItem: caseItem),
      ),
    );
  }

  Future<void> _restoreCase(String caseId, String caseTitle) async {
    try {
      await _firestoreService.restoreCase(caseId);
      if (!mounted) return;
      setState(() => _selectedCaseIds.remove(caseId));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('"$caseTitle" restored successfully.'),
          backgroundColor: primaryGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.fromLTRB(18, 0, 18, 12),
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to restore: $e'),
          backgroundColor: const Color(0xFFB3261E),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.fromLTRB(18, 0, 18, 12),
        ),
      );
    }
  }

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
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 10, 14, 8),
                  child: Row(
                    children: [
                      IconButton(
                        tooltip: 'Back',
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_rounded, size: 23, color: textDark),
                      ),
                      Expanded(
                        child: Text(
                          _isSelectionMode
                              ? '${_selectedCaseIds.length} Selected'
                              : 'Recently Deleted',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: 'serif',
                            fontSize: 21,
                            fontWeight: FontWeight.w700,
                            color: textDark,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),

                // Info Banner
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF8E1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0x4DCCA046), width: 0.8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline_rounded, size: 16, color: Color(0xFFCCA046)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Tap a case to view. Long-press to select. Use Restore to reinstate a case.',
                            style: TextStyle(fontSize: 12, color: textMuted, height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Stream
                Expanded(
                  child: StreamBuilder<List<CaseModel>>(
                    stream: _firestoreService.watchCases(status: 'deleted'),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(color: primaryGreen, strokeWidth: 2),
                        );
                      }
                      if (snapshot.hasError) {
                        return Center(
                          child: Text('Error loading cases',
                              style: TextStyle(color: textMuted, fontSize: 14)),
                        );
                      }

                      final cases = snapshot.data ?? [];

                      if (cases.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(18),
                          child: CaseEmptyState(
                            title: 'No deleted cases',
                            subtitle: 'Deleted cases will appear here. Restored cases return to your active docket.',
                            icon: Icons.delete_outline_rounded,
                          ),
                        );
                      }

                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(18, 0, 18, 6),
                            child: Row(
                              children: [
                                Text(
                                  '${cases.length} ${cases.length == 1 ? 'case' : 'cases'} deleted',
                                  style: TextStyle(
                                      fontSize: 12, fontWeight: FontWeight.w600, color: textMuted),
                                ),
                                if (_isSelectionMode) ...[
                                  const Spacer(),
                                  GestureDetector(
                                    onTap: () => setState(() => _selectedCaseIds.clear()),
                                    child: const Text(
                                      'Clear selection',
                                      style: TextStyle(
                                          fontSize: 12, color: primaryGreen, fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          Expanded(
                            child: ListView.builder(
                              padding: const EdgeInsets.fromLTRB(18, 4, 18, 16),
                              physics: const BouncingScrollPhysics(),
                              itemCount: cases.length,
                              itemBuilder: (context, index) {
                                final c = cases[index];
                                final isSel = _selectedCaseIds.contains(c.id);
                                return CaseCard(
                                  caseItem: c,
                                  actionStyle: CaseCardActionStyle.deleted,
                                  isSelectionMode: _isSelectionMode,
                                  isSelected: isSel,
                                  onLongPress: () => _toggleSelect(c.id),
                                  onTap: _isSelectionMode
                                      ? () => _toggleSelect(c.id)
                                      : () => _openCaseDetail(c),
                                  onRestore: () => _restoreCase(c.id, c.caseTitle),
                                );
                              },
                            ),
                          ),
                        ],
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
        currentIndex: 2,
        onNavigate: (route) {
          if (route == '/home') {
            AppNavController.instance.switchToHome(context, index: 0, route: '/home');
          } else {
            Navigator.of(context).pushNamed(route);
          }
        },
      ),
    );
  }
}
