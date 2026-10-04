import 'dart:convert';

import 'package:drift/drift.dart';

import '../data/local/app_database.dart';
import '../models/case_model.dart';
import '../services/auth_identity.dart';

List<CaseDocumentModel> _decodeCaseDocuments(String value) {
  try {
    final decoded = jsonDecode(value);
    if (decoded is! List) {
      return const [];
    }

    final documents = <CaseDocumentModel>[];
    for (final item in decoded) {
      if (item is Map) {
        documents.add(
          CaseDocumentModel.fromMap(Map<String, dynamic>.from(item)),
        );
      }
    }
    return documents;
  } catch (_) {
    return const [];
  }
}

List<String> _decodeCaseNotes(String value) {
  try {
    final decoded = jsonDecode(value);
    if (decoded is! List) {
      return const [];
    }

    return decoded.map((item) => item.toString()).toList();
  } catch (_) {
    return const [];
  }
}

String _encodeSyncPayload(Map<String, dynamic> value) {
  return jsonEncode(
    value,
    toEncodable: (item) =>
        item is DateTime ? item.toIso8601String() : item.toString(),
  );
}

class LocalCaseRecord {
  const LocalCaseRecord({
    required this.id,
    required this.ownerUid,
    required this.caseNumber,
    required this.caseTitle,
    required this.clientName,
    required this.opponentName,
    required this.courtName,
    required this.status,
    required this.caseType,
    required this.handledBy,
    this.clientPhone,
    required this.isStarred,
    this.assignedUserUid,
    this.teamId,
    this.nextHearingDate,
    this.cnr,
    this.caseSource = 'manual',
    this.lifecycleMode = 'manual',
    this.documents = const [],
    this.notes = const [],
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.isDeleted,
    this.syncState = 'pending',
    this.lastSyncedAt,
    this.cloudVersion,
    this.cloudId,
    this.syncError,
    this.conflictRemoteData,
  });

  final String id;
  final String ownerUid;
  final String caseNumber;
  final String caseTitle;
  final String clientName;
  final String opponentName;
  final String courtName;
  final String status;
  final String caseType;
  final String handledBy;
  final String? clientPhone;
  final bool isStarred;
  final String? assignedUserUid;
  final String? teamId;
  final DateTime? nextHearingDate;
  final String? cnr;
  final String caseSource;
  final String lifecycleMode;
  final List<CaseDocumentModel> documents;
  final List<String> notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final bool isDeleted;
  final String syncState;
  final DateTime? lastSyncedAt;
  final int? cloudVersion;
  final String? cloudId;
  final String? syncError;
  final String? conflictRemoteData;

  factory LocalCaseRecord.fromRow(LocalCase row) {
    return LocalCaseRecord(
      id: row.id,
      ownerUid: row.ownerUid,
      caseNumber: row.caseNumber,
      caseTitle: row.caseTitle,
      clientName: row.clientName,
      opponentName: row.opponentName,
      courtName: row.courtName,
      status: row.status,
      caseType: row.caseType,
      handledBy: row.handledBy,
      clientPhone: row.clientPhone,
      isStarred: row.isStarred,
      assignedUserUid: row.assignedUserUid,
      teamId: row.teamId,
      nextHearingDate: row.nextHearingDate,
      cnr: row.cnr,
      caseSource: row.caseSource,
      lifecycleMode: row.lifecycleMode,
      documents: _decodeCaseDocuments(row.documents),
      notes: _decodeCaseNotes(row.notes),
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      deletedAt: row.deletedAt,
      isDeleted: row.isDeleted,
      syncState: row.syncState,
      lastSyncedAt: row.lastSyncedAt,
      cloudVersion: row.cloudVersion,
      cloudId: row.cloudId,
      syncError: row.syncError,
      conflictRemoteData: row.conflictRemoteData,
    );
  }

