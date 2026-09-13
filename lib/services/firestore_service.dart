import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/case_model.dart';

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

      // Ensure fallback members matching the blueprint if Firestore has few users
      if (members.isEmpty) {
        return const [
          TeamMemberModel(id: 'tm_1', name: 'Michael Scott', role: 'Associate Lawyer'),
          TeamMemberModel(id: 'tm_2', name: 'Sarah Connor', role: 'Senior Lawyer'),
          TeamMemberModel(id: 'tm_3', name: 'John Anderson', role: 'Partner'),
          TeamMemberModel(id: 'tm_4', name: 'Jessica Pearson', role: 'Senior Partner'),
        ];
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
  }) async {
    try {
      String? uid = _auth.currentUser?.uid;
      if (uid == null) {
        debugPrint("User not logged in");
        return null;
      }

      DocumentReference doc = await _db.collection('cases').add({
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
        if (nextHearingDate != null)
          'nextHearingDate': Timestamp.fromDate(nextHearingDate),
        'createdAt': FieldValue.serverTimestamp(),
        'lastUpdated': FieldValue.serverTimestamp(),
      });

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
}
