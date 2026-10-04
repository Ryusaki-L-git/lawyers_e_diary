import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/case_model.dart';
import '../models/fee_model.dart';
import '../models/reminder_model.dart';

class CaseStats {
  const CaseStats({
    this.total = 0,
    this.active = 0,
    this.completed = 0,
    this.deleted = 0,
  });

  final int total;
  final int active;
  final int completed;
  final int deleted;
}

class TeamMemberModel {
  const TeamMemberModel({
    required this.id,
    required this.name,
    required this.role,
    this.email,
  });

  final String id;
  final String name;
  final String role;
  final String? email;
}

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  /// Stream cases with Firestore query filters and controlled client refinement
  /// to avoid Firestore unindexed composite query errors.
  Stream<List<CaseModel>> watchCases({
    String? status, // 'all', 'active', 'upcoming', 'urgent', 'completed', 'deleted'
    String? caseType,
    String? handledBy,
    String? searchQuery,
    String? sortBy, // 'nextHearing', 'title', 'created'
    DateTime? specificDate,
    DateTimeRange? dateRange,
    int limit = 50,
  }) {
    Query<Map<String, dynamic>> query = _db.collection('cases');

    // Primary Firestore query constraints on indexed field
    if (status != null && status.isNotEmpty && status.toLowerCase() != 'all') {
      query = query.where('status', isEqualTo: status.toLowerCase());
    }

    return query.limit(limit).snapshots().map((snapshot) {
      var list = snapshot.docs.map((d) => CaseModel.fromFirestore(d)).toList();

      // If status wasn't explicitly requested as deleted, filter out deleted dockets
      if (status == null || (status.toLowerCase() != 'deleted' && status.toLowerCase() != 'all')) {
        list = list.where((c) => !c.isDeleted).toList();
      }

      // Case type filter
      if (caseType != null && caseType.isNotEmpty && caseType.toLowerCase() != 'all') {
        list = list.where((c) => c.caseType.toLowerCase().contains(caseType.toLowerCase())).toList();
      }

      // Handled by / Team member filter
      if (handledBy != null && handledBy.isNotEmpty && handledBy.toLowerCase() != 'all') {
        list = list.where((c) => c.handledBy.toLowerCase().contains(handledBy.toLowerCase())).toList();
      }

      // Specific single date filter (e.g. Cause List)
      if (specificDate != null) {
        list = list.where((c) {
          if (c.nextHearingDate == null) return false;
          final d = c.nextHearingDate!;
          return d.year == specificDate.year &&
              d.month == specificDate.month &&
              d.day == specificDate.day;
        }).toList();
      }

      // Date range filter
      if (dateRange != null) {
        list = list.where((c) {
          if (c.nextHearingDate == null) return false;
          final d = c.nextHearingDate!;
          return !d.isBefore(dateRange.start) && !d.isAfter(dateRange.end);
        }).toList();
      }

      // Text search filter (matches case title, client name, or case number)
      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        final q = searchQuery.trim().toLowerCase();
        list = list.where((c) {
          return c.caseTitle.toLowerCase().contains(q) ||
              c.clientName.toLowerCase().contains(q) ||
              c.caseNumber.toLowerCase().contains(q);
        }).toList();
      }

      // Client-side sorting
      if (sortBy == 'title') {
        list.sort((a, b) => a.caseTitle.compareTo(b.caseTitle));
      } else if (sortBy == 'created') {
        list.sort((a, b) {
          final aDate = a.createdAt ?? DateTime(2020);
          final bDate = b.createdAt ?? DateTime(2020);
          return bDate.compareTo(aDate);
        });
      } else {
        // Default: Next Hearing Date ascending
        list.sort((a, b) {
          if (a.nextHearingDate == null && b.nextHearingDate == null) return 0;
          if (a.nextHearingDate == null) return 1;
          if (b.nextHearingDate == null) return -1;
          return a.nextHearingDate!.compareTo(b.nextHearingDate!);
        });
      }

      return list;
    });
  }

  /// Live stream for Case Management statistics cards.
  Stream<CaseStats> watchCaseStats() {
    return _db.collection('cases').snapshots().map((snapshot) {
      int total = 0;
      int active = 0;
      int completed = 0;
      int deleted = 0;

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final status = (data['status'] as String? ?? 'active').toLowerCase();
        if (status == 'deleted') {
          deleted++;
        } else {
          total++;
          if (status == 'completed') {
            completed++;
          } else {
            active++;
          }
        }
      }

      return CaseStats(
        total: total,
        active: active,
        completed: completed,
        deleted: deleted,
      );
    });
  }

  /// Soft deletes a case into the Deleted Cases bin.
  Future<void> softDeleteCase(String caseId) async {
    try {
      await _db.collection('cases').doc(caseId).update({
        'status': 'deleted',
        'deletedAt': FieldValue.serverTimestamp(),
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error soft deleting case: $e');
    }
  }

  /// Restores a deleted case back to active status.
  Future<void> restoreCase(String caseId) async {
    try {
      await _db.collection('cases').doc(caseId).update({
        'status': 'active',
        'deletedAt': FieldValue.delete(),
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error restoring case: $e');
    }
  }

  /// Transfers case ownership/handler to another lawyer.
  Future<void> transferCase({
    required String caseId,
    required String targetLawyerName,
    required String targetLawyerId,
  }) async {
    try {
      await _db.collection('cases').doc(caseId).update({
        'handledBy': targetLawyerName,
        'userId': targetLawyerId,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error transferring case: $e');
    }
  }

  /// Updates status of a case (e.g. 'completed', 'active', 'urgent').
  Future<void> updateCaseStatus(String caseId, String status) async {
    try {
      await _db.collection('cases').doc(caseId).update({
        'status': status.toLowerCase(),
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error updating case status: $e');
    }
  }

  /// Toggles star/pin status of a case.
  Future<void> toggleCaseStarred(String caseId, bool isStarred) async {
    try {
      await _db.collection('cases').doc(caseId).update({
        'isStarred': isStarred,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error toggling case starred: $e');
    }
  }

  /// Stream firm team members for the Cause List team switcher and transfer screen.
  Stream<List<TeamMemberModel>> getTeamMembers() {
    return _db.collection('users').snapshots().map((snapshot) {
      final members = <TeamMemberModel>[];
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final name = data['name'] as String? ?? 'Associate Lawyer';
        members.add(
          TeamMemberModel(
            id: doc.id,
            name: name,
            role: data['role'] as String? ?? 'Associate Advocate',
            email: data['email'] as String?,
          ),
        );
      }

      return members;
    });
  }

  /// ================================
  /// SAVE USER DATA (after signup)
  /// ================================
  Future<void> saveUserData({
    required String name,
    required String email,
    required String phone,
    required String courtAddress,
    required String officeAddress,
  }) async {
    try {
      String? uid = _auth.currentUser?.uid;
      if (uid == null) {
        debugPrint("User not logged in");
        return;
      }

      await _db.collection('users').doc(uid).set({
        'name': name,
        'email': email,
        'phone': phone,
        'courtAddress': courtAddress,
        'officeAddress': officeAddress,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint("Error saving user data: $e");
    }
  }

  /// ================================
  /// ADD NEW CASE (returns caseId)
  /// ================================
  Future<String?> addCase({
    required String caseTitle,
    required String clientName,
    required String courtName,
    required String cnrNumber,
    required String status,
    String? opponentName,
    String? caseType,
    DateTime? nextHearingDate,
    String? clientPhone,
    String? initialNote,
  }) async {
    try {
      String? uid = _auth.currentUser?.uid;
      if (uid == null) {
        debugPrint("User not logged in");
        return null;
      }

      final Map<String, dynamic> caseData = {
        'userId': uid,
        'caseTitle': caseTitle,
        'clientName': clientName,
        'courtName': courtName,
        'cnrNumber': cnrNumber,
        'status': status.toLowerCase(),
        'opponentName': opponentName ?? '',
        'caseType': caseType ?? 'Civil Case',
        'handledBy': _auth.currentUser?.displayName ?? 'Advocate',
        'clientPhone': clientPhone,
        'isStarred': false,
        'documents': <dynamic>[],
        'notes': (initialNote != null && initialNote.trim().isNotEmpty)
            ? <String>[initialNote.trim()]
            : <String>[],
        'createdAt': FieldValue.serverTimestamp(),
        'lastUpdated': FieldValue.serverTimestamp(),
      };

      if (nextHearingDate != null) {
        caseData['nextHearingDate'] = Timestamp.fromDate(nextHearingDate);
      }

      DocumentReference doc = await _db.collection('cases').add(caseData);

      return doc.id;
    } catch (e) {
      debugPrint("Error adding case: $e");
      return null;
    }
  }

  /// =======================================
  /// ADD NOTE INSIDE A CASE
  /// =======================================
  Future<void> addNote({
    required String caseId,
    required String text,
    required DateTime nextHearingDate,
  }) async {
    try {
      await _db.collection('cases').doc(caseId).collection('notes').add({
        'text': text,
        'date': FieldValue.serverTimestamp(),
        'nextHearingDate': Timestamp.fromDate(nextHearingDate),
      });
    } catch (e) {
      debugPrint("Error adding note: $e");
    }
  }

  // â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”
  // REMINDERS â€” Phase 1
  // â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”

  /// Live stream of all reminders for the current user, ordered by dueDateTime.
  /// Pass [showCompleted] = true to include completed reminders.
  Stream<List<ReminderModel>> watchReminders({bool showCompleted = false}) {
    final uid = currentUserId;
    if (uid == null) return const Stream.empty();

    Query<Map<String, dynamic>> query = _db
        .collection('reminders')
        .where('userId', isEqualTo: uid)
        .orderBy('dueDateTime');

    if (!showCompleted) {
      query = query.where('isCompleted', isEqualTo: false);
    }

    return query.snapshots().map(
          (snap) =>
              snap.docs.map((d) => ReminderModel.fromFirestore(d)).toList(),
        );
  }

  /// Adds a new reminder for the current user. Returns the new document ID.
  Future<String?> addReminder({
    required String title,
    required DateTime dueDateTime,
    String? description,
    String? caseId,
    String? caseTitle,
    String? clientName,
    ReminderRepeat repeatRule = ReminderRepeat.none,
  }) async {
    final uid = currentUserId;
    if (uid == null) {
      debugPrint('addReminder: No user signed in');
      return null;
    }
    try {
      final data = ReminderModel(
        id: '',
        userId: uid,
        title: title,
        dueDateTime: dueDateTime,
        description: description,
        caseId: caseId,
        caseTitle: caseTitle,
        clientName: clientName,
        repeatRule: repeatRule,
      ).toMap();

      final ref = await _db.collection('reminders').add(data);
      return ref.id;
    } catch (e) {
      debugPrint('Error adding reminder: $e');
      return null;
    }
  }

  /// Toggles the `isCompleted` field on a reminder.
  Future<void> toggleReminderDone(String reminderId, bool currentValue) async {
    try {
      await _db.collection('reminders').doc(reminderId).update({
        'isCompleted': !currentValue,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error toggling reminder: $e');
    }
  }

  /// Permanently deletes a reminder document.
  Future<void> deleteReminder(String reminderId) async {
    try {
      await _db.collection('reminders').doc(reminderId).delete();
    } catch (e) {
      debugPrint('Error deleting reminder: $e');
    }
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // FEE CALCULATOR — Phase 2
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// Live stream of all fee records for the current user, newest first.
  Stream<List<FeeModel>> watchFees() {
    final uid = currentUserId;
    if (uid == null) return const Stream.empty();

    return _db
        .collection('fees')
        .where('userId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => FeeModel.fromFirestore(d)).toList());
  }

  /// Creates a new fee record. Returns the new document ID.
  Future<String?> addFee({
    required String clientName,
    required String caseTitle,
    required List<FeeLineItem> services,
    String? caseId,
    double? agreedTotal,
    String? notes,
  }) async {
    final uid = currentUserId;
    if (uid == null) {
      debugPrint('addFee: No user signed in');
      return null;
    }
    try {
      final total = agreedTotal ?? services.fold<double>(0.0, (s, i) => s + i.subtotal);
      final ref = await _db.collection('fees').add(
        FeeModel(
          id: '',
          userId: uid,
          clientName: clientName,
          caseTitle: caseTitle,
          caseId: caseId,
          services: services,
          agreedTotal: total,
          notes: notes,
        ).toMap(),
      );
      return ref.id;
    } catch (e) {
      debugPrint('Error adding fee: $e');
      return null;
    }
  }

  /// Records a payment against a fee, updating collected total and status.
  Future<void> recordFeePayment({
    required String feeId,
    required double amount,
    required double newCollectedTotal,
    required double agreedTotal,
    String paymentMode = 'Cash',
    String? receiptNumber,
  }) async {
    try {
      final batch = _db.batch();
      final txRef = _db.collection('fees').doc(feeId).collection('transactions').doc();
      batch.set(txRef, {
        'amount': amount,
        'paymentDate': FieldValue.serverTimestamp(),
        'paymentMode': paymentMode,
        // ignore: use_null_aware_elements
        if (receiptNumber != null) 'receiptNumber': receiptNumber,
      });
      final newPending = (agreedTotal - newCollectedTotal).clamp(0.0, double.infinity);
      final newStatus = newPending <= 0 ? FeeStatus.settled.value : FeeStatus.partiallyPaid.value;
      batch.update(_db.collection('fees').doc(feeId), {
        'collectedTotal': newCollectedTotal,
        'pendingTotal': newPending,
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      await batch.commit();
    } catch (e) {
      debugPrint('Error recording fee payment: $e');
    }
  }

  /// Fetches all payment transactions for a specific fee.
  Future<List<FeeTransaction>> fetchFeeTransactions(String feeId) async {
    try {
      final snap = await _db
          .collection('fees')
          .doc(feeId)
          .collection('transactions')
          .orderBy('paymentDate', descending: true)
          .get();
      return snap.docs.map((d) => FeeTransaction.fromMap(d.id, d.data())).toList();
    } catch (e) {
      debugPrint('Error fetching fee transactions: $e');
      return [];
    }
  }

  /// Deletes a fee record and all its subcollection transactions.
  Future<void> deleteFee(String feeId) async {
    try {
      final txSnap = await _db.collection('fees').doc(feeId).collection('transactions').get();
      final batch = _db.batch();
      for (final doc in txSnap.docs) {
        batch.delete(doc.reference);
      }
      batch.delete(_db.collection('fees').doc(feeId));
      await batch.commit();
    } catch (e) {
      debugPrint('Error deleting fee: $e');
    }
  }
}
