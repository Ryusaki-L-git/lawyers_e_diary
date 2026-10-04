import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

class LocalCases extends Table {
  TextColumn get id => text()();
  TextColumn get ownerUid => text()();
  TextColumn get caseNumber => text()();
  TextColumn get caseTitle => text()();
  TextColumn get clientName => text()();
  TextColumn get opponentName => text().withDefault(const Constant(''))();
  TextColumn get courtName => text()();
  TextColumn get caseType => text()();
  TextColumn get status => text()();
  DateTimeColumn get nextHearingDate => dateTime().nullable()();
  TextColumn get handledBy => text()();
  TextColumn get clientPhone => text().nullable()();
  BoolColumn get isStarred => boolean().withDefault(const Constant(false))();
  TextColumn get documents => text().withDefault(const Constant('[]'))();
  TextColumn get notes => text().withDefault(const Constant('[]'))();
  TextColumn get assignedUserUid => text().nullable()();
  TextColumn get teamId => text().nullable()();
  TextColumn get cnr => text().nullable()();
  TextColumn get caseSource => text().withDefault(const Constant('manual'))();
  TextColumn get lifecycleMode =>
      text().withDefault(const Constant('manual'))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  TextColumn get syncState => text().withDefault(const Constant('pending'))();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();
  IntColumn get cloudVersion => integer().nullable()();
  TextColumn get cloudId => text().nullable()();
  TextColumn get syncError => text().nullable()();
  TextColumn get conflictRemoteData => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class LocalCaseChanges extends Table {
  TextColumn get caseId => text()();
  TextColumn get ownerUid => text()();
  IntColumn get revision => integer().withDefault(const Constant(1))();
  TextColumn get operation => text()();
  DateTimeColumn get changedAt => dateTime()();
  IntColumn get attemptCount => integer().withDefault(const Constant(0))();
  TextColumn get lastError => text().nullable()();

  @override
  Set<Column> get primaryKey => {caseId};
}

class LocalClients extends Table {
  TextColumn get id => text()();
  TextColumn get ownerUid => text()();
  TextColumn get name => text()();
  TextColumn get type => text().withDefault(const Constant('Individual'))();
  TextColumn get phone => text().withDefault(const Constant(''))();
  TextColumn get email => text().withDefault(const Constant(''))();
  TextColumn get address => text().withDefault(const Constant(''))();
  TextColumn get notes => text().withDefault(const Constant(''))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  TextColumn get syncState => text().withDefault(const Constant('pending'))();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();
  IntColumn get cloudVersion => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [LocalCases, LocalClients, LocalCaseChanges])
class AppDatabase extends _$AppDatabase {
  static final AppDatabase instance = AppDatabase();

  AppDatabase() : super(_openConnection());

  AppDatabase.memory() : super(NativeDatabase.memory());

  static QueryExecutor _openConnection() {
    return LazyDatabase(() async {
      final documentsDirectory = await getApplicationDocumentsDirectory();
      final path = p.join(documentsDirectory.path, 'led_local.db');
      return NativeDatabase(File(path));
    });
  }

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
    },
    onUpgrade: (m, from, to) async {
      if (from < 1) {
        await m.createAll();
      } else if (from < 2) {
        await m.addColumn(localCases, localCases.cloudId);
        await m.addColumn(localCases, localCases.syncError);
        await m.addColumn(localCases, localCases.conflictRemoteData);
        await m.createTable(localCaseChanges);
      }
    },
  );
}