  factory LocalCaseRecord.fromLegacyCase(
    CaseModel caseModel, {
    required String ownerUid,
    String? assignedUserUid,
    String? teamId,
    String caseSource = 'manual',
    String lifecycleMode = 'manual',
  }) {
    return LocalCaseRecord(
      id: caseModel.id,
      ownerUid: ownerUid,
      caseNumber: caseModel.caseNumber,
      caseTitle: caseModel.caseTitle,
      clientName: caseModel.clientName,
      opponentName: caseModel.opponentName,
      courtName: caseModel.courtName,
      status: caseModel.status,
      caseType: caseModel.caseType,
      handledBy: caseModel.handledBy,
      clientPhone: caseModel.clientPhone,
      isStarred: caseModel.isStarred,
      assignedUserUid: assignedUserUid ?? caseModel.userId,
      teamId: teamId,
      nextHearingDate: caseModel.nextHearingDate,
      cnr: caseModel.caseNumber,
      caseSource: caseSource,
      lifecycleMode: lifecycleMode,
      documents: List<CaseDocumentModel>.from(caseModel.documents),
      notes: List<String>.from(caseModel.notes),
      createdAt: caseModel.createdAt ?? DateTime.now(),
      updatedAt: caseModel.updatedAt ?? DateTime.now(),
      deletedAt: caseModel.deletedAt,
      isDeleted: caseModel.isDeleted,
      syncState: 'pending',
      cloudId: caseModel.id,
    );
  }

  LocalCasesCompanion toCompanion({
    String? syncStateOverride,
    Value<String?> syncErrorOverride = const Value.absent(),
    Value<String?> conflictRemoteDataOverride = const Value.absent(),
  }) {
    return LocalCasesCompanion(
      id: Value(id),
      ownerUid: Value(ownerUid),
      caseNumber: Value(caseNumber),
      caseTitle: Value(caseTitle),
      clientName: Value(clientName),
      opponentName: Value(opponentName),
      courtName: Value(courtName),
      caseType: Value(caseType),
      status: Value(status),
      nextHearingDate: Value(nextHearingDate),
      handledBy: Value(handledBy),
      clientPhone: Value(clientPhone),
      isStarred: Value(isStarred),
      documents: Value(jsonEncode(documents.map((d) => d.toMap()).toList())),
      notes: Value(jsonEncode(notes)),
      assignedUserUid: Value(assignedUserUid),
      teamId: Value(teamId),
      cnr: Value(cnr),
      caseSource: Value(caseSource),
      lifecycleMode: Value(lifecycleMode),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: Value(deletedAt),
      isDeleted: Value(isDeleted),
      syncState: Value(syncStateOverride ?? syncState),
      lastSyncedAt: Value(lastSyncedAt),
      cloudVersion: Value(cloudVersion),
      cloudId: Value(cloudId),
      syncError: syncErrorOverride.present
          ? syncErrorOverride
          : Value(syncError),
      conflictRemoteData: conflictRemoteDataOverride.present
          ? conflictRemoteDataOverride
          : Value(conflictRemoteData),
    );
  }

  Map<String, dynamic> toCloudMap({required int cloudVersion}) {
    return {
      'ownerUid': ownerUid,
      'userId': ownerUid,
      'caseTitle': caseTitle,
      'cnrNumber': caseNumber,
      'caseNumber': caseNumber,
      'clientName': clientName,
      'opponentName': opponentName,
      'courtName': courtName,
      'caseType': caseType,
      'status': isDeleted ? 'deleted' : status,
      'isDeleted': isDeleted,
      'nextHearingDate': nextHearingDate,
      'handledBy': handledBy,
      'clientPhone': clientPhone,
      'isStarred': isStarred,
      'documents': documents.map((document) => document.toMap()).toList(),
      'notes': notes,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'lastUpdated': updatedAt,
      'deletedAt': deletedAt,
      'assignedUserUid': assignedUserUid,
      'teamId': teamId,
      'caseSource': caseSource,
      'lifecycleMode': lifecycleMode,
      'cloudVersion': cloudVersion,
    };
  }

