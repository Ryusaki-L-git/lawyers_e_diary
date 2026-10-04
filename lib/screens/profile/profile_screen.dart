import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../services/subscription_service.dart';
import '../../widgets/app_bottom_navigation.dart';
import '../../widgets/app_nav_controller.dart';
import '../../widgets/app_palette.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid;

    return Scaffold(
      backgroundColor: AppPalette.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Profile & Settings',
          style: TextStyle(
            color: AppPalette.ink,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          if (uid != null)
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: AppPalette.teal),
              tooltip: 'Edit Profile',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const EditProfileScreen(),
                  ),
                );
              },
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: uid == null
          ? const Center(
              child: Text(
                'No user signed in',
                style: TextStyle(color: AppPalette.mutedInk),
              ),
            )
          : StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final userData = snapshot.data?.data() ?? {};
                final name = userData['name'] as String? ??
                    user?.displayName ??
                    'Advocate';
                final email = userData['email'] as String? ??
                    user?.email ??
                    'No email available';
                final phone = userData['phone'] as String? ?? 'Not added';
                final ledId = userData['ledId'] as String? ?? 'LED-2026';
                final advocateType =
                    userData['advocateType'] as String? ?? 'General Practice';
                final degrees = userData['degrees'] as String? ?? 'LL.B.';
                final address = userData['address'] as String? ??
                    userData['officeAddress'] as String? ??
                    'Not added';
                final courtAddress =
                    userData['courtAddress'] as String? ?? 'Not added';

                return ListView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                  children: [
                    // Header card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppPalette.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppPalette.border),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x0D000000),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: AppPalette.teal.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppPalette.teal.withValues(alpha: 0.3),
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Icons.person_rounded,
                              color: AppPalette.teal,
                              size: 36,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: const TextStyle(
                                    color: AppPalette.ink,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  email,
                                  style: const TextStyle(
                                    color: AppPalette.mutedInk,
                                    fontSize: 13,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppPalette.gold.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'ID: $ledId',
                                    style: const TextStyle(
                                      color: Color(0xFF946200),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                    const _SectionHeader('Professional Credentials'),
                    const SizedBox(height: 8),
                    _InfoCard(
                      items: [
                        _InfoItem(
                          icon: Icons.workspace_premium_outlined,
                          title: 'Advocate Type',
                          value: advocateType,
                        ),
                        _InfoItem(
                          icon: Icons.school_outlined,
                          title: 'Qualifications / Degrees',
                          value: degrees,
                        ),
                        _InfoItem(
                          icon: Icons.phone_outlined,
                          title: 'Contact Phone',
                          value: phone,
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),
                    const _SectionHeader('Chamber & Court Practice'),
                    const SizedBox(height: 8),
                    _InfoCard(
                      items: [
                        _InfoItem(
                          icon: Icons.business_outlined,
                          title: 'Office / Chamber Address',
                          value: address,
                        ),
                        _InfoItem(
                          icon: Icons.gavel_outlined,
                          title: 'Court / Bar Address',
                          value: courtAddress,
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // ── Subscription Status ──────────────────────────────
                    StreamBuilder<SubscriptionInfo>(
                      stream: SubscriptionService.instance.watchSubscription(),
                      builder: (ctx, subSnap) {
                        final sub = subSnap.data ?? SubscriptionInfo.defaultFree;
                        return GestureDetector(
                          onTap: () => Navigator.of(context)
                              .pushNamed(sub.isCloud ? '/cloud_storage' : '/upgrade'),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: sub.isCloud
                                  ? const LinearGradient(
                                      colors: [
                                        Color(0xFF1F3D2B),
                                        Color(0xFF2D6142)
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    )
                                  : null,
                              color: sub.isFree ? const Color(0xFFFFF8E7) : null,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: sub.isCloud
                                    ? const Color(0xFF2D6142)
                                    : const Color(0xFFCCA046)
                                        .withValues(alpha: 0.4),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  sub.isCloud
                                      ? Icons.cloud_done_rounded
                                      : Icons.workspace_premium_outlined,
                                  color: sub.isCloud
                                      ? Colors.white
                                      : const Color(0xFFCCA046),
                                  size: 28,
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        sub.isCloud
                                            ? 'Cloud Subscriber'
                                            : 'Free Tier',
                                        style: TextStyle(
                                          color: sub.isCloud
                                              ? Colors.white
                                              : const Color(0xFF7A4E00),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        sub.isCloud
                                            ? 'Data backed up · ${sub.storageUsedFormatted} used'
                                            : 'Tap to upgrade & unlock cloud features',
                                        style: TextStyle(
                                          color: sub.isCloud
                                              ? const Color(0xFFB8D4C0)
                                              : const Color(0xFF946200),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.chevron_right_rounded,
                                  color: sub.isCloud
                                      ? Colors.white.withValues(alpha: 0.7)
                                      : const Color(0xFF946200),
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 24),
                    const _SectionHeader('Account & Quick Services'),
                    const SizedBox(height: 8),
                    _ActionCard(
                      tiles: [
                        _ActionTile(
                          icon: Icons.star_rounded,
                          title: 'Starred Cases',
                          subtitle: 'View your pinned priority matters',
                          color: AppPalette.gold,
                          onTap: () => Navigator.of(context).pushNamed('/starred'),
                        ),
                        _ActionTile(
                          icon: Icons.notifications_active_outlined,
                          title: 'Reminders',
                          subtitle: 'Court alerts and follow-ups',
                          color: AppPalette.teal,
                          onTap: () => Navigator.of(context).pushNamed('/reminders'),
                        ),
                        _ActionTile(
                          icon: Icons.calculate_outlined,
                          title: 'Fee Calculator',
                          subtitle: 'Track quotes, receipts and dues',
                          color: const Color(0xFF2C6B56),
                          onTap: () => Navigator.of(context).pushNamed('/fee'),
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),
                    ElevatedButton.icon(
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            backgroundColor: AppPalette.surface,
                            title: const Text('Sign Out'),
                            content: const Text(
                              'Are you sure you want to sign out from Lawyer\'s E-Diary?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppPalette.unread,
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: () => Navigator.pop(ctx, true),
                                child: const Text('Sign Out'),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true && context.mounted) {
                          await FirebaseAuth.instance.signOut();
                          if (context.mounted) {
                            Navigator.of(context).pushNamedAndRemoveUntil(
                              '/login',
                              (route) => false,
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppPalette.unread.withValues(alpha: 0.1),
                        foregroundColor: AppPalette.unread,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: BorderSide(
                            color: AppPalette.unread.withValues(alpha: 0.3),
                          ),
                        ),
                      ),
                      icon: const Icon(Icons.logout_rounded),
                      label: const Text(
                        'Sign Out',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                );
              },
            ),
      bottomNavigationBar: const AppBottomNavigation(
        currentIndex: 4,
        mode: NavMode.home,
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: AppPalette.mutedInk,
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.items});
  final List<_InfoItem> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppPalette.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppPalette.border),
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final isLast = entry.key == items.length - 1;
          final item = entry.value;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppPalette.background,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(item.icon, color: AppPalette.teal, size: 20),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: const TextStyle(
                              color: AppPalette.mutedInk,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.value,
                            style: const TextStyle(
                              color: AppPalette.ink,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (!isLast)
                const Divider(height: 1, indent: 64, color: AppPalette.border),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _InfoItem {
  const _InfoItem({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({required this.tiles});
  final List<_ActionTile> tiles;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppPalette.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppPalette.border),
      ),
      child: Column(
        children: tiles.asMap().entries.map((entry) {
          final isLast = entry.key == tiles.length - 1;
          final tile = entry.value;
          return Column(
            children: [
              ListTile(
                onTap: tile.onTap,
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: tile.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(tile.icon, color: tile.color, size: 20),
                ),
                title: Text(
                  tile.title,
                  style: const TextStyle(
                    color: AppPalette.ink,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  tile.subtitle,
                  style: const TextStyle(
                    color: AppPalette.mutedInk,
                    fontSize: 12,
                  ),
                ),
                trailing: const Icon(
                  Icons.chevron_right_rounded,
                  color: AppPalette.mutedInk,
                  size: 20,
                ),
              ),
              if (!isLast)
                const Divider(height: 1, indent: 64, color: AppPalette.border),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _ActionTile {
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
}
