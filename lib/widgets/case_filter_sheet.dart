import 'package:flutter/material.dart';

class CaseFilterCriteria {
  const CaseFilterCriteria({
    this.caseType = 'All',
    this.status = 'All',
    this.datePeriod = 'All',
    this.assignedTo = 'All',
    this.sortBy = 'nextHearing',
    this.customDateRange,
  });

  final String caseType;
  final String status;
  final String datePeriod; // All, Today, Week, Month, Custom
  final String assignedTo;
  final String sortBy; // nextHearing, title, created
  final DateTimeRange? customDateRange;

  CaseFilterCriteria copyWith({
    String? caseType,
    String? status,
    String? datePeriod,
    String? assignedTo,
    String? sortBy,
    DateTimeRange? customDateRange,
  }) {
    return CaseFilterCriteria(
      caseType: caseType ?? this.caseType,
      status: status ?? this.status,
      datePeriod: datePeriod ?? this.datePeriod,
      assignedTo: assignedTo ?? this.assignedTo,
      sortBy: sortBy ?? this.sortBy,
      customDateRange: customDateRange ?? this.customDateRange,
    );
  }
}

/// Global bottom sheet filter replacing 3-dot on case listing screens.
class CaseFilterSheet extends StatefulWidget {
  const CaseFilterSheet({
    super.key,
    required this.initialCriteria,
    required this.onApply,
    this.showStatusFilter = true,
  });

  final CaseFilterCriteria initialCriteria;
  final ValueChanged<CaseFilterCriteria> onApply;
  final bool showStatusFilter;

  static Future<void> show(
    BuildContext context, {
    required CaseFilterCriteria initialCriteria,
    required ValueChanged<CaseFilterCriteria> onApply,
    bool showStatusFilter = true,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => CaseFilterSheet(
        initialCriteria: initialCriteria,
        onApply: onApply,
        showStatusFilter: showStatusFilter,
      ),
    );
  }

  @override
  State<CaseFilterSheet> createState() => _CaseFilterSheetState();
}

class _CaseFilterSheetState extends State<CaseFilterSheet> {
  late String _caseType;
  late String _status;
  late String _datePeriod;
  late String _assignedTo;
  late String _sortBy;
  DateTimeRange? _customDateRange;

  static const Color primaryGreen = Color(0xFF1F3D2B);
  static const Color border = Color(0xFFE5DFD7);
  static const Color textDark = Color(0xFF1A1A1A);

  @override
  void initState() {
    super.initState();
    _caseType = widget.initialCriteria.caseType;
    _status = widget.initialCriteria.status;
    _datePeriod = widget.initialCriteria.datePeriod;
    _assignedTo = widget.initialCriteria.assignedTo;
    _sortBy = widget.initialCriteria.sortBy;
    _customDateRange = widget.initialCriteria.customDateRange;
  }

  Future<void> _pickCustomRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 5),
      initialDateRange: _customDateRange ??
          DateTimeRange(start: now, end: now.add(const Duration(days: 7))),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: primaryGreen,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: textDark,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _datePeriod = 'Custom';
        _customDateRange = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filter Cases',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: textDark,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded, size: 22),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Case Type
          _sectionTitle('Case Type'),
          const SizedBox(height: 8),
          _chipRow(
            options: ['All', 'Civil', 'Criminal', 'Corporate', 'Family'],
            selected: _caseType,
            onSelected: (val) => setState(() => _caseType = val),
          ),
          const SizedBox(height: 16),

          // Status Filter (if applicable)
          if (widget.showStatusFilter) ...[
            _sectionTitle('Status'),
            const SizedBox(height: 8),
            _chipRow(
              options: ['All', 'Active', 'Upcoming', 'Urgent', 'Completed'],
              selected: _status,
              onSelected: (val) => setState(() => _status = val),
            ),
            const SizedBox(height: 16),
          ],

          // Date Filter
          _sectionTitle('Hearing Date'),
          const SizedBox(height: 8),
          _chipRow(
            options: ['All', 'Today', 'Week', 'Month', 'Custom'],
            selected: _datePeriod,
            onSelected: (val) {
              if (val == 'Custom') {
                _pickCustomRange();
              } else {
                setState(() {
                  _datePeriod = val;
                  _customDateRange = null;
                });
              }
            },
          ),
          const SizedBox(height: 16),

          // Sort By
          _sectionTitle('Sort By'),
          const SizedBox(height: 8),
          _chipRow(
            options: ['Next Hearing', 'Case Title', 'Date Added'],
            selected: _sortBy == 'title'
                ? 'Case Title'
                : _sortBy == 'created'
                    ? 'Date Added'
                    : 'Next Hearing',
            onSelected: (val) {
              setState(() {
                if (val == 'Case Title') {
                  _sortBy = 'title';
                } else if (val == 'Date Added') _sortBy = 'created';
                else _sortBy = 'nextHearing';
              });
            },
          ),
          const SizedBox(height: 24),

          // Action Buttons: Apply & Reset
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _caseType = 'All';
                      _status = 'All';
                      _datePeriod = 'All';
                      _assignedTo = 'All';
                      _sortBy = 'nextHearing';
                      _customDateRange = null;
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primaryGreen,
                    side: const BorderSide(color: border),
                    minimumSize: const Size(0, 44),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Reset', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    final criteria = CaseFilterCriteria(
                      caseType: _caseType,
                      status: _status,
                      datePeriod: _datePeriod,
                      assignedTo: _assignedTo,
                      sortBy: _sortBy,
                      customDateRange: _customDateRange,
                    );
                    widget.onApply(criteria);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    minimumSize: const Size(0, 44),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Apply Filter', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: Color(0xFF6B665E),
      ),
    );
  }

  Widget _chipRow({
    required List<String> options,
    required String selected,
    required ValueChanged<String> onSelected,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: options.map((opt) {
        final isSel = opt == selected;
        return ChoiceChip(
          label: Text(opt),
          selected: isSel,
          onSelected: (_) => onSelected(opt),
          backgroundColor: const Color(0xFFF7F5F2),
          selectedColor: primaryGreen,
          labelStyle: TextStyle(
            fontSize: 12,
            fontWeight: isSel ? FontWeight.w600 : FontWeight.w500,
            color: isSel ? Colors.white : textDark,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: isSel ? primaryGreen : border,
              width: 0.8,
            ),
          ),
          showCheckmark: false,
        );
      }).toList(),
    );
  }
}
