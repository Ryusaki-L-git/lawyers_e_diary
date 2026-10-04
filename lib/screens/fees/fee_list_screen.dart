import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/fee_model.dart';
import '../../services/firestore_service.dart';
import '../../widgets/app_bottom_navigation.dart';
import '../../widgets/app_nav_controller.dart';
import '../../widgets/app_palette.dart';
import 'add_fee_screen.dart';
import 'fee_detail_screen.dart';

/// Dashboard listing all fee records with summary stats.
class FeeListScreen extends StatelessWidget {
  const FeeListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = FirestoreService();

    return Scaffold(
      backgroundColor: AppPalette.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Fee Calculator',
          style: TextStyle(
            color: AppPalette.ink,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_rounded,
                color: AppPalette.teal, size: 28),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddFeeScreen()),
            ),
            tooltip: 'Add Fee Record',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: StreamBuilder<List<FeeModel>>(
        stream: service.watchFees(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final fees = snap.data ?? [];

          if (fees.isEmpty) {
            return _FeeEmptyState(
              onAdd: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddFeeScreen()),
              ),
            );
          }

          // Compute summary
          final totalAgreed = fees.fold(0.0, (s, f) => s + f.agreedTotal);
          final totalCollected = fees.fold(0.0, (s, f) => s + f.collectedTotal);
          final totalPending = fees.fold(0.0, (s, f) => s + f.pendingTotal);

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: _FeeSummaryBanner(
                  agreed: totalAgreed,
                  collected: totalCollected,
                  pending: totalPending,
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _FeeCard(
                          fee: fees[index],
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => FeeDetailScreen(fee: fees[index]),
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: fees.length,
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddFeeScreen()),
        ),
        backgroundColor: AppPalette.teal,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'New Record',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),
      bottomNavigationBar: const AppBottomNavigation(
        currentIndex: 0,
        mode: NavMode.home,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────

class _FeeSummaryBanner extends StatelessWidget {
  const _FeeSummaryBanner({
    required this.agreed,
    required this.collected,
    required this.pending,
  });

  final double agreed;
  final double collected;
  final double pending;

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,##0.00', 'en_US');
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppPalette.teal,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          _StatCol(label: 'Total Agreed', value: 'Rs ${fmt.format(agreed)}',
              valueColor: Colors.white),
          const SizedBox(width: 1),
          _Divider(),
          _StatCol(label: 'Collected', value: 'Rs ${fmt.format(collected)}',
              valueColor: const Color(0xFF9EABA4)),
          _Divider(),
          _StatCol(label: 'Pending', value: 'Rs ${fmt.format(pending)}',
              valueColor: const Color(0xFFFFD580)),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 36,
      color: Colors.white.withValues(alpha: 0.2),
      margin: const EdgeInsets.symmetric(horizontal: 12),
    );
  }
}

class _StatCol extends StatelessWidget {
  const _StatCol(
      {required this.label, required this.value, required this.valueColor});
  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  color: Color(0xFF9EABA4), fontSize: 10, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  color: valueColor, fontSize: 12, fontWeight: FontWeight.w700),
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

class _FeeCard extends StatelessWidget {
  const _FeeCard({required this.fee, required this.onTap});

  final FeeModel fee;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,##0.00', 'en_US');
    Color statusColor;
    switch (fee.status) {
      case FeeStatus.settled:
        statusColor = AppPalette.teal;
        break;
      case FeeStatus.partiallyPaid:
        statusColor = AppPalette.gold;
        break;
      case FeeStatus.quoted:
      statusColor = AppPalette.mutedInk;
    }

    return Material(
      color: AppPalette.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      fee.clientName,
                      style: const TextStyle(
                        color: AppPalette.ink,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      fee.status.label,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                fee.caseTitle,
                style: const TextStyle(color: AppPalette.mutedInk, fontSize: 13),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _AmountCol(label: 'Agreed', amount: 'Rs ${fmt.format(fee.agreedTotal)}'),
                  _AmountCol(label: 'Collected', amount: 'Rs ${fmt.format(fee.collectedTotal)}'),
                  _AmountCol(
                    label: 'Pending',
                    amount: 'Rs ${fmt.format(fee.pendingTotal)}',
                    color: fee.pendingTotal > 0 ? AppPalette.unread : AppPalette.teal,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AmountCol extends StatelessWidget {
  const _AmountCol({required this.label, required this.amount, this.color});

  final String label;
  final String amount;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  color: AppPalette.mutedInk, fontSize: 10, fontWeight: FontWeight.w600)),
          const SizedBox(height: 3),
          Text(amount,
              style: TextStyle(
                color: color ?? AppPalette.ink,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

class _FeeEmptyState extends StatelessWidget {
  const _FeeEmptyState({required this.onAdd});
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFFE2F0EC),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.calculate_rounded,
                  color: AppPalette.teal, size: 36),
            ),
            const SizedBox(height: 20),
            const Text('No fee records yet',
                style: TextStyle(
                    color: AppPalette.ink,
                    fontSize: 17,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            const Text('Track fees, payments & balance for your cases.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppPalette.mutedInk, fontSize: 14)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onAdd,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppPalette.teal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add Fee Record',
                  style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }
}
