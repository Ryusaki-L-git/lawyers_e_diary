import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/client_model.dart';

/// Dedicated singleton service for all Client entity operations in Lawyer's E-Diary.
class ClientService {
  ClientService._();
  static final ClientService instance = ClientService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  /// Stream of active clients for the signed-in user.
  /// Automatically filters out soft-deleted clients (`isDeleted == false`).
  Stream<List<ClientModel>> watchClients({
    String? searchQuery,
    String? typeFilter,
  }) {
    final uid = currentUserId;
    if (uid == null) return Stream.value([]);

    Query<Map<String, dynamic>> query = _db
        .collection('clients')
        .where('userId', isEqualTo: uid)
        .where('isDeleted', isEqualTo: false);

    return query.snapshots().map((snapshot) {
      var clients = snapshot.docs
          .map((doc) => ClientModel.fromFirestore(doc))
          .toList();

      // Client-side type filter
      if (typeFilter != null &&
          typeFilter.isNotEmpty &&
          typeFilter.toLowerCase() != 'all') {
        clients = clients
            .where((c) => c.type.toLowerCase() == typeFilter.toLowerCase())
            .toList();
      }

      // Client-side text search (matches name, phone, email, notes)
      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        final q = searchQuery.trim().toLowerCase();
        clients = clients.where((c) {
          final cleanPhone = c.phone.replaceAll(RegExp(r'[^0-9]'), '');
          return c.name.toLowerCase().contains(q) ||
              cleanPhone.contains(q) ||
              c.email.toLowerCase().contains(q) ||
              c.type.toLowerCase().contains(q);
        }).toList();
      }

      // Sort alphabetically by name
      clients.sort((a, b) =>
          a.name.toLowerCase().compareTo(b.name.toLowerCase()));

      return clients;
    });
  }

  /// Add a new client entity.
  Future<String?> addClient(ClientModel client) async {
    final uid = currentUserId;
    if (uid == null) {
      debugPrint('ClientService.addClient: No user authenticated');
      return null;
    }

    try {
      final docRef = await _db.collection('clients').add({
        'userId': uid,
        'name': client.name.trim(),
        'type': client.type.trim(),
        'phone': client.phone.trim(),
        'email': client.email.trim(),
        'address': client.address.trim(),
        'notes': client.notes.trim(),
        'isDeleted': false,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return docRef.id;
    } catch (e) {
      debugPrint('ClientService.addClient error: $e');
      return null;
    }
  }

  /// Update an existing client entity.
  Future<bool> updateClient(ClientModel client) async {
    try {
      await _db.collection('clients').doc(client.id).update({
        'name': client.name.trim(),
        'type': client.type.trim(),
        'phone': client.phone.trim(),
        'email': client.email.trim(),
        'address': client.address.trim(),
        'notes': client.notes.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      debugPrint('ClientService.updateClient error: $e');
      return false;
    }
  }

  /// Soft-delete (archive) a client entity.
  /// Preserves all legal records and historical integrity.
  Future<bool> deleteClient(String clientId) async {
    try {
      await _db.collection('clients').doc(clientId).update({
        'isDeleted': true,
        'deletedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      debugPrint('ClientService.deleteClient error: $e');
      return false;
    }
  }

  /// Restore an archived client entity back to active status.
  Future<bool> restoreClient(String clientId) async {
    try {
      await _db.collection('clients').doc(clientId).update({
        'isDeleted': false,
        'deletedAt': FieldValue.delete(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      debugPrint('ClientService.restoreClient error: $e');
      return false;
    }
  }
}

