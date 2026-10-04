import 'package:flutter/material.dart';

import '../../services/subscription_service.dart';
import 'upgrade_prompt_screen.dart';

/// Cloud Storage & Sync Status Screen.
/// Shows tier, storage used, last sync time, and manual sync option.
/// Free users see an upgrade prompt banner at the top.
class CloudStorageScreen extends StatefulWidget {
  const CloudStorageScreen({super.key});

  @override
  State<CloudStorageScreen> createState() => _CloudStorageScreenState();
}

class _CloudStorageScreenState extends State<CloudStorageScreen> {
  bool _isSyncing = false;

  static const Color _bg = Color(0xFFF7F5F2);
  static const Color _green = Color(0xFF1F3D2B);
  static const Color _muted = Color(0xFF6B665E);
  static const Color _dark = Color(0xFF1A1A1A);

  Future<void> _triggerSync(SubscriptionInfo sub) async {
    if (!sub.isCloud) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const UpgradePromptScreen()),
      );
      return;
    }
    setState(() => _isSyncing = true);
    await SubscriptionService.instance.recordSync();
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      setState(() => _isSyncing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Cloud sync complete.'),
          backgroundColor: _green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.fromLTRB(18, 0, 18, 12),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: StreamBuilder<SubscriptionInfo>(
              stream: SubscriptionService.instance.watchSubscription(),
              builder: (context, snapshot) {
                final sub = snapshot.data ?? SubscriptionInfo.defaultFree;
                return Column(
                  children: [
                    // ── Header ──────────────────────────────────────────
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
                              'Cloud & Sync',
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
                    const Divider(
                        height: 1, thickness: 0.5, color: Color(0xFFE5DFD7)),

                    // ── Body ────────────────────────────────────────────
                    Expanded(
                      child: ListView(
                        padding:
                            const EdgeInsets.fromLTRB(20, 20, 20, 32),
                        children: [
                          // Free tier upgrade banner
                          if (sub.isFree) ...[
                            _UpgradeBanner(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        const UpgradePromptScreen()),
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],

                          // Tier status card
                          _StatusCard(sub: sub),
                          const SizedBox(height: 20),

                          // Storage bar card
                          _StorageCard(sub: sub),
                          const SizedBox(height: 20),

                          // Sync card
                          _SyncCard(
                            sub: sub,
                            isSyncing: _isSyncing,
                            onSync: () => _triggerSync(sub),
                          ),
                          const SizedBox(height: 20),

                          // Info section
                          _infoSection(sub),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoSection(SubscriptionInfo sub) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _green.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _green.withValues(alpha: 0.12)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: _green, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              sub.isCloud
                  ? 'Your data is continuously synced to Firestore. '
                      'All cases, reminders, and fees are securely backed up in real-time.'
                  : 'Upgrade to Cloud Subscriber to enable real-time backup, '
                      'multi-device access, and team collaboration.',
              style: const TextStyle(
                fontSize: 12.5,
                color: _muted,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Upgrade Banner ─────────────────────────────────────────────────────────

class _UpgradeBanner extends StatelessWidget {
  const _UpgradeBanner({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1F3D2B), Color(0xFF2D6142)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1F3D2B).withValues(alpha: 0.25),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.workspace_premium_rounded,
                color: Color(0xFFCCA046), size: 32),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'You\'re on Free Tier',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Upgrade to unlock cloud sync, teams & backup →',
                    style: TextStyle(
                      color: Color(0xFFB8D4C0),
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

// ── Status Card ────────────────────────────────────────────────────────────

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.sub});
  final SubscriptionInfo sub;

  @override
  Widget build(BuildContext context) {
    final isCloud = sub.isCloud;
    final tierColor = isCloud ? const Color(0xFF1F3D2B) : const Color(0xFF6B665E);
    final tierLabel = isCloud ? 'Cloud Subscriber' : 'Free Tier';
    final tierIcon =
        isCloud ? Icons.cloud_done_rounded : Icons.cloud_off_rounded;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5DFD7)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: tierColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(tierIcon, color: tierColor, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Subscription Tier',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF6B665E),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tierLabel,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: tierColor,
                  ),
                ),
                if (isCloud && sub.expiresAt != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Expires: ${_fmtDate(sub.expiresAt!)}',
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: Color(0xFF6B665E),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: isCloud
                  ? const Color(0xFF1F3D2B).withValues(alpha: 0.08)
                  : const Color(0xFF6B665E).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              isCloud ? 'ACTIVE' : 'FREE',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: tierColor,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}

// ── Storage Bar Card ───────────────────────────────────────────────────────

class _StorageCard extends StatelessWidget {
  const _StorageCard({required this.sub});
  final SubscriptionInfo sub;

  static const int _maxFreeBytes = 50 * 1024 * 1024; // 50 MB for free
  static const int _maxCloudBytes = 5 * 1024 * 1024 * 1024; // 5 GB for cloud

  @override
  Widget build(BuildContext context) {
    final maxBytes = sub.isCloud ? _maxCloudBytes : _maxFreeBytes;
    final maxLabel = sub.isCloud ? '5 GB' : '50 MB';
    final fraction = (sub.storageUsedBytes / maxBytes).clamp(0.0, 1.0);
    final barColor = fraction > 0.85
        ? const Color(0xFFB3261E)
        : sub.isCloud
            ? const Color(0xFF1F3D2B)
            : const Color(0xFFCCA046);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5DFD7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.storage_rounded,
                  color: Color(0xFF1F3D2B), size: 20),
              const SizedBox(width: 10),
              const Text(
                'Storage Used',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const Spacer(),
              Text(
                '${sub.storageUsedFormatted} / $maxLabel',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6B665E),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: fraction,
              minHeight: 8,
              backgroundColor: const Color(0xFFE5DFD7),
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            fraction == 0
                ? 'No data stored yet.'
                : '${(fraction * 100).toStringAsFixed(1)}% of your quota used.',
            style: const TextStyle(fontSize: 11.5, color: Color(0xFF6B665E)),
          ),
        ],
      ),
    );
  }
}

// ── Sync Card ──────────────────────────────────────────────────────────────

class _SyncCard extends StatelessWidget {
  const _SyncCard({
    required this.sub,
    required this.isSyncing,
    required this.onSync,
  });

  final SubscriptionInfo sub;
  final bool isSyncing;
  final VoidCallback onSync;

  @override
  Widget build(BuildContext context) {
    final lastSync = sub.lastSyncedAt;
    final lastSyncLabel = lastSync == null
        ? 'Never synced'
        : _timeAgo(lastSync);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5DFD7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.sync_rounded,
                  color: Color(0xFF1F3D2B), size: 20),
              const SizedBox(width: 10),
              const Text(
                'Cloud Sync',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const Spacer(),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: sub.isCloud
                      ? const Color(0xFF2D6142)
                      : const Color(0xFF6B665E),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                sub.isCloud ? 'Connected' : 'Offline',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: sub.isCloud
                      ? const Color(0xFF2D6142)
                      : const Color(0xFF6B665E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Last sync: $lastSyncLabel',
            style: const TextStyle(
              fontSize: 12.5,
              color: Color(0xFF6B665E),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton.icon(
              onPressed: isSyncing ? null : onSync,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1F3D2B),
                foregroundColor: Colors.white,
                disabledBackgroundColor:
                    const Color(0xFF1F3D2B).withValues(alpha: 0.4),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: isSyncing
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.cloud_sync_rounded, size: 18),
              label: Text(
                isSyncing ? 'Syncing…' : (sub.isCloud ? 'Sync Now' : 'Enable Cloud Sync'),
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

