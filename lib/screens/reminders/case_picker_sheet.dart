import 'package:flutter/material.dart';

import '../../models/case_model.dart';
import '../../services/firestore_service.dart';
import '../../widgets/app_palette.dart';

/// Bottom sheet to pick a case and link it to a reminder.
class CasePickerSheet extends StatefulWidget {
  const CasePickerSheet({super.key});

  static Future<CaseModel?> show(BuildContext context) {
    return showModalBottomSheet<CaseModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppPalette.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const CasePickerSheet(),
    );
  }

  @override
  State<CasePickerSheet> createState() => _CasePickerSheetState();
}

class _CasePickerSheetState extends State<CasePickerSheet> {
  final _service = FirestoreService();
  String _query = '';

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      expand: false,
      builder: (context, controller) {
        return Column(
          children: [
            // Handle
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppPalette.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  const Text(
                    'Link a Case',
                    style: TextStyle(
                      color: AppPalette.ink,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Skip',
                      style: TextStyle(color: AppPalette.mutedInk),
                    ),
                  ),
                ],
              ),
            ),
            // Search
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: TextField(
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search case or client...',
                  hintStyle: const TextStyle(color: AppPalette.mutedInk),
                  prefixIcon: const Icon(Icons.search_rounded, color: AppPalette.mutedInk),
                  filled: true,
                  fillColor: AppPalette.background,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppPalette.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppPalette.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppPalette.teal, width: 1.5),
                  ),
                ),
                onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
              ),
            ),
            const Divider(height: 1, color: AppPalette.border),
            // Case list
            Expanded(
              child: StreamBuilder<List<CaseModel>>(
                stream: _service.watchCases(status: 'active'),
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final all = snap.data ?? [];
                  final filtered = _query.isEmpty
                      ? all
                      : all.where((c) {
                          return c.caseTitle.toLowerCase().contains(_query) ||
                              c.clientName.toLowerCase().contains(_query) ||
                              c.caseNumber.toLowerCase().contains(_query);
                        }).toList();

                  if (filtered.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.folder_open_rounded,
                              color: AppPalette.border, size: 48),
                          const SizedBox(height: 12),
                          const Text(
                            'No cases found',
                            style: TextStyle(color: AppPalette.mutedInk),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    controller: controller,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: filtered.length,
                    separatorBuilder: (_, i) =>
                        const Divider(height: 1, indent: 20, color: AppPalette.border),
                    itemBuilder: (context, index) {
                      final c = filtered[index];
                      return ListTile(
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE2F0EC),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.gavel_rounded,
                            color: AppPalette.teal,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          c.caseTitle,
                          style: const TextStyle(
                            color: AppPalette.ink,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          '${c.clientName} · ${c.caseNumber}',
                          style: const TextStyle(
                            color: AppPalette.mutedInk,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () => Navigator.pop(context, c),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