  factory LocalCaseRecord.fromCloudMap({
    required String id,
    required String ownerUid,
    required Map<String, dynamic> data,
    required DateTime lastSyncedAt,
    required int cloudVersion,
  }) {
    if (data['ownerUid'] != ownerUid) {
      throw StateError(
        'Remote Case owner does not match the authenticated user.',
      );
    }

    final model = CaseModel.fromMap(id, data);
    return LocalCaseRecord(
      id: id,
      ownerUid: ownerUid,
      caseNumber: model.caseNumber,
      caseTitle: model.caseTitle,
      clientName: model.clientName,
      opponentName: model.opponentName,
      courtName: model.courtName,
      status: model.status,
      caseType: model.caseType,
      handledBy: model.handledBy,
      clientPhone: model.clientPhone,
      isStarred: model.isStarred,
      assignedUserUid: data['assignedUserUid'] as String?,
      teamId: data['teamId'] as String?,
      nextHearingDate: model.nextHearingDate,
      cnr: model.caseNumber,
      caseSource: data['caseSource'] as String? ?? 'manual',
      lifecycleMode: data['lifecycleMode'] as String? ?? 'manual',
      documents: model.documents,
      notes: model.notes,
      createdAt: model.createdAt ?? lastSyncedAt,
      updatedAt: model.updatedAt ?? lastSyncedAt,
      deletedAt: model.deletedAt,
      isDeleted: data['isDeleted'] as bool? ?? model.isDeleted,
      syncState: 'synced',
      lastSyncedAt: lastSyncedAt,
      cloudVersion: cloudVersion,
      cloudId: id,
    );
  }
  CaseModel toCaseModel() {
    return CaseModel(
      id: id,
      caseTitle: caseTitle,
      caseNumber: caseNumber,
      clientName: clientName,
      opponentName: opponentName,
      courtName: courtName,
      caseType: caseType,
      status: isDeleted ? 'deleted' : status,
      nextHearingDate: nextHearingDate,
      handledBy: handledBy,
      userId: ownerUid,
      clientPhone: clientPhone,
      isStarred: isStarred,
      documents: documents,
      notes: notes,
      createdAt: createdAt,
      updatedAt: updatedAt,
      deletedAt: deletedAt,
    );
  }

  LocalCaseRecord copyWith({
    String? id,
    String? ownerUid,
    String? caseNumber,
    String? caseTitle,
    String? clientName,
    String? opponentName,
    String? courtName,
    String? status,
    String? caseType,
    String? handledBy,
    String? clientPhone,
    bool? isStarred,
    String? assignedUserUid,
    String? teamId,
    DateTime? nextHearingDate,
    String? cnr,
    String? caseSource,
    String? lifecycleMode,
    List<CaseDocumentModel>? documents,
    List<String>? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    bool? isDeleted,
    String? syncState,
    DateTime? lastSyncedAt,
    int? cloudVersion,
    String? cloudId,
    String? syncError,
    String? conflictRemoteData,
  }) {
    return LocalCaseRecord(
      id: id ?? this.id,
      ownerUid: ownerUid ?? this.ownerUid,
      caseNumber: caseNumber ?? this.caseNumber,
      caseTitle: caseTitle ?? this.caseTitle,
      clientName: clientName ?? this.clientName,
      opponentName: opponentName ?? this.opponentName,
      courtName: courtName ?? this.courtName,
      status: status ?? this.status,
      caseType: caseType ?? this.caseType,
      handledBy: handledBy ?? this.handledBy,
      clientPhone: clientPhone ?? this.clientPhone,
      isStarred: isStarred ?? this.isStarred,
      assignedUserUid: assignedUserUid ?? this.assignedUserUid,
      teamId: teamId ?? this.teamId,
      nextHearingDate: nextHearingDate ?? this.nextHearingDate,
      cnr: cnr ?? this.cnr,
      caseSource: caseSource ?? this.caseSource,
      lifecycleMode: lifecycleMode ?? this.lifecycleMode,
      documents: documents ?? this.documents,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      syncState: syncState ?? this.syncState,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      cloudVersion: cloudVersion ?? this.cloudVersion,
      cloudId: cloudId ?? this.cloudId,
      syncError: syncError ?? this.syncError,
      conflictRemoteData: conflictRemoteData ?? this.conflictRemoteData,
    );
  }
}

class PendingCaseChange {
  const PendingCaseChange({
    required this.record,
    required this.revision,
    required this.operation,
    required this.attemptCount,
  });

  final LocalCaseRecord record;
  final int revision;
  final String operation;
  final int attemptCount;
}

class CaseRepository {
  CaseRepository({required this.database, AppIdentity? identity})
    : _identity = identity ?? FirebaseAuthIdentity.instance;

  final AppDatabase database;
  final AppIdentity _identity;

  String get currentUserId {
    final uid = _identity.currentUserId;
    if (uid == null || uid.isEmpty) {
      throw StateError(
        'No authenticated user is available for local repository access.',
      );
    }
    return uid;
  }

