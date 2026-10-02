import 'package:flutter_test/flutter_test.dart';
import 'package:lawyers_e_diary/data/local/app_database.dart';
import 'package:lawyers_e_diary/models/case_model.dart';
import 'package:lawyers_e_diary/repositories/case_repository.dart';
import 'package:lawyers_e_diary/services/auth_identity.dart';
import 'package:lawyers_e_diary/services/case_sync_service.dart';

class FakeCaseSyncDataSource implements CaseSyncDataSource {
  FakeCaseSyncDataSource(this.uid);

  final String uid;
  final Map<String, Map<String, dynamic>> documents = {};
  bool failWrites = false;
  bool returnForeignDocuments = false;
  int writeCount = 0;

  @override
  Future<RemoteCaseDocument?> readOwnedCase(String caseId) async {
    final data = documents[caseId];
    if (data == null || data['ownerUid'] != uid) return null;
    return RemoteCaseDocument(
      id: caseId,
      data: Map<String, dynamic>.from(data),
    );
  }

  @override
  Future<List<RemoteCaseDocument>> fetchOwnedCases() async {
    return documents.entries
        .where(
          (entry) => returnForeignDocuments || entry.value['ownerUid'] == uid,
        )
        .map(
          (entry) => RemoteCaseDocument(
            id: entry.key,
            data: Map<String, dynamic>.from(entry.value),
          ),
        )
        .toList();
  }

  @override
  Future<void> writeOwnedCase(
    String caseId,
    Map<String, dynamic> data, {
    required int? expectedCloudVersion,
    required DateTime? expectedUpdatedAt,
  }) async {
    if (failWrites) throw StateError('Injected cloud write failure.');
    if (data['ownerUid'] != uid) throw StateError('Wrong owner in write.');
    final existing = documents[caseId];
    if (existing != null && existing['ownerUid'] != uid) {
      throw StateError('Cloud Case belongs to another user.');
    }
    if (existing == null && expectedCloudVersion != null) {
      throw StateError('Cloud Case changed during synchronization.');
    }
    if (existing != null) {
      final remoteUpdatedAt = existing['updatedAt'] as DateTime?;
      final remoteCloudVersion =
          (existing['cloudVersion'] as num?)?.toInt() ?? 0;
      if (remoteCloudVersion != expectedCloudVersion ||
          remoteUpdatedAt != expectedUpdatedAt) {
        throw StateError('Cloud Case changed during synchronization.');
      }
    }
    documents[caseId] = Map<String, dynamic>.from(data);
    writeCount++;
  }
}

LocalCaseRecord buildRecord({
  required String id,
  required String ownerUid,
  required DateTime updatedAt,
  String title = 'Sync case',
  bool isDeleted = false,
}) {
  return LocalCaseRecord(
    id: id,
    ownerUid: ownerUid,
    caseNumber: 'CNR-$id',
    caseTitle: title,
    clientName: 'Client',
    opponentName: 'Opponent',
    courtName: 'District Court',
    status: isDeleted ? 'deleted' : 'active',
    caseType: 'Civil',
    handledBy: 'Advocate',
    isStarred: false,
    documents: const [CaseDocumentModel(name: 'brief.pdf', type: 'PDF')],
    notes: const ['Initial note'],
    createdAt: updatedAt,
    updatedAt: updatedAt,
    isDeleted: isDeleted,
    deletedAt: isDeleted ? updatedAt : null,
  );
}

