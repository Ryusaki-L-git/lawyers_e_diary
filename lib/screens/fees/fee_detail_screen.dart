import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/fee_model.dart';
import '../../services/firestore_service.dart';
import '../../widgets/app_palette.dart';
import 'record_payment_screen.dart';

/// Detailed view of a single fee record with line items and transactions.
class FeeDetailScreen extends StatefulWidget {
  const FeeDetailScreen({super.key, required this.fee});

  final FeeModel fee;

  @override
  State<FeeDetailScreen> createState() => _FeeDetailScreenState();
}

class _FeeDetailScreenState extends State<FeeDetailScreen> {
  final _service = FirestoreService();
  List<FeeTransaction> _transactions = [];
  bool _loadingTx = true;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    final tx = await _service.fetchFeeTransactions(widget.fee.id);
    if (mounted) {
      setState(() {
        _transactions = tx;
        _loadingTx = false;
      });
    }
  }

  Future<void> _openRecordPayment() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => RecordPaymentScreen(fee: widget.fee),
      ),
    );
    if (result == true && mounted) {
      _loadTransactions();
    }
  }

  Future<void> _deleteFee() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppPalette.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Fee Record?',
            style: TextStyle(color: AppPalette.ink, fontWeight: FontWeight.w700)),
        content: const Text(
          'This will permanently delete the fee record and all its transactions.',
          style: TextStyle(color: AppPalette.mutedInk, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel',
                style: TextStyle(color: AppPalette.mutedInk)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete',
                style: TextStyle(color: AppPalette.unread)),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await _service.deleteFee(widget.fee.id);
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final fee = widget.fee;
    final fmt = NumberFormat('#,##0.00', 'en_US');
    final dateFmt = DateFormat('dd MMM yyyy');

    return Scaffold(
      backgroundColor: AppPalette.background,
      appBar: AppBar(
        title: Text(
          fee.clientName,
          style: const TextStyle(
              color: AppPalette.ink, fontWeight: FontWeight.w700, fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 18, color: AppPalette.ink),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded,
                color: AppPalette.unread),
            onPressed: _deleteFee,
            tooltip: 'Delete Record',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Summary card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppPalette.teal,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(fee.caseTitle,
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _SummaryTile(
                        label: 'Agreed',
                        amount: 'Rs ${fmt.format(fee.agreedTotal)}',
                        color: Colors.white),
                    _SummaryTile(
                        label: 'Collected',
                        amount: 'Rs ${fmt.format(fee.collectedTotal)}',
                        color: Colors.white70),
                    _SummaryTile(
                        label: 'Pending',
                        amount: 'Rs ${fmt.format(fee.pendingTotal)}',
                        color: fee.pendingTotal > 0
                            ? const Color(0xFFFFD580)
                            : Colors.white70),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(fee.status.label,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Line items
          const _SectionHeader('Services'),
          const SizedBox(height: 10),
          ...fee.services.map((s) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppPalette.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppPalette.border),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(s.serviceName,
                                style: const TextStyle(
                                    color: AppPalette.ink,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13)),
                            Text(
                                'Rs ${fmt.format(s.rate)} × ${s.quantity}',
                                style: const TextStyle(
                                    color: AppPalette.mutedInk,
                                    fontSize: 12)),
                          ],
                        ),
                      ),
                      Text('Rs ${fmt.format(s.subtotal)}',
                          style: const TextStyle(
                              color: AppPalette.ink,
                              fontWeight: FontWeight.w700,
                              fontSize: 13)),
                    ],
                  ),
                ),
              )),
          if (fee.notes != null && fee.notes!.isNotEmpty) ...[
            const SizedBox(height: 16),
            const _SectionHeader('Notes'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppPalette.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppPalette.border),
              ),
              child: Text(fee.notes!,
                  style: const TextStyle(
                      color: AppPalette.mutedInk, fontSize: 14)),
            ),
          ],
          const SizedBox(height: 20),
          // Transactions
          Row(
            children: [
              const Expanded(child: _SectionHeader('Payment History')),
              if (fee.status != FeeStatus.settled)
                TextButton.icon(
                  onPressed: _openRecordPayment,
                  icon: const Icon(Icons.add_rounded,
                      color: AppPalette.teal, size: 18),
                  label: const Text('Record',
                      style: TextStyle(color: AppPalette.teal, fontSize: 13)),
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (_loadingTx)
            const Center(child: CircularProgressIndicator())
          else if (_transactions.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppPalette.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppPalette.border),
              ),
              child: const Center(
                child: Text('No payments recorded yet.',
                    style: TextStyle(color: AppPalette.mutedInk, fontSize: 13)),
              ),
            )
          else
            ..._transactions.map((tx) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppPalette.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppPalette.border),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE2F0EC),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.payments_rounded,
                              color: AppPalette.teal, size: 18),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(tx.paymentMode,
                                  style: const TextStyle(
                                      color: AppPalette.ink,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13)),
                              Text(dateFmt.format(tx.paymentDate),
                                  style: const TextStyle(
                                      color: AppPalette.mutedInk,
                                      fontSize: 12)),
                            ],
                          ),
                        ),
                        Text('Rs ${fmt.format(tx.amount)}',
                            style: const TextStyle(
                                color: AppPalette.teal,
                                fontWeight: FontWeight.w700,
                                fontSize: 14)),
                      ],
                    ),
                  ),
                )),
          const SizedBox(height: 32),
        ],
      ),
      bottomNavigationBar: fee.status != FeeStatus.settled
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: _openRecordPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppPalette.teal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Record Payment',
                      style: TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 15)),
                ),
              ),
            )
          : null,
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile(
      {required this.label, required this.amount, required this.color});
  final String label;
  final String amount;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  color: color.withValues(alpha: 0.7),
                  fontSize: 10,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 3),
          Text(amount,
              style: TextStyle(
                  color: color, fontSize: 13, fontWeight: FontWeight.w700),
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: const TextStyle(
            color: AppPalette.ink,
            fontWeight: FontWeight.w700,
            fontSize: 15));
  }
}