  Future<void> _enqueueChange({
    required String caseId,
    required String ownerUid,
    required String operation,
    required DateTime changedAt,
  }) async {
    final existing = await (database.select(
      database.localCaseChanges,
    )..where((tbl) => tbl.caseId.equals(caseId))).getSingleOrNull();

    if (existing != null && existing.ownerUid != ownerUid) {
      throw StateError('Case change owner mismatch.');
    }

    if (existing == null) {
      await database
          .into(database.localCaseChanges)
          .insert(
            LocalCaseChangesCompanion.insert(
              caseId: caseId,
              ownerUid: ownerUid,
              operation: operation,
              changedAt: changedAt,
            ),
          );
      return;
    }

    await (database.update(database.localCaseChanges)
          ..where((tbl) => tbl.caseId.equals(caseId))
          ..where((tbl) => tbl.ownerUid.equals(ownerUid)))
        .write(
          LocalCaseChangesCompanion(
            revision: Value(existing.revision + 1),
            operation: Value(operation),
            changedAt: Value(changedAt),
            attemptCount: const Value(0),
            lastError: const Value(null),
          ),
        );
  }

  Future<String> saveCase(LocalCaseRecord caseRecord) async {
    final authenticatedUid = currentUserId;
    final record = caseRecord.ownerUid.isEmpty
        ? caseRecord.copyWith(ownerUid: authenticatedUid)
        : caseRecord;

    if (record.ownerUid != authenticatedUid) {
      throw StateError(
        'Case owner mismatch: cannot write case for another user in local repository.',
      );
    }

    return database.transaction(() async {
      final existing = await (database.select(
        database.localCases,
      )..where((tbl) => tbl.id.equals(record.id))).getSingleOrNull();

      if (existing != null && existing.ownerUid != authenticatedUid) {
        throw StateError(
          'Case owner mismatch: cannot replace another user\'s local case.',
        );
      }

      final companion = record
          .copyWith(
            lastSyncedAt: record.lastSyncedAt ?? existing?.lastSyncedAt,
            cloudVersion: record.cloudVersion ?? existing?.cloudVersion,
            cloudId: record.cloudId ?? existing?.cloudId,
          )
          .toCompanion(
            syncStateOverride: 'pending',
            syncErrorOverride: const Value(null),
            conflictRemoteDataOverride: Value(existing?.conflictRemoteData),
          );
      if (existing != null) {
        await (database.update(
          database.localCases,
        )..where((tbl) => tbl.id.equals(record.id))).write(companion);
      } else {
        await database.into(database.localCases).insert(companion);
      }

      await _enqueueChange(
        caseId: record.id,
        ownerUid: authenticatedUid,
        operation: record.isDeleted ? 'archive' : 'upsert',
        changedAt: record.updatedAt,
      );
      return record.id;
    });
  }

  Future<String> createCase({
    required String caseTitle,
    required String caseNumber,
    required String clientName,
    required String opponentName,
    required String courtName,
    required String caseType,
    required String status,
    required String handledBy,
    String? clientPhone,
    DateTime? nextHearingDate,
    List<String> notes = const [],
  }) async {
    final uid = currentUserId;
    final now = DateTime.now();
    final caseModel = CaseModel(
      id: 'case_${now.microsecondsSinceEpoch}',
      caseTitle: caseTitle,
      caseNumber: caseNumber,
      clientName: clientName,
      opponentName: opponentName,
      courtName: courtName,
      caseType: caseType,
      status: status.toLowerCase(),
      handledBy: handledBy,
      userId: uid,
      clientPhone: clientPhone,
      nextHearingDate: nextHearingDate,
      notes: notes,
      createdAt: now,
      updatedAt: now,
    );

    return saveCase(LocalCaseRecord.fromLegacyCase(caseModel, ownerUid: uid));
  }

  Future<List<LocalCaseRecord>> getCasesForCurrentUser() async {
    final uid = currentUserId;
    final rows =
        await (database.select(database.localCases)
              ..where((tbl) => tbl.ownerUid.equals(uid))
              ..orderBy([(tbl) => OrderingTerm.desc(tbl.updatedAt)]))
            .get();

    return rows.map(LocalCaseRecord.fromRow).toList();
  }