void main() {
  late AppDatabase database;
  late CaseRepository repository;
  late FakeCaseSyncDataSource dataSource;
  late CaseSyncEngine engine;
  final now = DateTime.now().subtract(const Duration(days: 1));

  setUp(() {
    database = AppDatabase.memory();
    repository = CaseRepository(
      database: database,
      identity: const TestAuthIdentity('user-a'),
    );
    dataSource = FakeCaseSyncDataSource('user-a');
    engine = CaseSyncEngine(repository: repository, dataSource: dataSource);
  });

  tearDown(() async {
    await database.close();
  });

  test(
    'local create uploads stable Case ID and marks it synchronized',
    () async {
      final id = await repository.createCase(
        caseTitle: 'New Case',
        caseNumber: 'CNR-NEW',
        clientName: 'Client',
        opponentName: 'Opponent',
        courtName: 'District Court',
        caseType: 'Civil',
        status: 'active',
        handledBy: 'Advocate',
      );
      final localBefore = await repository.getCaseById(id);

      final result = await engine.sync();

      expect(result.uploaded, 1);
      expect(dataSource.documents.keys, [id]);
      expect(dataSource.documents[id]!['ownerUid'], 'user-a');
      expect(localBefore!.id, id);
      expect((await repository.getCaseById(id))!.syncState, 'synced');
      expect(await repository.getPendingCaseChanges(), isEmpty);
    },
  );

  test('local update, star, archive, and restore are uploaded', () async {
    final record = buildRecord(
      id: 'case-actions',
      ownerUid: 'user-a',
      updatedAt: now,
    );
    await repository.saveCase(record);
    await engine.sync();

    await repository.saveCase(
      record.copyWith(
        caseTitle: 'Updated Case',
        updatedAt: now.add(const Duration(minutes: 1)),
      ),
    );
    await engine.sync();
    expect(dataSource.documents['case-actions']!['caseTitle'], 'Updated Case');

    await repository.setCaseStarred('case-actions', true);
    await engine.sync();
    expect(dataSource.documents['case-actions']!['isStarred'], isTrue);

    await repository.softDeleteCase('case-actions');
    await engine.sync();
    expect(dataSource.documents['case-actions']!['isDeleted'], isTrue);
    expect(dataSource.documents['case-actions']!['status'], 'deleted');

    await repository.restoreCase('case-actions');
    await engine.sync();
    expect(dataSource.documents['case-actions']!['isDeleted'], isFalse);
    expect(dataSource.documents['case-actions']!['status'], 'active');
  });

  test('remote owned Case is imported into local storage', () async {
    final remote = buildRecord(
      id: 'remote-case',
      ownerUid: 'user-a',
      updatedAt: now,
    );
    dataSource.documents[remote.id] = remote.toCloudMap(cloudVersion: 3);

    final result = await engine.sync();
    final local = await repository.getCaseById(remote.id);

    expect(result.downloaded, 1);
    expect(local, isNotNull);
    expect(local!.syncState, 'synced');
    expect(local.cloudVersion, 3);
    expect(local.caseTitle, remote.caseTitle);
  });

  test(
    'repeated sync is idempotent after the pending change is acknowledged',
    () async {
      await repository.saveCase(
        buildRecord(id: 'repeat-case', ownerUid: 'user-a', updatedAt: now),
      );

      final first = await engine.sync();
      final writesAfterFirst = dataSource.writeCount;
      final second = await engine.sync();

      expect(first.uploaded, 1);
      expect(second.uploaded, 0);
      expect(dataSource.writeCount, writesAfterFirst);
      expect(
        (await repository.getCaseById('repeat-case'))!.syncState,
        'synced',
      );
    },
  );

  test('failed upload remains retryable with diagnostic state', () async {
    await repository.saveCase(
      buildRecord(id: 'retry-case', ownerUid: 'user-a', updatedAt: now),
    );
    dataSource.failWrites = true;

    final failed = await engine.sync();
    final pendingAfterFailure = await repository.getPendingCaseChanges();
    final localAfterFailure = await repository.getCaseById('retry-case');

    expect(failed.failed, 1);
    expect(pendingAfterFailure, hasLength(1));
    expect(pendingAfterFailure.single.attemptCount, 1);
    expect(pendingAfterFailure.single.record.syncState, 'failed');
    expect(
      localAfterFailure!.syncError,
      contains('Injected cloud write failure'),
    );

    dataSource.failWrites = false;
    final retried = await engine.sync();
    expect(retried.uploaded, 1);
    expect(await repository.getPendingCaseChanges(), isEmpty);
    expect((await repository.getCaseById('retry-case'))!.syncState, 'synced');
  });

  test(
    'foreign remote Case is rejected and never imported or overwritten',
    () async {
      final foreign = buildRecord(
        id: 'foreign-case',
        ownerUid: 'user-b',
        updatedAt: now,
      );
      dataSource.documents[foreign.id] = foreign.toCloudMap(cloudVersion: 1);
      dataSource.returnForeignDocuments = true;
      await repository.saveCase(
        buildRecord(id: foreign.id, ownerUid: 'user-a', updatedAt: now),
      );

      final result = await engine.sync();

      expect(result.failed, 1);
      expect(result.rejected, 1);
      expect(dataSource.documents[foreign.id]!['ownerUid'], 'user-b');
      expect(await repository.getCaseById(foreign.id), isNotNull);
      expect((await repository.getCaseById(foreign.id))!.syncState, 'failed');
    },
  );

  test('newer local Case wins over stale remote data', () async {
    final local = buildRecord(
      id: 'newer-local',
      ownerUid: 'user-a',
      updatedAt: now.add(const Duration(hours: 1)),
      title: 'New local value',
    );
    await repository.saveCase(local);
    dataSource.documents[local.id] = buildRecord(
      id: local.id,
      ownerUid: 'user-a',
      updatedAt: now,
      title: 'Stale cloud value',
    ).toCloudMap(cloudVersion: 4);

    await engine.sync();

    expect(
      (await repository.getCaseById(local.id))!.caseTitle,
      'New local value',
    );
    expect(dataSource.documents[local.id]!['caseTitle'], 'New local value');
    expect((await repository.getCaseById(local.id))!.syncState, 'synced');
  });

  test(
    'newer cloud conflict preserves local data and stores remote snapshot',
    () async {
      final local = buildRecord(
        id: 'conflict-case',
        ownerUid: 'user-a',
        updatedAt: now,
        title: 'Local version',
      );
      await repository.saveCase(local);
      final remoteData = buildRecord(
        id: local.id,
        ownerUid: 'user-a',
        updatedAt: now.add(const Duration(hours: 1)),
        title: 'Cloud version',
      ).toCloudMap(cloudVersion: 2);
      dataSource.documents[local.id] = remoteData;

      final result = await engine.sync();
      final stored = await repository.getCaseById(local.id);

      expect(result.conflicts, 1);
      expect(stored!.caseTitle, 'Local version');
      expect(stored.syncState, 'conflict');
      expect(stored.conflictRemoteData, contains('Cloud version'));
      expect(dataSource.documents[local.id]!['caseTitle'], 'Cloud version');
    },
  );
}
