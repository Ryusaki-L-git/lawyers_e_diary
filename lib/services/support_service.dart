import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/support_ticket_model.dart';

/// Dedicated singleton service for Help & Support in Lawyer's E-Diary.
/// Uses path-isolated persistence: `support_requests/{userId}/tickets/{ticketId}`.
class SupportService {
  SupportService._();
  static final SupportService instance = SupportService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  /// Stream tickets submitted by the authenticated user.
  Stream<List<SupportTicketModel>> watchMyTickets() {
    final uid = currentUserId;
    if (uid == null) return Stream.value([]);

    return _db
        .collection('support_requests')
        .doc(uid)
        .collection('tickets')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => SupportTicketModel.fromFirestore(doc))
          .toList();
    });
  }

  /// Submit a new support request ticket.
  /// Initial status is strictly set to 'pending'.
  Future<String?> submitSupportTicket({
    required String type,
    required String category,
    required String subject,
    required String message,
  }) async {
    final uid = currentUserId;
    if (uid == null) {
      debugPrint('SupportService.submitSupportTicket: No user authenticated');
      return null;
    }

    try {
      final docRef = await _db
          .collection('support_requests')
          .doc(uid)
          .collection('tickets')
          .add({
        'userId': uid,
        'type': type.trim(),
        'category': category.trim(),
        'subject': subject.trim(),
        'message': message.trim(),
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });
      return docRef.id;
    } catch (e) {
      debugPrint('SupportService.submitSupportTicket error: $e');
      return null;
    }
  }
}

