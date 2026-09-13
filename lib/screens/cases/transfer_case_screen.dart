import 'package:flutter/material.dart';

import '../../models/case_model.dart';
import '../../services/firestore_service.dart';
import '../../widgets/app_bottom_navigation.dart';
import '../../widgets/app_nav_controller.dart';

/// Transfer Case Screen — selects a firm lawyer to transfer a case to.
/// Back button is allowed (deep screen rule).
class TransferCaseScreen extends StatefulWidget {
  const TransferCaseScreen({super.key, this.caseItem});

  final CaseModel? caseItem;

  @override
  State<TransferCaseScreen> createState() => _TransferCaseScreenState();
}

class _TransferCaseScreenState extends State<TransferCaseScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _searchController = TextEditingController();
  String _selectedMemberId = '';
  String _selectedMemberName = '';
  String _searchQuery = '';
  bool _isTransferring = false;

  static const Color background = Color(0xFFF7F5F2);
  static const Color primaryGreen = Color(0xFF1F3D2B);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF1A1A1A);
  static const Color textMuted = Color(0xFF6B665E);
  static const Color border = Color(0xFFE5DFD7);

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _confirmTransfer() async {
    if (_selectedMemberId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a team member to transfer to.'),
          backgroundColor: primaryGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.fromLTRB(18, 0, 18, 12),
        ),
      );
      return;
    }

    final caseName = widget.caseItem?.caseTitle ?? 'this case';

    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: const Color(0x59000000),
      builder: (ctx) => AlertDialog(
        backgroundColor: cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
        contentPadding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
        actionsPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        title: const Text(
          'Confirm Transfer',
          style: TextStyle(
            fontFamily: 'serif',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: textDark,
          ),
        ),
        content: RichText(
          text: TextSpan(
            style: const TextStyle(fontSize: 13.5, color: textMuted, height: 1.5),
            children: [
              const TextSpan(text: 'Are you sure you want to transfer '),
              TextSpan(
                text: '"$caseName"',
                style: const TextStyle(color: textDark, fontWeight: FontWeight.w700),
              ),
              const TextSpan(text: ' to '),
              TextSpan(
                text: _selectedMemberName,
                style: const TextStyle(color: primaryGreen, fontWeight: FontWeight.w700),
              ),
              const TextSpan(text: '?'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            style: TextButton.styleFrom(
              foregroundColor: textMuted,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryGreen,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            ),
            child: const Text('Yes, Transfer', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isTransferring = true);
    try {
      if (widget.caseItem != null) {
        await _firestoreService.transferCase(
          caseId: widget.caseItem!.id,
          toMemberId: _selectedMemberId,
          toMemberName: _selectedMemberName,
        );
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('"$caseName" transferred to $_selectedMemberName.'),
          backgroundColor: primaryGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.fromLTRB(18, 0, 18, 12),
          duration: const Duration(seconds: 3),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isTransferring = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Transfer failed: $e'),
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
              crossAxisAlignment: CrossAxisAlignment.start,
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
                      const Expanded(
                        child: Text(
                          'Transfer Case',
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
                      const SizedBox(width: 48),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(18, 4, 18, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (widget.caseItem != null) ...[
                          _buildCaseInfoCard(widget.caseItem!),
                          const SizedBox(height: 20),
                        ],

                        const Text(
                          'Transfer To',
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            color: textDark,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Search bar
                        Container(
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: border, width: 0.8),
                          ),
                          child: TextField(
                            controller: _searchController,
                            onChanged: (v) => setState(() => _searchQuery = v.toLowerCase().trim()),
                            style: const TextStyle(fontSize: 14, color: textDark),
                            decoration: InputDecoration(
                              hintText: 'Search team member...',
                              hintStyle: TextStyle(fontSize: 13.5, color: textMuted),
                              prefixIcon: const Icon(Icons.search_rounded, size: 20, color: textMuted),
                              suffixIcon: _searchQuery.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear_rounded, size: 18, color: textMuted),
                                      onPressed: () {
                                        _searchController.clear();
                                        setState(() => _searchQuery = '');
                                      },
                                    )
                                  : null,
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(vertical: 13),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Team list
                        StreamBuilder<List<TeamMemberModel>>(
                          stream: _firestoreService.getTeamMembers(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 32),
                                child: Center(
                                  child: CircularProgressIndicator(color: primaryGreen, strokeWidth: 2),
                                ),
                              );
                            }
                            final members = (snapshot.data ?? []).where((m) {
                              if (_searchQuery.isEmpty) return true;
                              return m.name.toLowerCase().contains(_searchQuery) ||
                                  m.role.toLowerCase().contains(_searchQuery);
                            }).toList();

                            if (members.isEmpty) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 32),
                                child: Center(
                                  child: Text(
                                    _searchQuery.isEmpty
                                        ? 'No team members found'
                                        : 'No results for "$_searchQuery"',
                                    style: TextStyle(fontSize: 13.5, color: textMuted),
                                  ),
                                ),
                              );
                            }
                            return Column(
                              children: members
                                  .map((m) => _buildMemberTile(m, _selectedMemberId == m.id))
                                  .toList(),
                            );
                          },
                        ),

                        const SizedBox(height: 24),

                        // Confirm button
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton.icon(
                            onPressed: _isTransferring ? null : _confirmTransfer,
                            icon: _isTransferring
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                        color: Colors.white, strokeWidth: 2),
                                  )
                                : const Icon(Icons.swap_horiz_rounded, size: 20),
                            label: Text(
                              _isTransferring ? 'Transferring...' : 'Confirm Transfer',
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryGreen,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ],
                    ),
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

  Widget _buildCaseInfoCard(CaseModel caseItem) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border, width: 0.8),
        boxShadow: const [
          BoxShadow(color: Color(0x08111716), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F5F2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  caseItem.caseType,
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: primaryGreen,
                  ),
                ),
              ),
              const Spacer(),
              _statusChip(caseItem.status),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            caseItem.caseTitle,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: textDark),
          ),
          const SizedBox(height: 4),
          Text(caseItem.caseNumber, style: TextStyle(fontSize: 12, color: textMuted)),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.person_outline_rounded, size: 13, color: Color(0xFF9E9992)),
              const SizedBox(width: 5),
              Text(caseItem.clientName,
                  style: const TextStyle(fontSize: 12.5, color: textDark)),
              const SizedBox(width: 12),
              const Icon(Icons.account_balance_outlined, size: 13, color: Color(0xFF9E9992)),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  caseItem.courtName,
                  style: TextStyle(fontSize: 12.5, color: textMuted),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMemberTile(TeamMemberModel member, bool isSelected) {
    return GestureDetector(
      onTap: () => setState(() {
        _selectedMemberId = member.id;
        _selectedMemberName = member.name;
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0x0F1F3D2B) : cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0x661F3D2B) : border,
            width: isSelected ? 1.2 : 0.8,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0x1E1F3D2B) : const Color(0xFFF7F5F2),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  member.name.isNotEmpty ? member.name[0].toUpperCase() : '?',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? primaryGreen : textMuted,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? primaryGreen : textDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(member.role, style: TextStyle(fontSize: 12, color: textMuted)),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? primaryGreen : border,
                  width: isSelected ? 1.5 : 1.2,
                ),
                color: isSelected ? primaryGreen : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.check_rounded, size: 13, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusChip(String status) {
    Color chipColor;
    switch (status.toLowerCase()) {
      case 'urgent':
        chipColor = const Color(0xFFB3261E);
        break;
      case 'completed':
        chipColor = primaryGreen;
        break;
      case 'upcoming':
        chipColor = const Color(0xFF6750A4);
        break;
      default:
        chipColor = textMuted;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status[0].toUpperCase() + status.substring(1),
        style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: chipColor),
      ),
    );
  }
}
