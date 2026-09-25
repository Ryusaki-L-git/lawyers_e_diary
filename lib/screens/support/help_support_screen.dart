import 'package:flutter/material.dart';

import '../../models/support_ticket_model.dart';
import '../../services/support_service.dart';
import '../../widgets/app_palette.dart';

/// Comprehensive in-app Help & Support Screen.
/// Sections: FAQ Accordion, Submit Ticket Intake Sheet, My Tickets History, App Information.
class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  int _selectedTab = 0; // 0 = FAQ / Help Center, 1 = My Requests

  static const List<Map<String, String>> _faqItems = [
    {
      'question': 'How does Cloud Storage & Sync operate?',
      'answer':
          'When upgraded to a Cloud Subscription, your legal dockets, clients, and case files automatically synchronize with secure cloud storage, enabling real-time multi-device access and automatic backup.',
    },
    {
      'question': 'Can I access case dockets without internet connectivity?',
      'answer':
          'Yes. Lawyer\'s E-Diary maintains local offline persistence. You can review saved dockets, client contacts, and hearing dates offline; pending changes synchronize once network connection resumes.',
    },
    {
      'question': 'How are next hearing dates prioritized?',
      'answer':
          'Cases with upcoming hearing dates within 72 hours are automatically flagged as Urgent in your master docket and cause list, triggering priority reminders.',
    },
    {
      'question': 'How do I export or share case dossiers?',
      'answer':
          'Within any Case Detail screen, open the three-dot action menu to share case summaries, dispatch hearing notices via WhatsApp, or generate formal printable PDF dossiers.',
    },
    {
      'question': 'Are client records private and isolated?',
      'answer':
          'Yes. All client records and case files are strictly isolated to your authenticated account credentials under enterprise-grade database rules.',
    },
  ];

  void _openSubmitTicketSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _SubmitTicketSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.canvas,
      appBar: AppBar(
        backgroundColor: AppPalette.canvas,
        foregroundColor: AppPalette.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Help & Support',
          style: TextStyle(
            color: AppPalette.textPrimary,
            fontFamily: 'serif',
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openSubmitTicketSheet,
        backgroundColor: AppPalette.primaryGreen,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.support_agent_rounded, size: 20),
        label: const Text(
          'Submit Request',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Tab Toggle Selector
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 12),
              child: Container(
                height: 42,
                decoration: BoxDecoration(
                  color: AppPalette.cardBackground,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppPalette.borderLight),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedTab = 0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: _selectedTab == 0
                                ? AppPalette.primaryGreen
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(9),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Knowledge Center',
                            style: TextStyle(
                              color: _selectedTab == 0
                                  ? Colors.white
                                  : AppPalette.textMuted,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedTab = 1),
                        child: Container(
                          decoration: BoxDecoration(
                            color: _selectedTab == 1
                                ? AppPalette.primaryGreen
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(9),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'My Requests',
                            style: TextStyle(
                              color: _selectedTab == 1
                                  ? Colors.white
                                  : AppPalette.textMuted,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Tab Content
            Expanded(
              child: _selectedTab == 0
                  ? _buildFaqTab()
                  : _buildMyTicketsTab(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 4, 18, 80),
      children: [
        // Quick Action Support Banner
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppPalette.cardBackground,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppPalette.borderLight),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppPalette.primaryGreen.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.headset_mic_rounded,
                  color: AppPalette.primaryGreen,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Direct Chamber Assistance',
                      style: TextStyle(
                        color: AppPalette.textPrimary,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Encountering technical disruption? Submit a ticket for investigation.',
                      style: TextStyle(
                        color: AppPalette.textMuted,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // Section Title
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'FREQUENTLY ASKED QUESTIONS',
            style: TextStyle(
              color: AppPalette.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
        ),

        // FAQ Accordions
        ..._faqItems.map((item) {
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: AppPalette.cardBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppPalette.borderLight),
            ),
            child: Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                iconColor: AppPalette.primaryGreen,
                collapsedIconColor: AppPalette.textMuted,
                tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                title: Text(
                  item['question']!,
                  style: const TextStyle(
                    color: AppPalette.textPrimary,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                children: [
                  Text(
                    item['answer']!,
                    style: const TextStyle(
                      color: AppPalette.textMuted,
                      fontSize: 13,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 14),

        // App Information Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppPalette.cardBackground,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppPalette.borderLight),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Lawyer\'s E-Diary System',
                style: TextStyle(
                  color: AppPalette.textPrimary,
                  fontFamily: 'serif',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Edition: SaaS Chambers Production\nVersion: 1.0.0 (Build 2026.09)\nInquiries: support@lawyersediary.com',
                style: TextStyle(
                  color: AppPalette.textMuted,
                  fontSize: 12,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMyTicketsTab() {
    return StreamBuilder<List<SupportTicketModel>>(
      stream: SupportService.instance.watchMyTickets(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppPalette.primaryGreen,
              strokeWidth: 2.5,
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading tickets: ${snapshot.error}',
              style: const TextStyle(color: AppPalette.textMuted),
            ),
          );
        }

        final tickets = snapshot.data ?? [];

        if (tickets.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppPalette.primaryGreen.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.inbox_outlined,
                      color: AppPalette.primaryGreen,
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No Inquiries Submitted',
                    style: TextStyle(
                      color: AppPalette.textPrimary,
                      fontFamily: 'serif',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Any support requests, feature suggestions, or bug reports you submit will appear here with real-time status tracking.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppPalette.textMuted,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(18, 4, 18, 80),
          physics: const BouncingScrollPhysics(),
          itemCount: tickets.length,
          itemBuilder: (context, index) {
            final ticket = tickets[index];
            return _TicketCard(ticket: ticket);
          },
        );
      },
    );
  }
}

class _TicketCard extends StatelessWidget {
  const _TicketCard({required this.ticket});

  final SupportTicketModel ticket;

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'resolved':
        return const Color(0xFF27AE60);
      case 'under_review':
        return const Color(0xFFE67A20);
      case 'pending':
      default:
        return const Color(0xFF6750A4);
    }
  }

  String _statusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'resolved':
        return 'Resolved';
      case 'under_review':
        return 'Under Review';
      case 'pending':
      default:
        return 'Pending';
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(ticket.status);
    final statusLabel = _statusLabel(ticket.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppPalette.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppPalette.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                ticket.category,
                style: const TextStyle(
                  color: AppPalette.textMuted,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (ticket.createdAt != null)
                Text(
                  '${ticket.createdAt!.day}/${ticket.createdAt!.month}/${ticket.createdAt!.year}',
                  style: const TextStyle(
                    color: AppPalette.textMuted,
                    fontSize: 11,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            ticket.subject,
            style: const TextStyle(
              color: AppPalette.textPrimary,
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            ticket.message,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppPalette.textMuted,
              fontSize: 12.5,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _SubmitTicketSheet extends StatefulWidget {
  const _SubmitTicketSheet();

  @override
  State<_SubmitTicketSheet> createState() => _SubmitTicketSheetState();
}

class _SubmitTicketSheetState extends State<_SubmitTicketSheet> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();

  String _selectedType = 'inquiry';
  String _selectedCategory = 'Case Management';
  bool _isSubmitting = false;

  static const List<Map<String, String>> _types = [
    {'value': 'inquiry', 'label': 'General Inquiry'},
    {'value': 'bug', 'label': 'Bug Report'},
    {'value': 'feature', 'label': 'Feature Request'},
    {'value': 'feedback', 'label': 'Account Feedback'},
  ];

  static const List<String> _categories = [
    'Case Management',
    'Cloud Sync',
    'Calendar & Hearings',
    'Billing & Fees',
    'Other',
  ];

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final docId = await SupportService.instance.submitSupportTicket(
        type: _selectedType,
        category: _selectedCategory,
        subject: _subjectController.text.trim(),
        message: _messageController.text.trim(),
      );

      if (mounted) {
        setState(() => _isSubmitting = false);
        if (docId != null) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Support request submitted. We will investigate promptly.'),
              backgroundColor: AppPalette.primaryGreen,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to submit request. Please try again.'),
              backgroundColor: Color(0xFFB3261E),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: const Color(0xFFB3261E),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: AppPalette.cardBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppPalette.borderLight,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Submit Support Request',
                style: TextStyle(
                  color: AppPalette.textPrimary,
                  fontFamily: 'serif',
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),

              // Request Type Dropdown
              _fieldLabel('Request Classification'),
              DropdownButtonFormField<String>(
                initialValue: _selectedType,
                decoration: _fieldDecoration(),
                items: _types.map((t) {
                  return DropdownMenuItem(
                    value: t['value'],
                    child: Text(t['label']!),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedType = val);
                },
              ),
              const SizedBox(height: 14),

              // Category Dropdown
              _fieldLabel('Chamber Domain Category'),
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: _fieldDecoration(),
                items: _categories.map((cat) {
                  return DropdownMenuItem(
                    value: cat,
                    child: Text(cat),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedCategory = val);
                },
              ),
              const SizedBox(height: 14),

              // Subject Field
              _fieldLabel('Subject *'),
              TextFormField(
                controller: _subjectController,
                textCapitalization: TextCapitalization.sentences,
                decoration: _fieldDecoration(hint: 'Brief summary of issue or inquiry'),
                validator: (val) =>
                    val == null || val.trim().isEmpty ? 'Subject is required' : null,
              ),
              const SizedBox(height: 14),

              // Detailed Message Field
              _fieldLabel('Detailed Description *'),
              TextFormField(
                controller: _messageController,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                decoration: _fieldDecoration(hint: 'Provide context, steps, or observations'),
                validator: (val) =>
                    val == null || val.trim().isEmpty ? 'Message is required' : null,
              ),
              const SizedBox(height: 22),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppPalette.primaryGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Transmit Request',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        label,
        style: const TextStyle(
          color: AppPalette.textMuted,
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  InputDecoration _fieldDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppPalette.textMuted, fontSize: 13),
      filled: true,
      fillColor: AppPalette.canvas,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppPalette.borderLight),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppPalette.borderLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppPalette.primaryGreen, width: 1.5),
      ),
    );
  }
}

