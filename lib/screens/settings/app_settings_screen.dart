import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../services/subscription_service.dart';
import '../../widgets/app_bottom_navigation.dart';
import '../../widgets/app_nav_controller.dart';
import '../profile/edit_profile_screen.dart';
import '../profile/account_security_screen.dart';
import 'cloud_storage_screen.dart';
import 'upgrade_prompt_screen.dart';

/// Unified App Settings screen — Cloud/Non-Cloud aware.
/// Sections: Subscription Status, Account, Preferences, Data & Sync, About.
class AppSettingsScreen extends StatelessWidget {
  const AppSettingsScreen({super.key});

  static const Color _bg = Color(0xFFF7F5F2);
  static const Color _green = Color(0xFF1F3D2B);
  static const Color _gold = Color(0xFFCCA046);
  static const Color _muted = Color(0xFF6B665E);
  static const Color _dark = Color(0xFF1A1A1A);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Settings',
          style: TextStyle(
            color: _dark,
            fontFamily: 'serif',
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Back',
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close_rounded, color: _dark, size: 22),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: StreamBuilder<SubscriptionInfo>(
        stream: SubscriptionService.instance.watchSubscription(),
        builder: (context, snapshot) {
          final sub = snapshot.data ?? SubscriptionInfo.defaultFree;

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            children: [
              // ── Subscription Tier Banner ─────────────────────────────
              _SubscriptionBanner(sub: sub),
              const SizedBox(height: 24),

              // ── Account Section ──────────────────────────────────────
              _SectionLabel('Account'),
              const SizedBox(height: 8),
              _SettingsCard(
                tiles: [
                  _SettingsTile(
                    icon: Icons.person_outline_rounded,
                    iconColor: _green,
                    title: 'Edit Profile',
                    subtitle: 'Name, qualifications, chamber address',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const EditProfileScreen()),
                    ),
                  ),
                  _SettingsTile(
                    icon: Icons.lock_outline_rounded,
                    iconColor: const Color(0xFF6750A4),
                    title: 'Account Security',
                    subtitle: 'Password reset, sign-in options',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const AccountSecurityScreen()),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ── Cloud & Sync Section ─────────────────────────────────
              _SectionLabel('Cloud & Data'),
              const SizedBox(height: 8),
              _SettingsCard(
                tiles: [
                  _SettingsTile(
                    icon: Icons.cloud_sync_rounded,
                    iconColor: sub.isCloud ? _green : _muted,
                    title: 'Cloud Storage & Sync',
                    subtitle: sub.isCloud
                        ? 'Connected · ${sub.storageUsedFormatted} used'
                        : 'Not enabled · Upgrade to activate',
                    trailing: sub.isCloud
                        ? const _CloudBadge(label: 'ON', color: Color(0xFF1F3D2B))
                        : const _CloudBadge(label: 'OFF', color: Color(0xFF6B665E)),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const CloudStorageScreen()),
                    ),
                  ),
                  if (sub.isFree)
                    _SettingsTile(
                      icon: Icons.workspace_premium_rounded,
                      iconColor: _gold,
                      title: 'Upgrade to Cloud',
                      subtitle: 'Sync, teams, backup & more',
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                          color: _gold.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'UPGRADE',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF7A4E00),
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const UpgradePromptScreen()),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 24),

              // ── Navigation Shortcuts ─────────────────────────────────
              _SectionLabel('Quick Navigation'),
              const SizedBox(height: 8),
              _SettingsCard(
                tiles: [
                  _SettingsTile(
                    icon: Icons.star_rounded,
                    iconColor: _gold,
                    title: 'Starred Cases',
                    subtitle: 'Your priority matters at a glance',
                    onTap: () => Navigator.of(context).pushNamed('/starred'),
                  ),
                  _SettingsTile(
                    icon: Icons.notifications_active_outlined,
                    iconColor: const Color(0xFF00604E),
                    title: 'Reminders',
                    subtitle: 'Court alerts and follow-ups',
                    onTap: () =>
                        Navigator.of(context).pushNamed('/reminders'),
                  ),
                  _SettingsTile(
                    icon: Icons.calculate_outlined,
                    iconColor: const Color(0xFF2C6B56),
                    title: 'Fee Calculator',
                    subtitle: 'Quotes, receipts, and dues',
                    onTap: () => Navigator.of(context).pushNamed('/fee'),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ── About Section ────────────────────────────────────────
              _SectionLabel('About'),
              const SizedBox(height: 8),
              _SettingsCard(
                tiles: [
                  _SettingsTile(
                    icon: Icons.info_outline_rounded,
                    iconColor: _muted,
                    title: 'App Version',
                    subtitle: 'Lawyer\'s E-Diary v1.0.0',
                    onTap: null,
                  ),
                  _SettingsTile(
                    icon: Icons.privacy_tip_outlined,
                    iconColor: _muted,
                    title: 'Privacy Policy',
                    subtitle: 'How we handle your data',
                    onTap: null,
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // ── Sign Out ─────────────────────────────────────────────
              SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
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
                              backgroundColor: const Color(0xFFB3261E),
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
                        Navigator.of(context)
                            .pushNamedAndRemoveUntil('/login', (_) => false);
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(0xFFB3261E).withValues(alpha: 0.08),
                    foregroundColor: const Color(0xFFB3261E),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(
                          color: const Color(0xFFB3261E)
                              .withValues(alpha: 0.25)),
                    ),
                  ),
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text(
                    'Sign Out',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: const AppBottomNavigation(
        mode: NavMode.home,
        currentIndex: 4,
      ),
    );
  }
}

// ── Subscription Banner ────────────────────────────────────────────────────

class _SubscriptionBanner extends StatelessWidget {
  const _SubscriptionBanner({required this.sub});
  final SubscriptionInfo sub;

  @override
  Widget build(BuildContext context) {
    if (sub.isCloud) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1F3D2B), Color(0xFF2D6142)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const Icon(Icons.cloud_done_rounded,
                color: Colors.white, size: 30),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cloud Subscriber',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Your data is synced and backed up.',
                    style: TextStyle(
                      color: Color(0xFFB8D4C0),
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'ACTIVE',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Free tier
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const UpgradePromptScreen()),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF8E7),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: const Color(0xFFCCA046).withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            const Icon(Icons.workspace_premium_outlined,
                color: Color(0xFFCCA046), size: 28),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Free Tier',
                    style: TextStyle(
                      color: Color(0xFF7A4E00),
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Tap to unlock Cloud features →',
                    style: TextStyle(
                      color: Color(0xFF946200),
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Section Label ──────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: Color(0xFF6B665E),
        letterSpacing: 0.8,
      ),
    );
  }
}

// ── Settings Card ──────────────────────────────────────────────────────────

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.tiles});
  final List<_SettingsTile> tiles;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5DFD7)),
      ),
      child: Column(
        children: tiles.asMap().entries.map((entry) {
          final isLast = entry.key == tiles.length - 1;
          final tile = entry.value;
          return Column(
            children: [
              ListTile(
                onTap: tile.onTap,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: tile.iconColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(tile.icon, color: tile.iconColor, size: 20),
                ),
                title: Text(
                  tile.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: tile.onTap == null
                        ? const Color(0xFF6B665E)
                        : const Color(0xFF1A1A1A),
                  ),
                ),
                subtitle: Text(
                  tile.subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B665E),
                  ),
                ),
                trailing: tile.trailing ??
                    (tile.onTap != null
                        ? const Icon(Icons.chevron_right_rounded,
                            color: Color(0xFF6B665E), size: 20)
                        : null),
              ),
              if (!isLast)
                const Divider(
                    height: 1,
                    thickness: 0.5,
                    indent: 64,
                    color: Color(0xFFE5DFD7)),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _SettingsTile {
  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.trailing,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;
}

// ── Cloud Status Badge ─────────────────────────────────────────────────────

class _CloudBadge extends StatelessWidget {
  const _CloudBadge({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          color: color,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

