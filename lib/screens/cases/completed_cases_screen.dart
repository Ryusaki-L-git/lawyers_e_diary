import 'package:flutter/material.dart';

import '../../models/case_model.dart';
import '../../services/firestore_service.dart';
import '../../utils/case_actions_helper.dart';
import '../../widgets/app_bottom_navigation.dart';
import '../../widgets/app_nav_controller.dart';
import '../../widgets/calendar_components.dart' hide CaseCard;
import '../../widgets/case_card.dart';
import '../../widgets/case_empty_state.dart';
import '../../widgets/case_filter_sheet.dart';
import 'case_detail_screen.dart';

/// Completed Cases Screen matching the Case Section blueprint.
class CompletedCasesScreen extends StatefulWidget {
  const CompletedCasesScreen({super.key});

  @override
  State<CompletedCasesScreen> createState() => _CompletedCasesScreenState();
}

class _CompletedCasesScreenState extends State<CompletedCasesScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  CaseFilterCriteria _filterCriteria = const CaseFilterCriteria();
  final Set<String> _selectedCaseIds = <String>{};

  bool get _isSelectionMode => _selectedCaseIds.isNotEmpty;

  static const Color background = Color(0xFFF7F5F2);
  static const Color primaryGreen = Color(0xFF1F3D2B);
  static const Color textDark = Color(0xFF1A1A1A);

  void _openFilterSheet() {
    CaseFilterSheet.show(
      context,
      initialCriteria: _filterCriteria,
      showStatusFilter: false,
      onApply: (criteria) {
        setState(() => _filterCriteria = criteria);
      },
    );
  }

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
                // Header with Back Button (Rule: Allowed on Completed Cases)
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
                              : 'Completed Cases',
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
                      IconButton(
                        tooltip: 'Filter',
                        onPressed: _openFilterSheet,
                        icon: const Icon(Icons.tune_rounded, size: 21, color: textDark),
                      ),
                    ],
                  ),
                ),

                // Stream of Completed Cases from Firestore
                Expanded(
                  child: StreamBuilder<List<CaseModel>>(
                    stream: _firestoreService.watchCases(
                      status: 'completed',
                      caseType: _filterCriteria.caseType,
                      sortBy: _filterCriteria.sortBy,
                      dateRange: _filterCriteria.customDateRange,
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(color: primaryGreen, strokeWidth: 2),
                        );
                      }

                      final cases = snapshot.data ?? [];

                      if (cases.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(18),
                          child: CaseEmptyState(
                            title: 'No completed cases',
                            subtitle: 'Cases resolved or disposed will appear in this archive docket.',
                            icon: Icons.check_circle_outline_rounded,
                          ),
                        );
                      }

                      return Column(
                        children: [
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
                                  isSelectionMode: _isSelectionMode,
                                  isSelected: isSel,
                                  onLongPress: () => _toggleSelect(c.id),
                                  onTap: () => _toggleSelect(c.id),
                                  onOpenCase: () => _openCaseDetail(c),
                                  onDiscussJuris: () => Navigator.of(context).pushNamed('/juris'),
                                );
                              },
                            ),
                          ),

                          // Bottom "Print All" or "Print Selected (X)" Button
                          Padding(
                            padding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
                            child: SizedBox(
                              width: double.infinity,
                              height: 46,
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                  final targetCases = _isSelectionMode
                                      ? cases.where((c) => _selectedCaseIds.contains(c.id)).toList()
                                      : cases;
                                  await CaseActionsHelper.printMultipleCases(
                                    context: context,
                                    cases: targetCases,
                                    title: 'Completed Cases Report',
                                  );
                                },
                                icon: const Icon(Icons.print_outlined, size: 19),
                                label: Text(
                                  _isSelectionMode
                                      ? 'Print Selected (${_selectedCaseIds.length})'
                                      : 'Print All Completed Cases',
                                  style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryGreen,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
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
