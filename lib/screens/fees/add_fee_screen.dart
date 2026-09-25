import 'package:flutter/material.dart';

import '../../models/fee_model.dart';
import '../../services/firestore_service.dart';
import '../../widgets/app_palette.dart';
import '../reminders/case_picker_sheet.dart';

/// Screen for creating a new fee record with line items.
class AddFeeScreen extends StatefulWidget {
  const AddFeeScreen({super.key});

  @override
  State<AddFeeScreen> createState() => _AddFeeScreenState();
}

class _AddFeeScreenState extends State<AddFeeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _clientController = TextEditingController();
  final _caseController = TextEditingController();
  final _notesController = TextEditingController();
  final _service = FirestoreService();

  String? _linkedCaseId;
  final List<FeeLineItem> _items = [];
  bool _isSaving = false;
  double? _agreedOverride;

  @override
  void dispose() {
    _clientController.dispose();
    _caseController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  double get _calculatedTotal =>
      _items.fold(0.0, (s, i) => s + i.subtotal);

  Future<void> _pickCase() async {
    final c = await CasePickerSheet.show(context);
    if (c != null && mounted) {
      setState(() {
        _linkedCaseId = c.id;
        _caseController.text = c.caseTitle;
        if (_clientController.text.isEmpty) {
          _clientController.text = c.clientName;
        }
      });
    }
  }

  void _addItem() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppPalette.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _AddLineItemSheet(
        onAdd: (item) {
          setState(() => _items.add(item));
        },
      ),
    );
  }

  void _removeItem(int index) {
    setState(() => _items.removeAt(index));
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Add at least one service item.'),
          backgroundColor: AppPalette.unread,
        ),
      );
      return;
    }
    setState(() => _isSaving = true);
    final id = await _service.addFee(
      clientName: _clientController.text.trim(),
      caseTitle: _caseController.text.trim(),
      caseId: _linkedCaseId,
      services: List.from(_items),
      agreedTotal: _agreedOverride ?? _calculatedTotal,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );
    if (!mounted) return;
    setState(() => _isSaving = false);
    if (id != null) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to save. Please try again.'),
          backgroundColor: AppPalette.unread,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.background,
      appBar: AppBar(
        title: const Text(
          'New Fee Record',
          style: TextStyle(
              color: AppPalette.ink, fontWeight: FontWeight.w700, fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 18, color: AppPalette.ink),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: _isSaving
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppPalette.teal),
                  )
                : TextButton(
                    onPressed: _save,
                    child: const Text('Save',
                        style: TextStyle(
                            color: AppPalette.teal,
                            fontWeight: FontWeight.w700,
                            fontSize: 15)),
                  ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Client
            _Label('Client Name'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _clientController,
              textCapitalization: TextCapitalization.words,
              decoration: _fieldDec('e.g. Ali Hassan'),
              style: const TextStyle(color: AppPalette.ink),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Client name is required'
                  : null,
            ),
            const SizedBox(height: 16),
            // Case
            _Label('Case Title'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _caseController,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: _fieldDec('Case name or matter'),
                    style: const TextStyle(color: AppPalette.ink),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Case title is required'
                        : null,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.outlined(
                  icon: const Icon(Icons.gavel_rounded, color: AppPalette.teal),
                  onPressed: _pickCase,
                  tooltip: 'Link Case',
                  style: IconButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    side: const BorderSide(color: AppPalette.border),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Services
            Row(
              children: [
                const Expanded(
                  child: _Label('Services / Line Items'),
                ),
                TextButton.icon(
                  onPressed: _addItem,
                  icon: const Icon(Icons.add_rounded,
                      color: AppPalette.teal, size: 18),
                  label: const Text('Add',
                      style: TextStyle(color: AppPalette.teal, fontSize: 13)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_items.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppPalette.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppPalette.border),
                ),
                child: const Center(
                  child: Text('No items yet. Tap Add to create a line item.',
                      style: TextStyle(color: AppPalette.mutedInk, fontSize: 13)),
                ),
              )
            else
              ..._items.asMap().entries.map((e) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _LineItemRow(
                    item: e.value,
                    onRemove: () => _removeItem(e.key),
                  ),
                );
              }),
            const SizedBox(height: 12),
            // Calculated total
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Calculated Total: Rs ${_calculatedTotal.toStringAsFixed(2)}',
                  style: const TextStyle(
                      color: AppPalette.teal,
                      fontWeight: FontWeight.w700,
                      fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Notes
            _Label('Notes (optional)'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _notesController,
              maxLines: 3,
              maxLength: 300,
              decoration: _fieldDec('Any remarks or instructions...'),
              style: const TextStyle(color: AppPalette.ink),
            ),
            const SizedBox(height: 32),
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppPalette.border)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppPalette.border)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppPalette.teal, width: 1.5)),
      counterStyle:
          const TextStyle(color: AppPalette.mutedInk, fontSize: 11),
    );
  }
}