  Stream<List<CaseModel>> watchCasesForCurrentUser({
    String? status,
    String? caseType,
    String? handledBy,
    String? searchQuery,
    DateTime? hearingDateFrom,
    DateTime? hearingDateTo,
    String? sortBy = 'nextHearing',
  }) {
    try {
      final uid = currentUserId;
      final query =
          (database.select(database.localCases)
                ..where((tbl) => tbl.ownerUid.equals(uid))
                ..where((tbl) => tbl.isDeleted.equals(false))
                ..orderBy([(tbl) => OrderingTerm.desc(tbl.updatedAt)]))
              .watch();

      return query.map((rows) {
        var cases = rows
            .map((row) => LocalCaseRecord.fromRow(row).toCaseModel())
            .toList();

        if (status != null &&
            status.isNotEmpty &&
            status.toLowerCase() != 'all') {
          cases = cases
              .where(
                (item) => item.status.toLowerCase() == status.toLowerCase(),
              )
              .toList();
        }
        if (caseType != null &&
            caseType.isNotEmpty &&
            caseType.toLowerCase() != 'all') {
          cases = cases
              .where(
                (item) => item.caseType.toLowerCase().contains(
                  caseType.toLowerCase(),
                ),
              )
              .toList();
        }
        if (handledBy != null &&
            handledBy.isNotEmpty &&
            handledBy.toLowerCase() != 'all') {
          cases = cases
              .where(
                (item) => item.handledBy.toLowerCase().contains(
                  handledBy.toLowerCase(),
                ),
              )
              .toList();
        }
        if (searchQuery != null && searchQuery.trim().isNotEmpty) {
          final queryText = searchQuery.trim().toLowerCase();
          cases = cases.where((item) {
            return item.caseTitle.toLowerCase().contains(queryText) ||
                item.clientName.toLowerCase().contains(queryText) ||
                item.caseNumber.toLowerCase().contains(queryText);
          }).toList();
        }
        if (hearingDateFrom != null || hearingDateTo != null) {
          cases = cases.where((item) {
            final date = item.nextHearingDate;
            if (date == null) return false;
            return (hearingDateFrom == null ||
                    !date.isBefore(hearingDateFrom)) &&
                (hearingDateTo == null || !date.isAfter(hearingDateTo));
          }).toList();
        }

        if (sortBy == 'title') {
          cases.sort((a, b) => a.caseTitle.compareTo(b.caseTitle));
        } else if (sortBy == 'created') {
          cases.sort(
            (a, b) => (b.createdAt ?? DateTime(2020)).compareTo(
              a.createdAt ?? DateTime(2020),
            ),
          );
        } else {
          cases.sort((a, b) {
            if (a.nextHearingDate == null && b.nextHearingDate == null) {
              return 0;
            }
            if (a.nextHearingDate == null) return 1;
            if (b.nextHearingDate == null) return -1;
            return a.nextHearingDate!.compareTo(b.nextHearingDate!);
          });
        }

        return cases;
      });
    } catch (error, stackTrace) {
      return Stream.error(error, stackTrace);
    }
  }

  Future<List<LocalCaseRecord>> searchCasesForCurrentUser({
    String query = '',
    String? status,
  }) async {
    final uid = currentUserId;
    var base = database.select(database.localCases)
      ..where((tbl) => tbl.ownerUid.equals(uid));

    if (status != null && status.isNotEmpty) {
      base = base..where((tbl) => tbl.status.equals(status));
    }

    final rows = await base.get();
    final searchText = query.trim().toLowerCase();

    final filtered = rows.where((row) {
      if (searchText.isEmpty) {
        return true;
      }
      final haystack = [
        row.caseTitle,
        row.caseNumber,
        row.clientName,
        row.courtName,
        row.caseType,
      ].join(' ').toLowerCase();
      return haystack.contains(searchText);
    }).toList();

    if (status != null && status.isNotEmpty) {
      return filtered
          .map(LocalCaseRecord.fromRow)
          .where((row) => row.status == status)
          .toList();
    }

    return filtered.map(LocalCaseRecord.fromRow).toList();
  }

  Future<LocalCaseRecord?> getCaseById(String caseId) async {
    final uid = currentUserId;
    final row =
        await (database.select(database.localCases)
              ..where((tbl) => tbl.id.equals(caseId))
              ..where((tbl) => tbl.ownerUid.equals(uid)))
            .getSingleOrNull();

    return row == null ? null : LocalCaseRecord.fromRow(row);
  }

