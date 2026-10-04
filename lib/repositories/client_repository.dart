import 'package:drift/drift.dart';

import '../data/local/app_database.dart';
import '../models/client_model.dart';
import '../services/auth_identity.dart';

class LocalClientRecord {
  const LocalClientRecord({
    required this.id,
    required this.ownerUid,
    required this.name,
    required this.type,
    required this.phone,
    required this.email,
    required this.address,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
    this.deletedAt,
    this.syncState = 'pending',
    this.lastSyncedAt,
    this.cloudVersion,
  });

  final String id;
  final String ownerUid;
  final String name;
  final String type;
  final String phone;
  final String email;
  final String address;
  final String notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
  final DateTime? deletedAt;
  final String syncState;
  final DateTime? lastSyncedAt;
  final int? cloudVersion;

  factory LocalClientRecord.fromRow(LocalClient row) {
    return LocalClientRecord(
      id: row.id,
      ownerUid: row.ownerUid,
      name: row.name,
      type: row.type,
      phone: row.phone,
      email: row.email,
      address: row.address,
      notes: row.notes,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      isDeleted: row.isDeleted,
      deletedAt: row.deletedAt,
      syncState: row.syncState,
      lastSyncedAt: row.lastSyncedAt,
      cloudVersion: row.cloudVersion,
    );
  }

  factory LocalClientRecord.fromLegacyClient(
    ClientModel clientModel, {
    required String ownerUid,
  }) {
    return LocalClientRecord(
      id: clientModel.id,
      ownerUid: ownerUid,
      name: clientModel.name,
      type: clientModel.type,
      phone: clientModel.phone,
      email: clientModel.email,
      address: clientModel.address,
      notes: clientModel.notes,
      createdAt: clientModel.createdAt ?? DateTime.now(),
      updatedAt: clientModel.updatedAt ?? DateTime.now(),
      isDeleted: clientModel.isDeleted,
      deletedAt: clientModel.deletedAt,
      syncState: 'pending',
    );
  }

  LocalClientsCompanion toCompanion() {
    return LocalClientsCompanion(
      id: Value(id),
      ownerUid: Value(ownerUid),
      name: Value(name),
      type: Value(type),
      phone: Value(phone),
      email: Value(email),
      address: Value(address),
      notes: Value(notes),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: Value(deletedAt),
      isDeleted: Value(isDeleted),
      syncState: Value(syncState),
      lastSyncedAt: Value(lastSyncedAt),
      cloudVersion: Value(cloudVersion),
    );
  }

  LocalClientRecord copyWith({
    String? id,
    String? ownerUid,
    String? name,
    String? type,
    String? phone,
    String? email,
    String? address,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
    DateTime? deletedAt,
    String? syncState,
    DateTime? lastSyncedAt,
    int? cloudVersion,
  }) {
    return LocalClientRecord(
      id: id ?? this.id,
      ownerUid: ownerUid ?? this.ownerUid,
      name: name ?? this.name,
      type: type ?? this.type,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt ?? this.deletedAt,
      syncState: syncState ?? this.syncState,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      cloudVersion: cloudVersion ?? this.cloudVersion,
    );
  }
}

class ClientRepository {
  ClientRepository({
    required this.database,
    AppIdentity? identity,
  }) : _identity = identity ?? FirebaseAuthIdentity.instance;

  final AppDatabase database;
  final AppIdentity _identity;

  String get currentUserId {
    final uid = _identity.currentUserId;
    if (uid == null || uid.isEmpty) {
      throw StateError('No authenticated user is available for local repository access.');
    }
    return uid;
  }

  Future<String> saveClient(LocalClientRecord clientRecord) async {
    final authenticatedUid = currentUserId;
    final record = clientRecord.ownerUid.isEmpty
        ? clientRecord.copyWith(ownerUid: authenticatedUid)
        : clientRecord;

    if (record.ownerUid != authenticatedUid) {
      throw StateError(
        'Client owner mismatch: cannot write client for another user in local repository.',
      );
    }

    final existing = await (database.select(database.localClients)
          ..where((tbl) => tbl.id.equals(record.id)))
        .getSingleOrNull();

    if (existing != null) {
      await (database.update(database.localClients)
            ..where((tbl) => tbl.id.equals(record.id)))
          .write(record.toCompanion());
    } else {
      await database.into(database.localClients).insert(record.toCompanion());
    }

    return record.id;
  }

  Future<List<LocalClientRecord>> getClientsForCurrentUser() async {
    final uid = currentUserId;
    final rows = await (database.select(database.localClients)
          ..where((tbl) => tbl.ownerUid.equals(uid))
          ..where((tbl) => tbl.isDeleted.equals(false))
          ..orderBy([
            (tbl) => OrderingTerm.asc(tbl.name),
          ]))
        .get();

    return rows.map(LocalClientRecord.fromRow).toList();
  }

  Future<LocalClientRecord?> getClientById(String clientId) async {
    final uid = currentUserId;
    final row = await (database.select(database.localClients)
          ..where((tbl) => tbl.id.equals(clientId))
          ..where((tbl) => tbl.ownerUid.equals(uid)))
        .getSingleOrNull();

    return row == null ? null : LocalClientRecord.fromRow(row);
  }

  Future<List<LocalClientRecord>> searchClientsForCurrentUser({
    String query = '',
  }) async {
    final uid = currentUserId;
    final rows = await (database.select(database.localClients)
          ..where((tbl) => tbl.ownerUid.equals(uid))
          ..where((tbl) => tbl.isDeleted.equals(false)))
        .get();

    final searchText = query.trim().toLowerCase();
    if (searchText.isEmpty) {
      return rows.map(LocalClientRecord.fromRow).toList();
    }

    return rows
        .where((row) {
          final haystack = [
            row.name,
            row.phone,
            row.email,
            row.address,
            row.type,
          ].join(' ').toLowerCase();
          return haystack.contains(searchText);
        })
        .map(LocalClientRecord.fromRow)
        .toList();
  }

  Future<void> softDeleteClient(String clientId) async {
    final uid = currentUserId;
    final now = DateTime.now();
    await (database.update(database.localClients)
          ..where((tbl) => tbl.id.equals(clientId))
          ..where((tbl) => tbl.ownerUid.equals(uid)))
        .write(
      LocalClientsCompanion(
        isDeleted: const Value(true),
        deletedAt: Value(now),
        updatedAt: Value(now),
      ),
    );
  }

  Future<void> restoreClient(String clientId) async {
    final uid = currentUserId;
    final now = DateTime.now();
    await (database.update(database.localClients)
          ..where((tbl) => tbl.id.equals(clientId))
          ..where((tbl) => tbl.ownerUid.equals(uid)))
        .write(
      LocalClientsCompanion(
        isDeleted: const Value(false),
        deletedAt: const Value.absent(),
        updatedAt: Value(now),
      ),
    );
  }
}
