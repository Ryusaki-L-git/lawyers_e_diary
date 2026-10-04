import 'package:flutter/material.dart';

/// Upgrade Prompt Screen — shown when a free-tier user taps "Upgrade to Cloud".
/// Beautiful full-page CTA that lists Cloud Subscriber benefits.
class UpgradePromptScreen extends StatelessWidget {
  const UpgradePromptScreen({super.key});

  static const Color _bg = Color(0xFFF7F5F2);
  static const Color _card = Color(0xFFFFFFFF);
  static const Color _green = Color(0xFF1F3D2B);
  static const Color _gold = Color(0xFFCCA046);
  static const Color _muted = Color(0xFF6B665E);
  static const Color _dark = Color(0xFF1A1A1A);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              children: [
                // ── Header ───────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 10, 14, 8),
                  child: Row(
                    children: [
                      IconButton(
                        tooltip: 'Back',
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.arrow_back_rounded,
                          size: 23,
                          color: _dark,
                        ),
                      ),
                      const Expanded(
                        child: Text(
                          'Upgrade Plan',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'serif',
                            fontSize: 21,
                            fontWeight: FontWeight.w700,
                            color: _dark,
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),
                const Divider(height: 1, thickness: 0.5, color: Color(0xFFE5DFD7)),

                // ── Body ─────────────────────────────────────────────────
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Hero badge
                        Center(
                          child: Container(
                            width: 88,
                            height: 88,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF1F3D2B), Color(0xFF2D6142)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF1F3D2B).withValues(alpha: 0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.cloud_done_rounded,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Title
                        const Text(
                          'Lawyer\'s E-Diary\nCloud Subscriber',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'serif',
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            color: _dark,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Unlock the full power of your digital docket.\nSync, backup, and collaborate from anywhere.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: _muted,
                            height: 1.55,
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Feature list card
                        Container(
                          decoration: BoxDecoration(
                            color: _card,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: const Color(0xFFE5DFD7)),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x0A000000),
                                blurRadius: 12,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              _Feature(
                                icon: Icons.cloud_sync_rounded,
                                color: _green,
                                title: 'Real-Time Cloud Sync',
                                subtitle:
                                    'All cases, reminders, and fees automatically backed up to Firestore.',
                              ),
                              _divider(),
                              _Feature(
                                icon: Icons.groups_2_rounded,
                                color: const Color(0xFF6750A4),
                                title: 'Team Collaboration',
                                subtitle:
                                    'Invite co-counsel, assign cases, and chat in real-time with your team.',
                              ),
                              _divider(),
                              _Feature(
                                icon: Icons.lock_person_rounded,
                                color: const Color(0xFF00604E),
                                title: 'Secure Cloud Storage',
                                subtitle:
                                    'Documents and attachments stored with Firebase Storage encryption.',
                              ),
                              _divider(),
                              _Feature(
                                icon: Icons.history_rounded,
                                color: _gold,
                                title: 'Full Audit & Activity Log',
                                subtitle:
                                    'Track every change, assignment, and deletion across your practice.',
                              ),
                              _divider(),
                              _Feature(
                                icon: Icons.devices_rounded,
                                color: const Color(0xFFB36E00),
                                title: 'Multi-Device Access',
                                subtitle:
                                    'Access your docket from any device — phone, tablet, or desktop.',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Pricing badge
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFFF8E7), Color(0xFFFFF3D0)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: _gold.withValues(alpha: 0.4),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.workspace_premium_rounded,
                                  color: _gold, size: 32),
                              const SizedBox(width: 14),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Cloud Subscriber',
                                      style: TextStyle(
                                        color: Color(0xFF7A4E00),
                                        fontWeight: FontWeight.w800,
                                        fontSize: 15,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      'Contact your administrator to activate',
                                      style: TextStyle(
                                        color: Color(0xFF946200),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),

                        // CTA button
                        SizedBox(
                          height: 52,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              // Contact admin / initiate upgrade flow
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text(
                                    'Contact your administrator to upgrade to Cloud Subscriber.',
                                  ),
                                  backgroundColor: _green,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  margin: const EdgeInsets.fromLTRB(18, 0, 18, 12),
                                  duration: const Duration(seconds: 4),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _green,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            icon: const Icon(Icons.cloud_upload_rounded),
                            label: const Text(
                              'Request Cloud Upgrade',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            'Maybe Later',
                            style: TextStyle(color: _muted),
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
    );
  }

  Widget _divider() =>
      const Divider(height: 1, thickness: 0.5, color: Color(0xFFE5DFD7), indent: 60);
}

class _Feature extends StatelessWidget {
  const _Feature({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF1A1A1A),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF6B665E),
                    fontSize: 12.5,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