  Future<List<PendingCaseChange>> getPendingCaseChanges() async {
    final uid = currentUserId;
    final changes =
        await (database.select(database.localCaseChanges)
              ..where((tbl) => tbl.ownerUid.equals(uid))
              ..orderBy([(tbl) => OrderingTerm.asc(tbl.changedAt)]))
            .get();
    final pending = <PendingCaseChange>[];

    for (final change in changes) {
      final record = await getCaseById(change.caseId);
      if (record == null || record.syncState == 'conflict') continue;
      pending.add(
        PendingCaseChange(
          record: record,
          revision: change.revision,
          operation: change.operation,
          attemptCount: change.attemptCount,
        ),
      );
    }

    return pending;
  }

  Future<void> markCaseSyncFailed({
    required String caseId,
    required int expectedRevision,
    required Object error,
  }) async {
    final uid = currentUserId;
    final message = error.toString();
    final savedError = message.length > 1000
        ? message.substring(0, 1000)
        : message;

    await database.transaction(() async {
      final change =
          await (database.select(database.localCaseChanges)
                ..where((tbl) => tbl.caseId.equals(caseId))
                ..where((tbl) => tbl.ownerUid.equals(uid)))
              .getSingleOrNull();
      if (change == null || change.revision != expectedRevision) return;

      await (database.update(database.localCaseChanges)
            ..where((tbl) => tbl.caseId.equals(caseId))
            ..where((tbl) => tbl.ownerUid.equals(uid)))
          .write(
            LocalCaseChangesCompanion(
              attemptCount: Value(change.attemptCount + 1),
              lastError: Value(savedError),
            ),
          );
      await (database.update(database.localCases)
            ..where((tbl) => tbl.id.equals(caseId))
            ..where((tbl) => tbl.ownerUid.equals(uid)))
          .write(
            LocalCasesCompanion(
              syncState: const Value('failed'),
              syncError: Value(savedError),
            ),
          );
    });
  }

  Future<void> markCaseConflict({
    required String caseId,
    required int expectedRevision,
    required Map<String, dynamic> remoteData,
    required int cloudVersion,
  }) async {
    final uid = currentUserId;
    await database.transaction(() async {
      final change =
          await (database.select(database.localCaseChanges)
                ..where((tbl) => tbl.caseId.equals(caseId))
                ..where((tbl) => tbl.ownerUid.equals(uid)))
              .getSingleOrNull();
      if (change == null || change.revision != expectedRevision) return;

      await (database.update(database.localCases)
            ..where((tbl) => tbl.id.equals(caseId))
            ..where((tbl) => tbl.ownerUid.equals(uid)))
          .write(
            LocalCasesCompanion(
              syncState: const Value('conflict'),
              syncError: const Value(
                'A newer cloud Case exists; local data was retained.',
              ),
              conflictRemoteData: Value(
                jsonEncode(
                  remoteData,
                  toEncodable: (value) => value is DateTime
                      ? value.toIso8601String()
                      : value.toString(),
                ),
              ),
              cloudId: Value(caseId),
              cloudVersion: Value(cloudVersion),
            ),
          );
    });
  }

  Future<void> markCaseSynchronized({
    required String caseId,
    required int expectedRevision,
    required DateTime expectedUpdatedAt,
    required int cloudVersion,
  }) async {
    final uid = currentUserId;
    await database.transaction(() async {
      final row =
          await (database.select(database.localCases)
                ..where((tbl) => tbl.id.equals(caseId))
                ..where((tbl) => tbl.ownerUid.equals(uid)))
              .getSingleOrNull();
      final change =
          await (database.select(database.localCaseChanges)
                ..where((tbl) => tbl.caseId.equals(caseId))
                ..where((tbl) => tbl.ownerUid.equals(uid)))
              .getSingleOrNull();
      if (row == null ||
          change == null ||
          change.revision != expectedRevision ||
          !row.updatedAt.isAtSameMomentAs(expectedUpdatedAt)) {
        return;
      }

      await (database.update(database.localCases)
            ..where((tbl) => tbl.id.equals(caseId))
            ..where((tbl) => tbl.ownerUid.equals(uid)))
          .write(
            LocalCasesCompanion(
              syncState: const Value('synced'),
              lastSyncedAt: Value(DateTime.now()),
              cloudVersion: Value(cloudVersion),
              cloudId: Value(caseId),
              syncError: const Value(null),
              conflictRemoteData: const Value(null),
            ),
          );
      await (database.delete(database.localCaseChanges)
            ..where((tbl) => tbl.caseId.equals(caseId))
            ..where((tbl) => tbl.ownerUid.equals(uid))
            ..where((tbl) => tbl.revision.equals(expectedRevision)))
          .go();
    });
  }

