import 'dart:async';
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

class AllCasesScreen extends StatefulWidget {
  const AllCasesScreen({super.key});

  @override
  State<AllCasesScreen> createState() => _AllCasesScreenState();
}

class _AllCasesScreenState extends State<AllCasesScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _searchController = TextEditingController();

  Timer? _debounce;

  String _activeChip = 'All';
  CaseFilterCriteria _filterCriteria = const CaseFilterCriteria();

  final Set<String> _selectedCaseIds = {};
  List<CaseModel> _latestCases = [];

  bool get _isSelectionMode => _selectedCaseIds.isNotEmpty;

  static const Color background = Color(0xFFF7F5F2);
  static const Color primaryGreen = Color(0xFF1F3D2B);
  static const Color textDark = Color(0xFF1A1A1A);
  static const Color border = Color(0xFFE5DFD7);

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String val) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() {});
    });
  }

  void _openFilterSheet() {
    CaseFilterSheet.show(
      context,
      initialCriteria: _filterCriteria,
      onApply: (criteria) {
        setState(() {
          _filterCriteria = criteria;
          _activeChip = 'All'; // prevent conflict
        });
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

  void _clearSelection() {
    setState(() => _selectedCaseIds.clear());
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
    String? effectiveStatus;

    if (_activeChip != 'All') {
      effectiveStatus = _activeChip.toLowerCase();
    } else if (_filterCriteria.status.toLowerCase() != 'all') {
      effectiveStatus = _filterCriteria.status.toLowerCase();
    }

    return PopScope(
      canPop: !_isSelectionMode,
      onPopInvokedWithResult: (didPop, result) {
        if (_isSelectionMode) _clearSelection();
      },
      child: Scaffold(
        backgroundColor: background,
        body: SafeArea(
          bottom: false,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                children: [
                  // HEADER
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 12, 14, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _isSelectionMode
                              ? '${_selectedCaseIds.length} Selected'
                              : 'All Cases',
                          style: const TextStyle(
                            fontFamily: 'serif',
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: textDark,
                          ),
                        ),
                        if (_isSelectionMode)
                          TextButton(
                            onPressed: _clearSelection,
                            child: const Text(
                              'Cancel',
                              style: TextStyle(color: primaryGreen),
                            ),
                          )
                        else
                          IconButton(
                            onPressed: _openFilterSheet,
                            icon: const Icon(Icons.tune_rounded, size: 22),
                          ),
                      ],
                    ),
                  ),

                  // SEARCH
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Container(
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: border),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: _onSearchChanged,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.search_rounded, size: 20),
                          hintText: 'Search cases, clients, CNR...',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // FILTER CHIPS
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Row(
                      children: ['All', 'Active', 'Upcoming', 'Urgent']
                          .map((chip) {
                        final isSel = _activeChip == chip;
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _activeChip = chip;
                                _filterCriteria =
                                    const CaseFilterCriteria(); // reset filters
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color:
                                    isSel ? primaryGreen : Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: border),
                              ),
                              child: Text(
                                chip,
                                style: TextStyle(
                                  fontSize: 11,
                                  color:
                                      isSel ? Colors.white : textDark,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // LIST
                  Expanded(
                    child: StreamBuilder<List<CaseModel>>(
                      stream: _firestoreService.watchCases(
                        status: effectiveStatus,
                        caseType: _filterCriteria.caseType,
                        handledBy: _filterCriteria.assignedTo,
                        searchQuery: _searchController.text,
                        sortBy: _filterCriteria.sortBy,
                        dateRange: _filterCriteria.customDateRange,
                      ),
                      builder: (context, snapshot) {
                        final cases = snapshot.data ?? [];
                        _latestCases = cases;

                        if (cases.isEmpty) {
                          final hasActiveFilter =
                              _searchController.text.isNotEmpty ||
                              _activeChip != 'All' ||
                              _filterCriteria.caseType != 'All' ||
                              _filterCriteria.assignedTo != 'All' ||
                              _filterCriteria.customDateRange != null;

                          return Padding(
                            padding: const EdgeInsets.all(18),
                            child: CaseEmptyState(
                              title: hasActiveFilter
                                  ? 'No cases found'
                                  : 'No cases yet',
                              subtitle: hasActiveFilter
                                  ? (_searchController.text.isNotEmpty
                                      ? 'No results found'
                                      : 'No cases match your filters')
                                  : 'Get started by creating your first case docket',
                              icon: hasActiveFilter
                                  ? (_searchController.text.isNotEmpty
                                      ? Icons.search_off_rounded
                                      : Icons.folder_open_rounded)
                                  : Icons.folder_open_rounded,
                              actionLabel:
                                  hasActiveFilter ? 'Reset' : 'Add Case',
                              onAction: () {
                                if (hasActiveFilter) {
                                  setState(() {
                                    _searchController.clear();
                                    _activeChip = 'All';
                                    _filterCriteria =
                                        const CaseFilterCriteria();
                                  });
                                } else {
                                  Navigator.pushNamed(context, '/add_case');
                                }
                              },
                            ),
                          );
                        }

                        return ListView.builder(
                          itemCount: cases.length,
                          padding:
                              const EdgeInsets.fromLTRB(18, 4, 18, 90),
                          itemBuilder: (context, index) {
                            final c = cases[index];
                            final isSel =
                                _selectedCaseIds.contains(c.id);

                            return CaseCard(
                              key: ValueKey(c.id),
                              caseItem: c,
                              isSelectionMode: _isSelectionMode,
                              isSelected: isSel,
                              onLongPress: () => _toggleSelect(c.id),
                              onTap: () {
                                if (_isSelectionMode) {
                                  _toggleSelect(c.id);
                                } else {
                                  _openCaseDetail(c);
                                }
                              },
                              onOpenCase: () => _openCaseDetail(c),
                              onDiscussJuris: _openJuris,
                              onToggleStar: () => _firestoreService
                                  .toggleCaseStarred(c.id, !c.isStarred),
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
        floatingActionButton: _isSelectionMode
            ? null
            : FloatingActionButton.extended(
                heroTag: 'allCasesAddCaseFab',
                onPressed: () {
                  Navigator.of(context).pushNamed('/add_case');
                },
                backgroundColor: primaryGreen,
                foregroundColor: Colors.white,
                elevation: 3,
                icon: const Icon(Icons.add_rounded),
                label: const Text(
                  'Add Case',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
              ),

        // PRINT SELECTED
        bottomSheet: _isSelectionMode
            ? Container(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final selectedCases = _latestCases
                        .where((c) => _selectedCaseIds.contains(c.id))
                        .toList();

                    await CaseActionsHelper.printMultipleCases(
                      context: context,
                      cases: selectedCases,
                      title: 'Selected Cases',
                    );
                  },
                  icon: const Icon(Icons.print),
                  label: Text(
                      'Print Selected (${_selectedCaseIds.length})'),
                ),
              )
            : null,

        bottomNavigationBar: AppBottomNavigation(
          mode: NavMode.caseSection,
          currentIndex: 1,
          onNavigate: (route) {
            if (route == '/home') {
              AppNavController.instance
                  .switchToHome(context, index: 0, route: '/home');
            } else if (route != '/cases') {
              Navigator.of(context).pushNamed(route);
            }
          },
        ),
      ),
    );
  }
}