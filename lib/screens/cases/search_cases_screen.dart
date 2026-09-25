import 'dart:async';
import 'package:flutter/material.dart';

import '../../models/case_model.dart';
import '../../services/firestore_service.dart';
import '../../widgets/app_bottom_navigation.dart';
import '../../widgets/app_nav_controller.dart';
import '../../widgets/calendar_components.dart' hide CaseCard;
import '../../widgets/case_card.dart';
import '../../widgets/case_empty_state.dart';
import '../../widgets/case_filter_sheet.dart';
import 'case_detail_screen.dart';

/// Search Cases Screen matching the Case Section blueprint.
/// Includes 300ms debounce, recent searches, live Firestore search, and CaseBottomNavigation.
class SearchCasesScreen extends StatefulWidget {
  const SearchCasesScreen({super.key});

  @override
  State<SearchCasesScreen> createState() => _SearchCasesScreenState();
}

class _SearchCasesScreenState extends State<SearchCasesScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _controller = TextEditingController();
  Timer? _debounceTimer;

  String _searchQuery = '';
  CaseFilterCriteria _filterCriteria = const CaseFilterCriteria();
  final List<String> _recentSearches = ['Smith vs Johnson', 'ABC Corp', 'State vs John'];

  static const Color background = Color(0xFFF7F5F2);
  static const Color primaryGreen = Color(0xFF1F3D2B);
  static const Color textDark = Color(0xFF1A1A1A);
  static const Color textMuted = Color(0xFF6B665E);
  static const Color border = Color(0xFFE5DFD7);

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      setState(() => _searchQuery = query.trim());
    });
  }

  void _openFilterSheet() {
    CaseFilterSheet.show(
      context,
      initialCriteria: _filterCriteria,
      onApply: (criteria) {
        setState(() => _filterCriteria = criteria);
      },
    );
  }

  void _openCaseDetail(CaseModel caseItem) {
    Navigator.of(context).push(
      CalendarPageRoute(
        builder: (_) => CaseDetailScreen(caseItem: caseItem),
      ),
    );
  }

  void _openJuris() {
    Navigator.of(context).pushNamed('/juris');
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header: Title + Filter Icon (NO back button)
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 12, 14, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Search Cases',
                        style: TextStyle(
                          fontFamily: 'serif',
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: textDark,
                          letterSpacing: -0.2,
                        ),
                      ),
                      IconButton(
                        tooltip: 'Filter',
                        onPressed: _openFilterSheet,
                        icon: const Icon(Icons.tune_rounded, size: 22, color: textDark),
                      ),
                    ],
                  ),
                ),

                // Search Bar with barcode/qr trailing icon
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: border, width: 0.8),
                    ),
                    child: Row(
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Icon(Icons.search_rounded, size: 20, color: textMuted),
                        ),
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            onChanged: _onSearchChanged,
                            style: const TextStyle(fontSize: 13, color: textDark),
                            decoration: const InputDecoration(
                              hintText: 'Search cases, clients, case ID...',
                              hintStyle: TextStyle(fontSize: 12.5, color: textMuted),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                        if (_controller.text.isNotEmpty)
                          IconButton(
                            onPressed: () {
                              _controller.clear();
                              setState(() => _searchQuery = '');
                            },
                            icon: const Icon(Icons.clear_rounded, size: 18, color: textMuted),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        IconButton(
                          tooltip: 'Scan CNR Barcode',
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Camera barcode scanner ready for CNR scanning'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          icon: const Icon(Icons.qr_code_scanner_rounded, size: 19, color: primaryGreen),
                        ),
                        const SizedBox(width: 4),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // Recent Searches Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Recent Searches',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: textMuted,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: _recentSearches.map((term) {
                          return ActionChip(
                            label: Text(term),
                            onPressed: () {
                              _controller.text = term;
                              setState(() => _searchQuery = term);
                            },
                            backgroundColor: Colors.white,
                            side: const BorderSide(color: border, width: 0.8),
                            labelStyle: const TextStyle(fontSize: 11.5, color: textDark),
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // Search Results Header
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 18),
                  child: Text(
                    'Search Results',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: textDark,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // Live Results from Firestore
                Expanded(
                  child: StreamBuilder<List<CaseModel>>(
                    stream: _firestoreService.watchCases(
                      searchQuery: _searchQuery,
                      caseType: _filterCriteria.caseType,
                      status: _filterCriteria.status,
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
                        return Padding(
                          padding: const EdgeInsets.all(18),
                          child: CaseEmptyState(
                            title: 'No search results found',
                            subtitle: _searchQuery.isNotEmpty
                                ? 'No case records matched "$_searchQuery".'
                                : 'Start typing a case title, client name, or CNR number.',
                            icon: Icons.search_off_rounded,
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.fromLTRB(18, 4, 18, 90),
                        physics: const BouncingScrollPhysics(),
                        itemCount: cases.length,
                        itemBuilder: (context, index) {
                          final c = cases[index];
                          return CaseCard(
                            caseItem: c,
                            onOpenCase: () => _openCaseDetail(c),
                            onDiscussJuris: _openJuris,
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
        currentIndex: 0,
        onNavigate: (route) {
          if (route == '/home') {
            AppNavController.instance.switchToHome(context, index: 0, route: '/home');
          } else if (route != '/search_cases') {
            Navigator.of(context).pushNamed(route);
          }
        },
      ),
    );
  }
}