  Future<String> applyRemoteCase({
    required LocalCaseRecord remoteCase,
    required Map<String, dynamic> remoteData,
  }) async {
    final uid = currentUserId;
    if (remoteCase.ownerUid != uid) {
      throw StateError('Cannot apply a remote Case owned by another user.');
    }

    return database.transaction(() async {
      final local = await (database.select(
        database.localCases,
      )..where((tbl) => tbl.id.equals(remoteCase.id))).getSingleOrNull();
      if (local != null && local.ownerUid != uid) {
        throw StateError('Local Case ID belongs to another user.');
      }

      final queued =
          await (database.select(database.localCaseChanges)
                ..where((tbl) => tbl.caseId.equals(remoteCase.id))
                ..where((tbl) => tbl.ownerUid.equals(uid)))
              .getSingleOrNull();
      if (local != null &&
          (queued != null ||
              local.syncState == 'pending' ||
              local.syncState == 'failed' ||
              local.syncState == 'conflict')) {
        // Keep local pending data and the remote snapshot when cloud is newer.
        if (remoteCase.updatedAt.isAfter(local.updatedAt) && queued != null) {
          await (database.update(database.localCases)
                ..where((tbl) => tbl.id.equals(remoteCase.id))
                ..where((tbl) => tbl.ownerUid.equals(uid)))
              .write(
                LocalCasesCompanion(
                  syncState: const Value('conflict'),
                  syncError: const Value(
                    'A newer cloud Case exists; local data was retained.',
                  ),
                  conflictRemoteData: Value(_encodeSyncPayload(remoteData)),
                  cloudId: Value(remoteCase.cloudId ?? remoteCase.id),
                  cloudVersion: Value(remoteCase.cloudVersion),
                ),
              );
          return 'conflict';
        }
        return 'local-retained';
      }

      if (local != null && !remoteCase.updatedAt.isAfter(local.updatedAt)) {
        return 'local-retained';
      }

      if (local == null) {
        await database
            .into(database.localCases)
            .insert(remoteCase.toCompanion());
      } else {
        await (database.update(database.localCases)
              ..where((tbl) => tbl.id.equals(remoteCase.id))
              ..where((tbl) => tbl.ownerUid.equals(uid)))
            .write(remoteCase.toCompanion());
      }
      return 'applied';
    });
  }

  Future<void> softDeleteCase(String caseId) async {
    final uid = currentUserId;
    final now = DateTime.now();
    await _mutateCase(
      caseId: caseId,
      ownerUid: uid,
      operation: 'archive',
      changedAt: now,
      update: LocalCasesCompanion(
        status: const Value('deleted'),
        isDeleted: const Value(true),
        deletedAt: Value(now),
      ),
    );
  }

  Future<void> setCaseStarred(String caseId, bool isStarred) async {
    final uid = currentUserId;
    await _mutateCase(
      caseId: caseId,
      ownerUid: uid,
      operation: 'upsert',
      changedAt: DateTime.now(),
      update: LocalCasesCompanion(isStarred: Value(isStarred)),
    );
  }

  Future<void> restoreCase(String caseId) async {
    final uid = currentUserId;
    final now = DateTime.now();
    await _mutateCase(
      caseId: caseId,
      ownerUid: uid,
      operation: 'restore',
      changedAt: now,
      update: const LocalCasesCompanion(
        status: Value('active'),
        isDeleted: Value(false),
        deletedAt: Value(null),
      ),
    );
  }

  Future<void> _mutateCase({
    required String caseId,
    required String ownerUid,
    required String operation,
    required DateTime changedAt,
    required LocalCasesCompanion update,
  }) async {
    await database.transaction(() async {
      final changed =
          await (database.update(database.localCases)
                ..where((tbl) => tbl.id.equals(caseId))
                ..where((tbl) => tbl.ownerUid.equals(ownerUid)))
              .write(
                update.copyWith(
                  updatedAt: Value(changedAt),
                  syncState: const Value('pending'),
                  syncError: const Value(null),
                  conflictRemoteData: const Value(null),
                ),
              );
      if (changed == 0) {
        throw StateError(
          'Case was not found in the current user\'s local docket.',
        );
      }

      await _enqueueChange(
        caseId: caseId,
        ownerUid: ownerUid,
        operation: operation,
        changedAt: changedAt,
      );
    });
  }
}