// ─────────────────────────────────────────────────────────

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

class _LineItemRow extends StatelessWidget {
  const _LineItemRow({required this.item, required this.onRemove});

  final FeeLineItem item;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                Text(item.serviceName,
                    style: const TextStyle(
                        color: AppPalette.ink,
                        fontWeight: FontWeight.w600,
                        fontSize: 13)),
                Text(
                    'Rs ${item.rate.toStringAsFixed(2)} × ${item.quantity} = Rs ${item.subtotal.toStringAsFixed(2)}',
                    style: const TextStyle(
                        color: AppPalette.mutedInk, fontSize: 12)),
              ],
            ),
          ),
          IconButton(
            onPressed: onRemove,
            icon: const Icon(Icons.close_rounded,
                color: AppPalette.mutedInk, size: 18),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ],
      ),
    );
  }
}

class _AddLineItemSheet extends StatefulWidget {
  const _AddLineItemSheet({required this.onAdd});
  final ValueChanged<FeeLineItem> onAdd;

  @override
  State<_AddLineItemSheet> createState() => _AddLineItemSheetState();
}

class _AddLineItemSheetState extends State<_AddLineItemSheet> {
  final _nameCtrl = TextEditingController();
  final _rateCtrl = TextEditingController();
  int _qty = 1;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _rateCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Add Line Item',
              style: TextStyle(
                  color: AppPalette.ink,
                  fontWeight: FontWeight.w700,
                  fontSize: 16)),
          const SizedBox(height: 16),
          TextField(
            controller: _nameCtrl,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              labelText: 'Service / Description',
              labelStyle: const TextStyle(color: AppPalette.mutedInk),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      const BorderSide(color: AppPalette.teal, width: 1.5)),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _rateCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Rate (Rs)',
                    labelStyle: const TextStyle(color: AppPalette.mutedInk),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                            color: AppPalette.teal, width: 1.5)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                children: [
                  const Text('Qty',
                      style: TextStyle(
                          color: AppPalette.mutedInk,
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_rounded,
                            color: AppPalette.teal, size: 20),
                        onPressed: _qty > 1
                            ? () => setState(() => _qty--)
                            : null,
                      ),
                      Text('$_qty',
                          style: const TextStyle(
                              color: AppPalette.ink,
                              fontWeight: FontWeight.w700,
                              fontSize: 16)),
                      IconButton(
                        icon: const Icon(Icons.add_rounded,
                            color: AppPalette.teal, size: 20),
                        onPressed: () => setState(() => _qty++),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                final name = _nameCtrl.text.trim();
                final rate = double.tryParse(_rateCtrl.text.trim()) ?? 0.0;
                if (name.isEmpty || rate <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content:
                          Text('Enter a valid service name and rate.'),
                      backgroundColor: AppPalette.unread,
                    ),
                  );
                  return;
                }
                widget.onAdd(FeeLineItem(
                    serviceName: name, rate: rate, quantity: _qty));
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppPalette.teal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Add Item',
                  style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
