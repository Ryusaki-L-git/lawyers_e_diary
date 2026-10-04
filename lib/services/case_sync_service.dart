import 'package:cloud_firestore/cloud_firestore.dart';

import '../repositories/case_repository.dart';
import 'auth_identity.dart';

Object? _normalizeFirestoreValue(Object? value) {
  if (value is Timestamp) return value.toDate();
  if (value is Map) {
    return value.map(
      (key, item) => MapEntry(key.toString(), _normalizeFirestoreValue(item)),
    );
  }
  if (value is List) return value.map(_normalizeFirestoreValue).toList();
  return value;
}

class RemoteCaseDocument {
  const RemoteCaseDocument({required this.id, required this.data});

  final String id;
  final Map<String, dynamic> data;

  DateTime? get updatedAt {
    final value = data['updatedAt'] ?? data['lastUpdated'];
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  int get cloudVersion => (data['cloudVersion'] as num?)?.toInt() ?? 0;
}

abstract interface class CaseSyncDataSource {
  Future<RemoteCaseDocument?> readOwnedCase(String caseId);
  Future<List<RemoteCaseDocument>> fetchOwnedCases();
  Future<void> writeOwnedCase(
    String caseId,
    Map<String, dynamic> data, {
    required int? expectedCloudVersion,
    required DateTime? expectedUpdatedAt,
  });
}

class FirestoreCaseSyncDataSource implements CaseSyncDataSource {
  FirestoreCaseSyncDataSource({
    FirebaseFirestore? firestore,
    AppIdentity? identity,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _identity = identity ?? FirebaseAuthIdentity.instance;

  final FirebaseFirestore _firestore;
  final AppIdentity _identity;

  String get _uid {
    final uid = _identity.currentUserId;
    if (uid == null || uid.isEmpty) {
      throw StateError('Cannot sync Cases without an authenticated user.');
    }
    return uid;
  }

  CollectionReference<Map<String, dynamic>> get _cases =>
      _firestore.collection('cases');

  @override
  Future<RemoteCaseDocument?> readOwnedCase(String caseId) async {
    final uid = _uid;
    final canonical = await _cases
        .where(FieldPath.documentId, isEqualTo: caseId)
        .where('ownerUid', isEqualTo: uid)
        .limit(1)
        .get();
    final result = canonical.docs.isNotEmpty
        ? canonical
        : await _cases
              .where(FieldPath.documentId, isEqualTo: caseId)
              .where('userId', isEqualTo: uid)
              .where('ownerUid', isNull: true)
              .limit(1)
              .get();
    if (result.docs.isEmpty) return null;
    final document = result.docs.single;
    final rawData = document.data();
    if ((rawData['ownerUid'] ?? rawData['userId']) != uid) {
      throw StateError(
        'Firestore returned a Case outside the authenticated owner scope.',
      );
    }
    final data = Map<String, dynamic>.from(rawData)..['ownerUid'] = uid;
    return RemoteCaseDocument(
      id: document.id,
      data: Map<String, dynamic>.from(_normalizeFirestoreValue(data) as Map),
    );
  }

  @override
  Future<List<RemoteCaseDocument>> fetchOwnedCases() async {
    final uid = _uid;
    final results = await Future.wait([
      _cases.where('ownerUid', isEqualTo: uid).get(),
      _cases
          .where('userId', isEqualTo: uid)
          .where('ownerUid', isNull: true)
          .get(),
    ]);
    final documents = <String, QueryDocumentSnapshot<Map<String, dynamic>>>{};
    for (final result in results) {
      for (final document in result.docs) {
        final data = document.data();
        if ((data['ownerUid'] ?? data['userId']) == uid) {
          documents[document.id] = document;
        }
      }
    }

    return documents.values.map((document) {
      final normalized = Map<String, dynamic>.from(
        _normalizeFirestoreValue(document.data()) as Map,
      )..['ownerUid'] = uid;
      return RemoteCaseDocument(id: document.id, data: normalized);
    }).toList();
  }

  @override
  Future<void> writeOwnedCase(
    String caseId,
    Map<String, dynamic> data, {
    required int? expectedCloudVersion,
    required DateTime? expectedUpdatedAt,
  }) async {
    final uid = _uid;
    if (data['ownerUid'] != uid) {
      throw StateError(
        'Refusing to write a Case outside the authenticated owner scope.',
      );
    }

    final reference = _cases.doc(caseId);
    await _firestore.runTransaction((transaction) async {
      final existing = await transaction.get(reference);
      if (existing.exists) {
        final existingData = existing.data()!;
        if ((existingData['ownerUid'] ?? existingData['userId']) != uid) {
          throw StateError(
            'Firestore Case ID is already owned by another user.',
          );
        }
      }
      if (!existing.exists && expectedCloudVersion != null) {
        throw StateError('Firestore Case changed during synchronization.');
      }
      if (existing.exists) {
        final current = existing.data()!;
        final currentVersion = (current['cloudVersion'] as num?)?.toInt() ?? 0;
        final currentUpdatedValue =
            current['updatedAt'] ?? current['lastUpdated'];
        final currentUpdatedAt = currentUpdatedValue is Timestamp
            ? currentUpdatedValue.toDate()
            : currentUpdatedValue is DateTime
            ? currentUpdatedValue
            : currentUpdatedValue is String
            ? DateTime.tryParse(currentUpdatedValue)
            : null;
        if (currentVersion != expectedCloudVersion ||
            currentUpdatedAt != expectedUpdatedAt) {
          throw StateError('Firestore Case changed during synchronization.');
        }
      }
      transaction.set(reference, data);
    });
  }
}

class CaseSyncResult {
  const CaseSyncResult({
    this.uploaded = 0,
    this.downloaded = 0,
    this.conflicts = 0,
    this.failed = 0,
    this.rejected = 0,
    this.pullError,
  });

  final int uploaded;
  final int downloaded;
  final int conflicts;
  final int failed;
  final int rejected;
  final String? pullError;
}

class CaseSyncEngine {
  factory CaseSyncEngine({
    required CaseRepository repository,
    required CaseSyncDataSource dataSource,
  }) => CaseSyncEngine._(repository, dataSource);

  CaseSyncEngine._(this._repository, this._dataSource);

  final CaseRepository _repository;
  final CaseSyncDataSource _dataSource;

  Future<CaseSyncResult> sync() async {
    _repository.currentUserId;
    var uploaded = 0;
    var downloaded = 0;
    var conflicts = 0;
    var failed = 0;
    var rejected = 0;
    final conflictsHandled = <String>{};
    String? pullError;

    final pending = await _repository.getPendingCaseChanges();
    for (final change in pending) {
      try {
        final remote = await _dataSource.readOwnedCase(change.record.id);
        if (remote != null &&
            remote.data['ownerUid'] != change.record.ownerUid) {
          rejected++;
          continue;
        }

        if (remote != null &&
            remote.updatedAt != null &&
            remote.updatedAt!.isAfter(change.record.updatedAt)) {
          await _repository.markCaseConflict(
            caseId: change.record.id,
            expectedRevision: change.revision,
            remoteData: remote.data,
            cloudVersion: remote.cloudVersion,
          );
          conflictsHandled.add(change.record.id);
          conflicts++;
          continue;
        }

        final version = remote == null
            ? 1
            : remote.updatedAt != null &&
                  change.record.updatedAt.isAfter(remote.updatedAt!)
            ? remote.cloudVersion + 1
            : (remote.cloudVersion == 0 ? 1 : remote.cloudVersion);
        await _dataSource.writeOwnedCase(
          change.record.id,
          change.record.toCloudMap(cloudVersion: version),
          expectedCloudVersion: remote?.cloudVersion,
          expectedUpdatedAt: remote?.updatedAt,
        );
        await _repository.markCaseSynchronized(
          caseId: change.record.id,
          expectedRevision: change.revision,
          expectedUpdatedAt: change.record.updatedAt,
          cloudVersion: version,
        );
        uploaded++;
      } catch (error) {
        await _repository.markCaseSyncFailed(
          caseId: change.record.id,
          expectedRevision: change.revision,
          error: error,
        );
        failed++;
      }
    }

    try {
      final remoteCases = await _dataSource.fetchOwnedCases();
      for (final remote in remoteCases) {
        if (conflictsHandled.contains(remote.id)) continue;
        final uid = _repository.currentUserId;
        if (remote.data['ownerUid'] != uid) {
          rejected++;
          continue;
        }
        final syncedAt = DateTime.now();
        final record = LocalCaseRecord.fromCloudMap(
          id: remote.id,
          ownerUid: uid,
          data: remote.data,
          lastSyncedAt: syncedAt,
          cloudVersion: remote.cloudVersion,
        );
        final outcome = await _repository.applyRemoteCase(
          remoteCase: record,
          remoteData: remote.data,
        );
        if (outcome == 'applied') downloaded++;
        if (outcome == 'conflict') conflicts++;
      }
    } catch (error) {
      pullError = error.toString();
    }

    return CaseSyncResult(
      uploaded: uploaded,
      downloaded: downloaded,
      conflicts: conflicts,
      failed: failed,
      rejected: rejected,
      pullError: pullError,
    );
  }
}
