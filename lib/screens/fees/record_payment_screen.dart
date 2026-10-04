import 'package:flutter/material.dart';

import '../../models/fee_model.dart';
import '../../services/firestore_service.dart';
import '../../widgets/app_palette.dart';

/// Screen for recording a payment against an existing fee record.
class RecordPaymentScreen extends StatefulWidget {
  const RecordPaymentScreen({super.key, required this.fee});

  final FeeModel fee;

  @override
  State<RecordPaymentScreen> createState() => _RecordPaymentScreenState();
}

class _RecordPaymentScreenState extends State<RecordPaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _receiptController = TextEditingController();
  final _service = FirestoreService();
  bool _isSaving = false;
  String _paymentMode = 'Cash';

  static const _paymentModes = [
    'Cash',
    'Bank Transfer',
    'Cheque',
    'Online',
    'Other',
  ];

  @override
  void dispose() {
    _amountController.dispose();
    _receiptController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final amount = double.tryParse(_amountController.text.trim()) ?? 0.0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter a valid payment amount.'),
          backgroundColor: AppPalette.unread,
        ),
      );
      return;
    }
    final newCollected =
        (widget.fee.collectedTotal + amount).clamp(0.0, widget.fee.agreedTotal * 2);
    setState(() => _isSaving = true);
    await _service.recordFeePayment(
      feeId: widget.fee.id,
      amount: amount,
      newCollectedTotal: newCollected,
      agreedTotal: widget.fee.agreedTotal,
      paymentMode: _paymentMode,
      receiptNumber: _receiptController.text.trim().isEmpty
          ? null
          : _receiptController.text.trim(),
    );
    if (!mounted) return;
    setState(() => _isSaving = false);
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final pending = widget.fee.pendingTotal;

    return Scaffold(
      backgroundColor: AppPalette.background,
      appBar: AppBar(
        title: const Text(
          'Record Payment',
          style: TextStyle(
              color: AppPalette.ink, fontWeight: FontWeight.w700, fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 18, color: AppPalette.ink),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Info card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppPalette.teal.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: AppPalette.teal.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.fee.clientName,
                      style: const TextStyle(
                          color: AppPalette.ink,
                          fontWeight: FontWeight.w700,
                          fontSize: 15)),
                  const SizedBox(height: 4),
                  Text('Pending: Rs ${pending.toStringAsFixed(2)}',
                      style: const TextStyle(
                          color: AppPalette.teal,
                          fontWeight: FontWeight.w600,
                          fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Amount
            const _Label('Payment Amount (Rs)'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _amountController,
              autofocus: true,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: _fieldDec(
                  'e.g. ${(pending / 2).toStringAsFixed(0)}'),
              style: const TextStyle(
                  color: AppPalette.ink,
                  fontSize: 18,
                  fontWeight: FontWeight.w700),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Amount is required';
                }
                final d = double.tryParse(v.trim());
                if (d == null || d <= 0) return 'Enter a valid amount';
                return null;
              },
            ),
            const SizedBox(height: 16),
            // Payment mode
            const _Label('Payment Mode'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _paymentModes.map((m) {
                final selected = m == _paymentMode;
                return GestureDetector(
                  onTap: () => setState(() => _paymentMode = m),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppPalette.teal
                          : AppPalette.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: selected
                            ? AppPalette.teal
                            : AppPalette.border,
                      ),
                    ),
                    child: Text(m,
                        style: TextStyle(
                          color: selected
                              ? Colors.white
                              : AppPalette.mutedInk,
                          fontSize: 13,
                          fontWeight: selected
                              ? FontWeight.w600
                              : FontWeight.w500,
                        )),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            // Receipt number
            const _Label('Receipt / Ref Number (optional)'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _receiptController,
              decoration: _fieldDec('e.g. RCT-2024-001'),
              style: const TextStyle(color: AppPalette.ink),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppPalette.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Confirm Payment',
                        style: TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _fieldDec(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppPalette.mutedInk, fontSize: 14),
      filled: true,
      fillColor: AppPalette.surface,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppPalette.border)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppPalette.border)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppPalette.teal, width: 1.5)),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: const TextStyle(
            color: AppPalette.mutedInk,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.4));
  }
}
