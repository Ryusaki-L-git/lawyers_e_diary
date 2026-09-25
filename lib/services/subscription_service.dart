import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Subscription tiers for Lawyer's E-Diary.
enum SubscriptionTier { free, cloudSubscriber }

/// Lightweight model for a user's subscription state.
class SubscriptionInfo {
  const SubscriptionInfo({
    required this.tier,
    this.expiresAt,
    this.storageUsedBytes = 0,
    this.lastSyncedAt,
  });

  final SubscriptionTier tier;
  final DateTime? expiresAt;
  final int storageUsedBytes;
  final DateTime? lastSyncedAt;

  bool get isCloud => tier == SubscriptionTier.cloudSubscriber;
  bool get isFree => tier == SubscriptionTier.free;

  /// Storage used formatted as human-readable string (e.g. "2.4 MB").
  String get storageUsedFormatted {
    if (storageUsedBytes == 0) return '0 KB';
    if (storageUsedBytes < 1024) return '$storageUsedBytes B';
    if (storageUsedBytes < 1024 * 1024) {
      return '${(storageUsedBytes / 1024).toStringAsFixed(1)} KB';
    }
    if (storageUsedBytes < 1024 * 1024 * 1024) {
      return '${(storageUsedBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(storageUsedBytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  /// Parse from a Firestore document's data map.
  factory SubscriptionInfo.fromMap(Map<String, dynamic> data) {
    final subMap = data['subscription'] as Map<String, dynamic>?;
    if (subMap == null) return const SubscriptionInfo(tier: SubscriptionTier.free);

    final tierStr = subMap['tier'] as String? ?? 'free';
    final tier = tierStr == 'cloud_subscriber'
        ? SubscriptionTier.cloudSubscriber
        : SubscriptionTier.free;

    final expiryTs = subMap['expiry'] as Timestamp?;
    final lastSyncTs = subMap['lastSyncedAt'] as Timestamp?;

    return SubscriptionInfo(
      tier: tier,
      expiresAt: expiryTs?.toDate(),
      storageUsedBytes: (subMap['storageUsedBytes'] as int?) ?? 0,
      lastSyncedAt: lastSyncTs?.toDate(),
    );
  }

  /// Default free-tier info when user document is absent.
  static const SubscriptionInfo defaultFree =
      SubscriptionInfo(tier: SubscriptionTier.free);
}

/// Singleton service exposing the current user's subscription as a stream.
class SubscriptionService {
  SubscriptionService._();
  static final SubscriptionService instance = SubscriptionService._();

  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  /// Live stream of the current user's [SubscriptionInfo].
  /// Emits [SubscriptionInfo.defaultFree] when no user is signed in.
  Stream<SubscriptionInfo> watchSubscription() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      return Stream.value(SubscriptionInfo.defaultFree);
    }
    return _firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((snap) => snap.exists
            ? SubscriptionInfo.fromMap(snap.data()!)
            : SubscriptionInfo.defaultFree);
  }

  /// One-shot fetch (for non-reactive reads).
  Future<SubscriptionInfo> fetchSubscription() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return SubscriptionInfo.defaultFree;
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) return SubscriptionInfo.defaultFree;
    return SubscriptionInfo.fromMap(doc.data()!);
  }

  /// Update the last synced timestamp in Firestore.
  Future<void> recordSync() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    await _firestore.collection('users').doc(uid).set({
      'subscription': {
        'lastSyncedAt': FieldValue.serverTimestamp(),
      },
    }, SetOptions(merge: true));
  }
}

