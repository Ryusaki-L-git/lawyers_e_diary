// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $LocalCasesTable extends LocalCases
    with TableInfo<$LocalCasesTable, LocalCase> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalCasesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerUidMeta = const VerificationMeta(
    'ownerUid',
  );
  @override
  late final GeneratedColumn<String> ownerUid = GeneratedColumn<String>(
    'owner_uid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _caseNumberMeta = const VerificationMeta(
    'caseNumber',
  );
  @override
  late final GeneratedColumn<String> caseNumber = GeneratedColumn<String>(
    'case_number',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _caseTitleMeta = const VerificationMeta(
    'caseTitle',
  );
  @override
  late final GeneratedColumn<String> caseTitle = GeneratedColumn<String>(
    'case_title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _clientNameMeta = const VerificationMeta(
    'clientName',
  );
  @override
  late final GeneratedColumn<String> clientName = GeneratedColumn<String>(
    'client_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _opponentNameMeta = const VerificationMeta(
    'opponentName',
  );
  @override
  late final GeneratedColumn<String> opponentName = GeneratedColumn<String>(
    'opponent_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _courtNameMeta = const VerificationMeta(
    'courtName',
  );
  @override
  late final GeneratedColumn<String> courtName = GeneratedColumn<String>(
    'court_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _caseTypeMeta = const VerificationMeta(
    'caseType',
  );
  @override
  late final GeneratedColumn<String> caseType = GeneratedColumn<String>(
    'case_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nextHearingDateMeta = const VerificationMeta(
    'nextHearingDate',
  );
  @override
  late final GeneratedColumn<DateTime> nextHearingDate =
      GeneratedColumn<DateTime>(
        'next_hearing_date',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _handledByMeta = const VerificationMeta(
    'handledBy',
  );
  @override
  late final GeneratedColumn<String> handledBy = GeneratedColumn<String>(
    'handled_by',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _clientPhoneMeta = const VerificationMeta(
    'clientPhone',
  );
  @override
  late final GeneratedColumn<String> clientPhone = GeneratedColumn<String>(
    'client_phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isStarredMeta = const VerificationMeta(
    'isStarred',
  );
  @override
  late final GeneratedColumn<bool> isStarred = GeneratedColumn<bool>(
    'is_starred',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_starred" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _documentsMeta = const VerificationMeta(
    'documents',
  );
  @override
  late final GeneratedColumn<String> documents = GeneratedColumn<String>(
    'documents',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _assignedUserUidMeta = const VerificationMeta(
    'assignedUserUid',
  );
  @override
  late final GeneratedColumn<String> assignedUserUid = GeneratedColumn<String>(
    'assigned_user_uid',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _teamIdMeta = const VerificationMeta('teamId');
  @override
  late final GeneratedColumn<String> teamId = GeneratedColumn<String>(
    'team_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cnrMeta = const VerificationMeta('cnr');
  @override
  late final GeneratedColumn<String> cnr = GeneratedColumn<String>(
    'cnr',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _caseSourceMeta = const VerificationMeta(
    'caseSource',
  );
  @override
  late final GeneratedColumn<String> caseSource = GeneratedColumn<String>(
    'case_source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('manual'),
  );
  static const VerificationMeta _lifecycleModeMeta = const VerificationMeta(
    'lifecycleMode',
  );
  @override
  late final GeneratedColumn<String> lifecycleMode = GeneratedColumn<String>(
    'lifecycle_mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('manual'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _syncStateMeta = const VerificationMeta(
    'syncState',
  );
  @override
  late final GeneratedColumn<String> syncState = GeneratedColumn<String>(
    'sync_state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _lastSyncedAtMeta = const VerificationMeta(
    'lastSyncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
    'last_synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cloudVersionMeta = const VerificationMeta(
    'cloudVersion',
  );
  @override
  late final GeneratedColumn<int> cloudVersion = GeneratedColumn<int>(
    'cloud_version',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cloudIdMeta = const VerificationMeta(
    'cloudId',
  );
  @override
  late final GeneratedColumn<String> cloudId = GeneratedColumn<String>(
    'cloud_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncErrorMeta = const VerificationMeta(
    'syncError',
  );
  @override
  late final GeneratedColumn<String> syncError = GeneratedColumn<String>(
    'sync_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _conflictRemoteDataMeta =
      const VerificationMeta('conflictRemoteData');
  @override
  late final GeneratedColumn<String> conflictRemoteData =
      GeneratedColumn<String>(
        'conflict_remote_data',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ownerUid,
    caseNumber,
    caseTitle,
    clientName,
    opponentName,
    courtName,
    caseType,
    status,
    nextHearingDate,
    handledBy,
    clientPhone,
    isStarred,
    documents,
    notes,
    assignedUserUid,
    teamId,
    cnr,
    caseSource,
    lifecycleMode,
    createdAt,
    updatedAt,
    deletedAt,
    isDeleted,
    syncState,
    lastSyncedAt,
    cloudVersion,
    cloudId,
    syncError,
    conflictRemoteData,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_cases';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalCase> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('owner_uid')) {
      context.handle(
        _ownerUidMeta,
        ownerUid.isAcceptableOrUnknown(data['owner_uid']!, _ownerUidMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerUidMeta);
    }
    if (data.containsKey('case_number')) {
      context.handle(
        _caseNumberMeta,
        caseNumber.isAcceptableOrUnknown(data['case_number']!, _caseNumberMeta),
      );
    } else if (isInserting) {
      context.missing(_caseNumberMeta);
    }
    if (data.containsKey('case_title')) {
      context.handle(
        _caseTitleMeta,
        caseTitle.isAcceptableOrUnknown(data['case_title']!, _caseTitleMeta),
      );
    } else if (isInserting) {
      context.missing(_caseTitleMeta);
    }
    if (data.containsKey('client_name')) {
      context.handle(
        _clientNameMeta,
        clientName.isAcceptableOrUnknown(data['client_name']!, _clientNameMeta),
      );
    } else if (isInserting) {
      context.missing(_clientNameMeta);
    }
    if (data.containsKey('opponent_name')) {
      context.handle(
        _opponentNameMeta,
        opponentName.isAcceptableOrUnknown(
          data['opponent_name']!,
          _opponentNameMeta,
        ),
      );
    }
    if (data.containsKey('court_name')) {
      context.handle(
        _courtNameMeta,
        courtName.isAcceptableOrUnknown(data['court_name']!, _courtNameMeta),
      );
    } else if (isInserting) {
      context.missing(_courtNameMeta);
    }
    if (data.containsKey('case_type')) {
      context.handle(
        _caseTypeMeta,
        caseType.isAcceptableOrUnknown(data['case_type']!, _caseTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_caseTypeMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('next_hearing_date')) {
      context.handle(
        _nextHearingDateMeta,
        nextHearingDate.isAcceptableOrUnknown(
          data['next_hearing_date']!,
          _nextHearingDateMeta,
        ),
      );
    }
    if (data.containsKey('handled_by')) {
      context.handle(
        _handledByMeta,
        handledBy.isAcceptableOrUnknown(data['handled_by']!, _handledByMeta),
      );
    } else if (isInserting) {
      context.missing(_handledByMeta);
    }
    if (data.containsKey('client_phone')) {
      context.handle(
        _clientPhoneMeta,
        clientPhone.isAcceptableOrUnknown(
          data['client_phone']!,
          _clientPhoneMeta,
        ),
      );
    }
    if (data.containsKey('is_starred')) {
      context.handle(
        _isStarredMeta,
        isStarred.isAcceptableOrUnknown(data['is_starred']!, _isStarredMeta),
      );
    }
    if (data.containsKey('documents')) {
      context.handle(
        _documentsMeta,
        documents.isAcceptableOrUnknown(data['documents']!, _documentsMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('assigned_user_uid')) {
      context.handle(
        _assignedUserUidMeta,
        assignedUserUid.isAcceptableOrUnknown(
          data['assigned_user_uid']!,
          _assignedUserUidMeta,
        ),
      );
    }
    if (data.containsKey('team_id')) {
      context.handle(
        _teamIdMeta,
        teamId.isAcceptableOrUnknown(data['team_id']!, _teamIdMeta),
      );
    }
    if (data.containsKey('cnr')) {
      context.handle(
        _cnrMeta,
        cnr.isAcceptableOrUnknown(data['cnr']!, _cnrMeta),
      );
    }
    if (data.containsKey('case_source')) {
      context.handle(
        _caseSourceMeta,
        caseSource.isAcceptableOrUnknown(data['case_source']!, _caseSourceMeta),
      );
    }
    if (data.containsKey('lifecycle_mode')) {
      context.handle(
        _lifecycleModeMeta,
        lifecycleMode.isAcceptableOrUnknown(
          data['lifecycle_mode']!,
          _lifecycleModeMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('sync_state')) {
      context.handle(
        _syncStateMeta,
        syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta),
      );
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
        _lastSyncedAtMeta,
        lastSyncedAt.isAcceptableOrUnknown(
          data['last_synced_at']!,
          _lastSyncedAtMeta,
        ),
      );
    }
    if (data.containsKey('cloud_version')) {
      context.handle(
        _cloudVersionMeta,
        cloudVersion.isAcceptableOrUnknown(
          data['cloud_version']!,
          _cloudVersionMeta,
        ),
      );
    }
    if (data.containsKey('cloud_id')) {
      context.handle(
        _cloudIdMeta,
        cloudId.isAcceptableOrUnknown(data['cloud_id']!, _cloudIdMeta),
      );
    }
    if (data.containsKey('sync_error')) {
      context.handle(
        _syncErrorMeta,
        syncError.isAcceptableOrUnknown(data['sync_error']!, _syncErrorMeta),
      );
    }
    if (data.containsKey('conflict_remote_data')) {
      context.handle(
        _conflictRemoteDataMeta,
        conflictRemoteData.isAcceptableOrUnknown(
          data['conflict_remote_data']!,
          _conflictRemoteDataMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalCase map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalCase(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      ownerUid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_uid'],
      )!,
      caseNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}case_number'],
      )!,
      caseTitle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}case_title'],
      )!,
      clientName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}client_name'],
      )!,
      opponentName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}opponent_name'],
      )!,
      courtName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}court_name'],
      )!,
      caseType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}case_type'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      nextHearingDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}next_hearing_date'],
      ),
      handledBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}handled_by'],
      )!,
      clientPhone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}client_phone'],
      ),
      isStarred: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_starred'],
      )!,
      documents: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}documents'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      )!,
      assignedUserUid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}assigned_user_uid'],
      ),
      teamId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}team_id'],
      ),
      cnr: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cnr'],
      ),
      caseSource: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}case_source'],
      )!,
      lifecycleMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lifecycle_mode'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      syncState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_state'],
      )!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_synced_at'],
      ),
      cloudVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cloud_version'],
      ),
      cloudId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cloud_id'],
      ),
      syncError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_error'],
      ),
      conflictRemoteData: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}conflict_remote_data'],
      ),
    );
  }

  @override
  $LocalCasesTable createAlias(String alias) {
    return $LocalCasesTable(attachedDatabase, alias);
  }
}

class LocalCase extends DataClass implements Insertable<LocalCase> {
  final String id;
  final String ownerUid;
  final String caseNumber;
  final String caseTitle;
  final String clientName;
  final String opponentName;
  final String courtName;
  final String caseType;
  final String status;
  final DateTime? nextHearingDate;
  final String handledBy;
  final String? clientPhone;
  final bool isStarred;
  final String documents;
  final String notes;
  final String? assignedUserUid;
  final String? teamId;
  final String? cnr;
  final String caseSource;
  final String lifecycleMode;
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
  const LocalCase({
    required this.id,
    required this.ownerUid,
    required this.caseNumber,
    required this.caseTitle,
    required this.clientName,
    required this.opponentName,
    required this.courtName,
    required this.caseType,
    required this.status,
    this.nextHearingDate,
    required this.handledBy,
    this.clientPhone,
    required this.isStarred,
    required this.documents,
    required this.notes,
    this.assignedUserUid,
    this.teamId,
    this.cnr,
    required this.caseSource,
    required this.lifecycleMode,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.isDeleted,
    required this.syncState,
    this.lastSyncedAt,
    this.cloudVersion,
    this.cloudId,
    this.syncError,
    this.conflictRemoteData,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['owner_uid'] = Variable<String>(ownerUid);
    map['case_number'] = Variable<String>(caseNumber);
    map['case_title'] = Variable<String>(caseTitle);
    map['client_name'] = Variable<String>(clientName);
    map['opponent_name'] = Variable<String>(opponentName);
    map['court_name'] = Variable<String>(courtName);
    map['case_type'] = Variable<String>(caseType);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || nextHearingDate != null) {
      map['next_hearing_date'] = Variable<DateTime>(nextHearingDate);
    }
    map['handled_by'] = Variable<String>(handledBy);
    if (!nullToAbsent || clientPhone != null) {
      map['client_phone'] = Variable<String>(clientPhone);
    }
    map['is_starred'] = Variable<bool>(isStarred);
    map['documents'] = Variable<String>(documents);
    map['notes'] = Variable<String>(notes);
    if (!nullToAbsent || assignedUserUid != null) {
      map['assigned_user_uid'] = Variable<String>(assignedUserUid);
    }
    if (!nullToAbsent || teamId != null) {
      map['team_id'] = Variable<String>(teamId);
    }
    if (!nullToAbsent || cnr != null) {
      map['cnr'] = Variable<String>(cnr);
    }
    map['case_source'] = Variable<String>(caseSource);
    map['lifecycle_mode'] = Variable<String>(lifecycleMode);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['sync_state'] = Variable<String>(syncState);
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    if (!nullToAbsent || cloudVersion != null) {
      map['cloud_version'] = Variable<int>(cloudVersion);
    }
    if (!nullToAbsent || cloudId != null) {
      map['cloud_id'] = Variable<String>(cloudId);
    }
    if (!nullToAbsent || syncError != null) {
      map['sync_error'] = Variable<String>(syncError);
    }
    if (!nullToAbsent || conflictRemoteData != null) {
      map['conflict_remote_data'] = Variable<String>(conflictRemoteData);
    }
    return map;
  }

  LocalCasesCompanion toCompanion(bool nullToAbsent) {
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
      nextHearingDate: nextHearingDate == null && nullToAbsent
          ? const Value.absent()
          : Value(nextHearingDate),
      handledBy: Value(handledBy),
      clientPhone: clientPhone == null && nullToAbsent
          ? const Value.absent()
          : Value(clientPhone),
      isStarred: Value(isStarred),
      documents: Value(documents),
      notes: Value(notes),
      assignedUserUid: assignedUserUid == null && nullToAbsent
          ? const Value.absent()
          : Value(assignedUserUid),
      teamId: teamId == null && nullToAbsent
          ? const Value.absent()
          : Value(teamId),
      cnr: cnr == null && nullToAbsent ? const Value.absent() : Value(cnr),
      caseSource: Value(caseSource),
      lifecycleMode: Value(lifecycleMode),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      isDeleted: Value(isDeleted),
      syncState: Value(syncState),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
      cloudVersion: cloudVersion == null && nullToAbsent
          ? const Value.absent()
          : Value(cloudVersion),
      cloudId: cloudId == null && nullToAbsent
          ? const Value.absent()
          : Value(cloudId),
      syncError: syncError == null && nullToAbsent
          ? const Value.absent()
          : Value(syncError),
      conflictRemoteData: conflictRemoteData == null && nullToAbsent
          ? const Value.absent()
          : Value(conflictRemoteData),
    );
  }

  factory LocalCase.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalCase(
      id: serializer.fromJson<String>(json['id']),
      ownerUid: serializer.fromJson<String>(json['ownerUid']),
      caseNumber: serializer.fromJson<String>(json['caseNumber']),
      caseTitle: serializer.fromJson<String>(json['caseTitle']),
      clientName: serializer.fromJson<String>(json['clientName']),
      opponentName: serializer.fromJson<String>(json['opponentName']),
      courtName: serializer.fromJson<String>(json['courtName']),
      caseType: serializer.fromJson<String>(json['caseType']),
      status: serializer.fromJson<String>(json['status']),
      nextHearingDate: serializer.fromJson<DateTime?>(json['nextHearingDate']),
      handledBy: serializer.fromJson<String>(json['handledBy']),
      clientPhone: serializer.fromJson<String?>(json['clientPhone']),
      isStarred: serializer.fromJson<bool>(json['isStarred']),
      documents: serializer.fromJson<String>(json['documents']),
      notes: serializer.fromJson<String>(json['notes']),
      assignedUserUid: serializer.fromJson<String?>(json['assignedUserUid']),
      teamId: serializer.fromJson<String?>(json['teamId']),
      cnr: serializer.fromJson<String?>(json['cnr']),
      caseSource: serializer.fromJson<String>(json['caseSource']),
      lifecycleMode: serializer.fromJson<String>(json['lifecycleMode']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      syncState: serializer.fromJson<String>(json['syncState']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
      cloudVersion: serializer.fromJson<int?>(json['cloudVersion']),
      cloudId: serializer.fromJson<String?>(json['cloudId']),
      syncError: serializer.fromJson<String?>(json['syncError']),
      conflictRemoteData: serializer.fromJson<String?>(
        json['conflictRemoteData'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'ownerUid': serializer.toJson<String>(ownerUid),
      'caseNumber': serializer.toJson<String>(caseNumber),
      'caseTitle': serializer.toJson<String>(caseTitle),
      'clientName': serializer.toJson<String>(clientName),
      'opponentName': serializer.toJson<String>(opponentName),
      'courtName': serializer.toJson<String>(courtName),
      'caseType': serializer.toJson<String>(caseType),
      'status': serializer.toJson<String>(status),
      'nextHearingDate': serializer.toJson<DateTime?>(nextHearingDate),
      'handledBy': serializer.toJson<String>(handledBy),
      'clientPhone': serializer.toJson<String?>(clientPhone),
      'isStarred': serializer.toJson<bool>(isStarred),
      'documents': serializer.toJson<String>(documents),
      'notes': serializer.toJson<String>(notes),
      'assignedUserUid': serializer.toJson<String?>(assignedUserUid),
      'teamId': serializer.toJson<String?>(teamId),
      'cnr': serializer.toJson<String?>(cnr),
      'caseSource': serializer.toJson<String>(caseSource),
      'lifecycleMode': serializer.toJson<String>(lifecycleMode),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'syncState': serializer.toJson<String>(syncState),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
      'cloudVersion': serializer.toJson<int?>(cloudVersion),
      'cloudId': serializer.toJson<String?>(cloudId),
      'syncError': serializer.toJson<String?>(syncError),
      'conflictRemoteData': serializer.toJson<String?>(conflictRemoteData),
    };
  }

  LocalCase copyWith({
    String? id,
    String? ownerUid,
    String? caseNumber,
    String? caseTitle,
    String? clientName,
    String? opponentName,
    String? courtName,
    String? caseType,
    String? status,
    Value<DateTime?> nextHearingDate = const Value.absent(),
    String? handledBy,
    Value<String?> clientPhone = const Value.absent(),
    bool? isStarred,
    String? documents,
    String? notes,
    Value<String?> assignedUserUid = const Value.absent(),
    Value<String?> teamId = const Value.absent(),
    Value<String?> cnr = const Value.absent(),
    String? caseSource,
    String? lifecycleMode,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    bool? isDeleted,
    String? syncState,
    Value<DateTime?> lastSyncedAt = const Value.absent(),
    Value<int?> cloudVersion = const Value.absent(),
    Value<String?> cloudId = const Value.absent(),
    Value<String?> syncError = const Value.absent(),
    Value<String?> conflictRemoteData = const Value.absent(),
  }) => LocalCase(
    id: id ?? this.id,
    ownerUid: ownerUid ?? this.ownerUid,
    caseNumber: caseNumber ?? this.caseNumber,
    caseTitle: caseTitle ?? this.caseTitle,
    clientName: clientName ?? this.clientName,
    opponentName: opponentName ?? this.opponentName,
    courtName: courtName ?? this.courtName,
    caseType: caseType ?? this.caseType,
    status: status ?? this.status,
    nextHearingDate: nextHearingDate.present
        ? nextHearingDate.value
        : this.nextHearingDate,
    handledBy: handledBy ?? this.handledBy,
    clientPhone: clientPhone.present ? clientPhone.value : this.clientPhone,
    isStarred: isStarred ?? this.isStarred,
    documents: documents ?? this.documents,
    notes: notes ?? this.notes,
    assignedUserUid: assignedUserUid.present
        ? assignedUserUid.value
        : this.assignedUserUid,
    teamId: teamId.present ? teamId.value : this.teamId,
    cnr: cnr.present ? cnr.value : this.cnr,
    caseSource: caseSource ?? this.caseSource,
    lifecycleMode: lifecycleMode ?? this.lifecycleMode,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    isDeleted: isDeleted ?? this.isDeleted,
    syncState: syncState ?? this.syncState,
    lastSyncedAt: lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
    cloudVersion: cloudVersion.present ? cloudVersion.value : this.cloudVersion,
    cloudId: cloudId.present ? cloudId.value : this.cloudId,
    syncError: syncError.present ? syncError.value : this.syncError,
    conflictRemoteData: conflictRemoteData.present
        ? conflictRemoteData.value
        : this.conflictRemoteData,
  );
  LocalCase copyWithCompanion(LocalCasesCompanion data) {
    return LocalCase(
      id: data.id.present ? data.id.value : this.id,
      ownerUid: data.ownerUid.present ? data.ownerUid.value : this.ownerUid,
      caseNumber: data.caseNumber.present
          ? data.caseNumber.value
          : this.caseNumber,
      caseTitle: data.caseTitle.present ? data.caseTitle.value : this.caseTitle,
      clientName: data.clientName.present
          ? data.clientName.value
          : this.clientName,
      opponentName: data.opponentName.present
          ? data.opponentName.value
          : this.opponentName,
      courtName: data.courtName.present ? data.courtName.value : this.courtName,
      caseType: data.caseType.present ? data.caseType.value : this.caseType,
      status: data.status.present ? data.status.value : this.status,
      nextHearingDate: data.nextHearingDate.present
          ? data.nextHearingDate.value
          : this.nextHearingDate,
      handledBy: data.handledBy.present ? data.handledBy.value : this.handledBy,
      clientPhone: data.clientPhone.present
          ? data.clientPhone.value
          : this.clientPhone,
      isStarred: data.isStarred.present ? data.isStarred.value : this.isStarred,
      documents: data.documents.present ? data.documents.value : this.documents,
      notes: data.notes.present ? data.notes.value : this.notes,
      assignedUserUid: data.assignedUserUid.present
          ? data.assignedUserUid.value
          : this.assignedUserUid,
      teamId: data.teamId.present ? data.teamId.value : this.teamId,
      cnr: data.cnr.present ? data.cnr.value : this.cnr,
      caseSource: data.caseSource.present
          ? data.caseSource.value
          : this.caseSource,
      lifecycleMode: data.lifecycleMode.present
          ? data.lifecycleMode.value
          : this.lifecycleMode,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
      cloudVersion: data.cloudVersion.present
          ? data.cloudVersion.value
          : this.cloudVersion,
      cloudId: data.cloudId.present ? data.cloudId.value : this.cloudId,
      syncError: data.syncError.present ? data.syncError.value : this.syncError,
      conflictRemoteData: data.conflictRemoteData.present
          ? data.conflictRemoteData.value
          : this.conflictRemoteData,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalCase(')
          ..write('id: $id, ')
          ..write('ownerUid: $ownerUid, ')
          ..write('caseNumber: $caseNumber, ')
          ..write('caseTitle: $caseTitle, ')
          ..write('clientName: $clientName, ')
          ..write('opponentName: $opponentName, ')
          ..write('courtName: $courtName, ')
          ..write('caseType: $caseType, ')
          ..write('status: $status, ')
          ..write('nextHearingDate: $nextHearingDate, ')
          ..write('handledBy: $handledBy, ')
          ..write('clientPhone: $clientPhone, ')
          ..write('isStarred: $isStarred, ')
          ..write('documents: $documents, ')
          ..write('notes: $notes, ')
          ..write('assignedUserUid: $assignedUserUid, ')
          ..write('teamId: $teamId, ')
          ..write('cnr: $cnr, ')
          ..write('caseSource: $caseSource, ')
          ..write('lifecycleMode: $lifecycleMode, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('syncState: $syncState, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('cloudVersion: $cloudVersion, ')
          ..write('cloudId: $cloudId, ')
          ..write('syncError: $syncError, ')
          ..write('conflictRemoteData: $conflictRemoteData')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    ownerUid,
    caseNumber,
    caseTitle,
    clientName,
    opponentName,
    courtName,
    caseType,
    status,
    nextHearingDate,
    handledBy,
    clientPhone,
    isStarred,
    documents,
    notes,
    assignedUserUid,
    teamId,
    cnr,
    caseSource,
    lifecycleMode,
    createdAt,
    updatedAt,
    deletedAt,
    isDeleted,
    syncState,
    lastSyncedAt,
    cloudVersion,
    cloudId,
    syncError,
    conflictRemoteData,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalCase &&
          other.id == this.id &&
          other.ownerUid == this.ownerUid &&
          other.caseNumber == this.caseNumber &&
          other.caseTitle == this.caseTitle &&
          other.clientName == this.clientName &&
          other.opponentName == this.opponentName &&
          other.courtName == this.courtName &&
          other.caseType == this.caseType &&
          other.status == this.status &&
          other.nextHearingDate == this.nextHearingDate &&
          other.handledBy == this.handledBy &&
          other.clientPhone == this.clientPhone &&
          other.isStarred == this.isStarred &&
          other.documents == this.documents &&
          other.notes == this.notes &&
          other.assignedUserUid == this.assignedUserUid &&
          other.teamId == this.teamId &&
          other.cnr == this.cnr &&
          other.caseSource == this.caseSource &&
          other.lifecycleMode == this.lifecycleMode &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.isDeleted == this.isDeleted &&
          other.syncState == this.syncState &&
          other.lastSyncedAt == this.lastSyncedAt &&
          other.cloudVersion == this.cloudVersion &&
          other.cloudId == this.cloudId &&
          other.syncError == this.syncError &&
          other.conflictRemoteData == this.conflictRemoteData);
}

class LocalCasesCompanion extends UpdateCompanion<LocalCase> {
  final Value<String> id;
  final Value<String> ownerUid;
  final Value<String> caseNumber;
  final Value<String> caseTitle;
  final Value<String> clientName;
  final Value<String> opponentName;
  final Value<String> courtName;
  final Value<String> caseType;
  final Value<String> status;
  final Value<DateTime?> nextHearingDate;
  final Value<String> handledBy;
  final Value<String?> clientPhone;
  final Value<bool> isStarred;
  final Value<String> documents;
  final Value<String> notes;
  final Value<String?> assignedUserUid;
  final Value<String?> teamId;
  final Value<String?> cnr;
  final Value<String> caseSource;
  final Value<String> lifecycleMode;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<bool> isDeleted;
  final Value<String> syncState;
  final Value<DateTime?> lastSyncedAt;
  final Value<int?> cloudVersion;
  final Value<String?> cloudId;
  final Value<String?> syncError;
  final Value<String?> conflictRemoteData;
  final Value<int> rowid;
  const LocalCasesCompanion({
    this.id = const Value.absent(),
    this.ownerUid = const Value.absent(),
    this.caseNumber = const Value.absent(),
    this.caseTitle = const Value.absent(),
    this.clientName = const Value.absent(),
    this.opponentName = const Value.absent(),
    this.courtName = const Value.absent(),
    this.caseType = const Value.absent(),
    this.status = const Value.absent(),
    this.nextHearingDate = const Value.absent(),
    this.handledBy = const Value.absent(),
    this.clientPhone = const Value.absent(),
    this.isStarred = const Value.absent(),
    this.documents = const Value.absent(),
    this.notes = const Value.absent(),
    this.assignedUserUid = const Value.absent(),
    this.teamId = const Value.absent(),
    this.cnr = const Value.absent(),
    this.caseSource = const Value.absent(),
    this.lifecycleMode = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.syncState = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.cloudVersion = const Value.absent(),
    this.cloudId = const Value.absent(),
    this.syncError = const Value.absent(),
    this.conflictRemoteData = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalCasesCompanion.insert({
    required String id,
    required String ownerUid,
    required String caseNumber,
    required String caseTitle,
    required String clientName,
    this.opponentName = const Value.absent(),
    required String courtName,
    required String caseType,
    required String status,
    this.nextHearingDate = const Value.absent(),
    required String handledBy,
    this.clientPhone = const Value.absent(),
    this.isStarred = const Value.absent(),
    this.documents = const Value.absent(),
    this.notes = const Value.absent(),
    this.assignedUserUid = const Value.absent(),
    this.teamId = const Value.absent(),
    this.cnr = const Value.absent(),
    this.caseSource = const Value.absent(),
    this.lifecycleMode = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.syncState = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.cloudVersion = const Value.absent(),
    this.cloudId = const Value.absent(),
    this.syncError = const Value.absent(),
    this.conflictRemoteData = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       ownerUid = Value(ownerUid),
       caseNumber = Value(caseNumber),
       caseTitle = Value(caseTitle),
       clientName = Value(clientName),
       courtName = Value(courtName),
       caseType = Value(caseType),
       status = Value(status),
       handledBy = Value(handledBy),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<LocalCase> custom({
    Expression<String>? id,
    Expression<String>? ownerUid,
    Expression<String>? caseNumber,
    Expression<String>? caseTitle,
    Expression<String>? clientName,
    Expression<String>? opponentName,
    Expression<String>? courtName,
    Expression<String>? caseType,
    Expression<String>? status,
    Expression<DateTime>? nextHearingDate,
    Expression<String>? handledBy,
    Expression<String>? clientPhone,
    Expression<bool>? isStarred,
    Expression<String>? documents,
    Expression<String>? notes,
    Expression<String>? assignedUserUid,
    Expression<String>? teamId,
    Expression<String>? cnr,
    Expression<String>? caseSource,
    Expression<String>? lifecycleMode,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<bool>? isDeleted,
    Expression<String>? syncState,
    Expression<DateTime>? lastSyncedAt,
    Expression<int>? cloudVersion,
    Expression<String>? cloudId,
    Expression<String>? syncError,
    Expression<String>? conflictRemoteData,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ownerUid != null) 'owner_uid': ownerUid,
      if (caseNumber != null) 'case_number': caseNumber,
      if (caseTitle != null) 'case_title': caseTitle,
      if (clientName != null) 'client_name': clientName,
      if (opponentName != null) 'opponent_name': opponentName,
      if (courtName != null) 'court_name': courtName,
      if (caseType != null) 'case_type': caseType,
      if (status != null) 'status': status,
      if (nextHearingDate != null) 'next_hearing_date': nextHearingDate,
      if (handledBy != null) 'handled_by': handledBy,
      if (clientPhone != null) 'client_phone': clientPhone,
      if (isStarred != null) 'is_starred': isStarred,
      if (documents != null) 'documents': documents,
      if (notes != null) 'notes': notes,
      if (assignedUserUid != null) 'assigned_user_uid': assignedUserUid,
      if (teamId != null) 'team_id': teamId,
      if (cnr != null) 'cnr': cnr,
      if (caseSource != null) 'case_source': caseSource,
      if (lifecycleMode != null) 'lifecycle_mode': lifecycleMode,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (syncState != null) 'sync_state': syncState,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (cloudVersion != null) 'cloud_version': cloudVersion,
      if (cloudId != null) 'cloud_id': cloudId,
      if (syncError != null) 'sync_error': syncError,
      if (conflictRemoteData != null)
        'conflict_remote_data': conflictRemoteData,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalCasesCompanion copyWith({
    Value<String>? id,
    Value<String>? ownerUid,
    Value<String>? caseNumber,
    Value<String>? caseTitle,
    Value<String>? clientName,
    Value<String>? opponentName,
    Value<String>? courtName,
    Value<String>? caseType,
    Value<String>? status,
    Value<DateTime?>? nextHearingDate,
    Value<String>? handledBy,
    Value<String?>? clientPhone,
    Value<bool>? isStarred,
    Value<String>? documents,
    Value<String>? notes,
    Value<String?>? assignedUserUid,
    Value<String?>? teamId,
    Value<String?>? cnr,
    Value<String>? caseSource,
    Value<String>? lifecycleMode,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<bool>? isDeleted,
    Value<String>? syncState,
    Value<DateTime?>? lastSyncedAt,
    Value<int?>? cloudVersion,
    Value<String?>? cloudId,
    Value<String?>? syncError,
    Value<String?>? conflictRemoteData,
    Value<int>? rowid,
  }) {
    return LocalCasesCompanion(
      id: id ?? this.id,
      ownerUid: ownerUid ?? this.ownerUid,
      caseNumber: caseNumber ?? this.caseNumber,
      caseTitle: caseTitle ?? this.caseTitle,
      clientName: clientName ?? this.clientName,
      opponentName: opponentName ?? this.opponentName,
      courtName: courtName ?? this.courtName,
      caseType: caseType ?? this.caseType,
      status: status ?? this.status,
      nextHearingDate: nextHearingDate ?? this.nextHearingDate,
      handledBy: handledBy ?? this.handledBy,
      clientPhone: clientPhone ?? this.clientPhone,
      isStarred: isStarred ?? this.isStarred,
      documents: documents ?? this.documents,
      notes: notes ?? this.notes,
      assignedUserUid: assignedUserUid ?? this.assignedUserUid,
      teamId: teamId ?? this.teamId,
      cnr: cnr ?? this.cnr,
      caseSource: caseSource ?? this.caseSource,
      lifecycleMode: lifecycleMode ?? this.lifecycleMode,
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
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (ownerUid.present) {
      map['owner_uid'] = Variable<String>(ownerUid.value);
    }
    if (caseNumber.present) {
      map['case_number'] = Variable<String>(caseNumber.value);
    }
    if (caseTitle.present) {
      map['case_title'] = Variable<String>(caseTitle.value);
    }
    if (clientName.present) {
      map['client_name'] = Variable<String>(clientName.value);
    }
    if (opponentName.present) {
      map['opponent_name'] = Variable<String>(opponentName.value);
    }
    if (courtName.present) {
      map['court_name'] = Variable<String>(courtName.value);
    }
    if (caseType.present) {
      map['case_type'] = Variable<String>(caseType.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (nextHearingDate.present) {
      map['next_hearing_date'] = Variable<DateTime>(nextHearingDate.value);
    }
    if (handledBy.present) {
      map['handled_by'] = Variable<String>(handledBy.value);
    }
    if (clientPhone.present) {
      map['client_phone'] = Variable<String>(clientPhone.value);
    }
    if (isStarred.present) {
      map['is_starred'] = Variable<bool>(isStarred.value);
    }
    if (documents.present) {
      map['documents'] = Variable<String>(documents.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (assignedUserUid.present) {
      map['assigned_user_uid'] = Variable<String>(assignedUserUid.value);
    }
    if (teamId.present) {
      map['team_id'] = Variable<String>(teamId.value);
    }
    if (cnr.present) {
      map['cnr'] = Variable<String>(cnr.value);
    }
    if (caseSource.present) {
      map['case_source'] = Variable<String>(caseSource.value);
    }
    if (lifecycleMode.present) {
      map['lifecycle_mode'] = Variable<String>(lifecycleMode.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(syncState.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    if (cloudVersion.present) {
      map['cloud_version'] = Variable<int>(cloudVersion.value);
    }
    if (cloudId.present) {
      map['cloud_id'] = Variable<String>(cloudId.value);
    }
    if (syncError.present) {
      map['sync_error'] = Variable<String>(syncError.value);
    }
    if (conflictRemoteData.present) {
      map['conflict_remote_data'] = Variable<String>(conflictRemoteData.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalCasesCompanion(')
          ..write('id: $id, ')
          ..write('ownerUid: $ownerUid, ')
          ..write('caseNumber: $caseNumber, ')
          ..write('caseTitle: $caseTitle, ')
          ..write('clientName: $clientName, ')
          ..write('opponentName: $opponentName, ')
          ..write('courtName: $courtName, ')
          ..write('caseType: $caseType, ')
          ..write('status: $status, ')
          ..write('nextHearingDate: $nextHearingDate, ')
          ..write('handledBy: $handledBy, ')
          ..write('clientPhone: $clientPhone, ')
          ..write('isStarred: $isStarred, ')
          ..write('documents: $documents, ')
          ..write('notes: $notes, ')
          ..write('assignedUserUid: $assignedUserUid, ')
          ..write('teamId: $teamId, ')
          ..write('cnr: $cnr, ')
          ..write('caseSource: $caseSource, ')
          ..write('lifecycleMode: $lifecycleMode, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('syncState: $syncState, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('cloudVersion: $cloudVersion, ')
          ..write('cloudId: $cloudId, ')
          ..write('syncError: $syncError, ')
          ..write('conflictRemoteData: $conflictRemoteData, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalClientsTable extends LocalClients
    with TableInfo<$LocalClientsTable, LocalClient> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalClientsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerUidMeta = const VerificationMeta(
    'ownerUid',
  );
  @override
  late final GeneratedColumn<String> ownerUid = GeneratedColumn<String>(
    'owner_uid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Individual'),
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _addressMeta = const VerificationMeta(
    'address',
  );
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
    'address',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _syncStateMeta = const VerificationMeta(
    'syncState',
  );
  @override
  late final GeneratedColumn<String> syncState = GeneratedColumn<String>(
    'sync_state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _lastSyncedAtMeta = const VerificationMeta(
    'lastSyncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
    'last_synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cloudVersionMeta = const VerificationMeta(
    'cloudVersion',
  );
  @override
  late final GeneratedColumn<int> cloudVersion = GeneratedColumn<int>(
    'cloud_version',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ownerUid,
    name,
    type,
    phone,
    email,
    address,
    notes,
    createdAt,
    updatedAt,
    deletedAt,
    isDeleted,
    syncState,
    lastSyncedAt,
    cloudVersion,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_clients';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalClient> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('owner_uid')) {
      context.handle(
        _ownerUidMeta,
        ownerUid.isAcceptableOrUnknown(data['owner_uid']!, _ownerUidMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerUidMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    }
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('sync_state')) {
      context.handle(
        _syncStateMeta,
        syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta),
      );
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
        _lastSyncedAtMeta,
        lastSyncedAt.isAcceptableOrUnknown(
          data['last_synced_at']!,
          _lastSyncedAtMeta,
        ),
      );
    }
    if (data.containsKey('cloud_version')) {
      context.handle(
        _cloudVersionMeta,
        cloudVersion.isAcceptableOrUnknown(
          data['cloud_version']!,
          _cloudVersionMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalClient map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalClient(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      ownerUid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_uid'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      )!,
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      )!,
      address: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      syncState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_state'],
      )!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_synced_at'],
      ),
      cloudVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cloud_version'],
      ),
    );
  }

  @override
  $LocalClientsTable createAlias(String alias) {
    return $LocalClientsTable(attachedDatabase, alias);
  }
}

class LocalClient extends DataClass implements Insertable<LocalClient> {
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
  final DateTime? deletedAt;
  final bool isDeleted;
  final String syncState;
  final DateTime? lastSyncedAt;
  final int? cloudVersion;
  const LocalClient({
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
    this.deletedAt,
    required this.isDeleted,
    required this.syncState,
    this.lastSyncedAt,
    this.cloudVersion,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['owner_uid'] = Variable<String>(ownerUid);
    map['name'] = Variable<String>(name);
    map['type'] = Variable<String>(type);
    map['phone'] = Variable<String>(phone);
    map['email'] = Variable<String>(email);
    map['address'] = Variable<String>(address);
    map['notes'] = Variable<String>(notes);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['sync_state'] = Variable<String>(syncState);
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    if (!nullToAbsent || cloudVersion != null) {
      map['cloud_version'] = Variable<int>(cloudVersion);
    }
    return map;
  }

  LocalClientsCompanion toCompanion(bool nullToAbsent) {
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
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      isDeleted: Value(isDeleted),
      syncState: Value(syncState),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
      cloudVersion: cloudVersion == null && nullToAbsent
          ? const Value.absent()
          : Value(cloudVersion),
    );
  }

  factory LocalClient.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalClient(
      id: serializer.fromJson<String>(json['id']),
      ownerUid: serializer.fromJson<String>(json['ownerUid']),
      name: serializer.fromJson<String>(json['name']),
      type: serializer.fromJson<String>(json['type']),
      phone: serializer.fromJson<String>(json['phone']),
      email: serializer.fromJson<String>(json['email']),
      address: serializer.fromJson<String>(json['address']),
      notes: serializer.fromJson<String>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      syncState: serializer.fromJson<String>(json['syncState']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
      cloudVersion: serializer.fromJson<int?>(json['cloudVersion']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'ownerUid': serializer.toJson<String>(ownerUid),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<String>(type),
      'phone': serializer.toJson<String>(phone),
      'email': serializer.toJson<String>(email),
      'address': serializer.toJson<String>(address),
      'notes': serializer.toJson<String>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'syncState': serializer.toJson<String>(syncState),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
      'cloudVersion': serializer.toJson<int?>(cloudVersion),
    };
  }

  LocalClient copyWith({
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
    Value<DateTime?> deletedAt = const Value.absent(),
    bool? isDeleted,
    String? syncState,
    Value<DateTime?> lastSyncedAt = const Value.absent(),
    Value<int?> cloudVersion = const Value.absent(),
  }) => LocalClient(
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
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    isDeleted: isDeleted ?? this.isDeleted,
    syncState: syncState ?? this.syncState,
    lastSyncedAt: lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
    cloudVersion: cloudVersion.present ? cloudVersion.value : this.cloudVersion,
  );
  LocalClient copyWithCompanion(LocalClientsCompanion data) {
    return LocalClient(
      id: data.id.present ? data.id.value : this.id,
      ownerUid: data.ownerUid.present ? data.ownerUid.value : this.ownerUid,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      phone: data.phone.present ? data.phone.value : this.phone,
      email: data.email.present ? data.email.value : this.email,
      address: data.address.present ? data.address.value : this.address,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
      cloudVersion: data.cloudVersion.present
          ? data.cloudVersion.value
          : this.cloudVersion,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalClient(')
          ..write('id: $id, ')
          ..write('ownerUid: $ownerUid, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('address: $address, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('syncState: $syncState, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('cloudVersion: $cloudVersion')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    ownerUid,
    name,
    type,
    phone,
    email,
    address,
    notes,
    createdAt,
    updatedAt,
    deletedAt,
    isDeleted,
    syncState,
    lastSyncedAt,
    cloudVersion,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalClient &&
          other.id == this.id &&
          other.ownerUid == this.ownerUid &&
          other.name == this.name &&
          other.type == this.type &&
          other.phone == this.phone &&
          other.email == this.email &&
          other.address == this.address &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.isDeleted == this.isDeleted &&
          other.syncState == this.syncState &&
          other.lastSyncedAt == this.lastSyncedAt &&
          other.cloudVersion == this.cloudVersion);
}

class LocalClientsCompanion extends UpdateCompanion<LocalClient> {
  final Value<String> id;
  final Value<String> ownerUid;
  final Value<String> name;
  final Value<String> type;
  final Value<String> phone;
  final Value<String> email;
  final Value<String> address;
  final Value<String> notes;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<bool> isDeleted;
  final Value<String> syncState;
  final Value<DateTime?> lastSyncedAt;
  final Value<int?> cloudVersion;
  final Value<int> rowid;
  const LocalClientsCompanion({
    this.id = const Value.absent(),
    this.ownerUid = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
    this.address = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.syncState = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.cloudVersion = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalClientsCompanion.insert({
    required String id,
    required String ownerUid,
    required String name,
    this.type = const Value.absent(),
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
    this.address = const Value.absent(),
    this.notes = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.syncState = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.cloudVersion = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       ownerUid = Value(ownerUid),
       name = Value(name),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<LocalClient> custom({
    Expression<String>? id,
    Expression<String>? ownerUid,
    Expression<String>? name,
    Expression<String>? type,
    Expression<String>? phone,
    Expression<String>? email,
    Expression<String>? address,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<bool>? isDeleted,
    Expression<String>? syncState,
    Expression<DateTime>? lastSyncedAt,
    Expression<int>? cloudVersion,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ownerUid != null) 'owner_uid': ownerUid,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      if (address != null) 'address': address,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (syncState != null) 'sync_state': syncState,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (cloudVersion != null) 'cloud_version': cloudVersion,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalClientsCompanion copyWith({
    Value<String>? id,
    Value<String>? ownerUid,
    Value<String>? name,
    Value<String>? type,
    Value<String>? phone,
    Value<String>? email,
    Value<String>? address,
    Value<String>? notes,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<bool>? isDeleted,
    Value<String>? syncState,
    Value<DateTime?>? lastSyncedAt,
    Value<int?>? cloudVersion,
    Value<int>? rowid,
  }) {
    return LocalClientsCompanion(
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
      deletedAt: deletedAt ?? this.deletedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      syncState: syncState ?? this.syncState,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      cloudVersion: cloudVersion ?? this.cloudVersion,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (ownerUid.present) {
      map['owner_uid'] = Variable<String>(ownerUid.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(syncState.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    if (cloudVersion.present) {
      map['cloud_version'] = Variable<int>(cloudVersion.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalClientsCompanion(')
          ..write('id: $id, ')
          ..write('ownerUid: $ownerUid, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('address: $address, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('syncState: $syncState, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('cloudVersion: $cloudVersion, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalCaseChangesTable extends LocalCaseChanges
    with TableInfo<$LocalCaseChangesTable, LocalCaseChange> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalCaseChangesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _caseIdMeta = const VerificationMeta('caseId');
  @override
  late final GeneratedColumn<String> caseId = GeneratedColumn<String>(
    'case_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerUidMeta = const VerificationMeta(
    'ownerUid',
  );
  @override
  late final GeneratedColumn<String> ownerUid = GeneratedColumn<String>(
    'owner_uid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _revisionMeta = const VerificationMeta(
    'revision',
  );
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
    'revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _operationMeta = const VerificationMeta(
    'operation',
  );
  @override
  late final GeneratedColumn<String> operation = GeneratedColumn<String>(
    'operation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _changedAtMeta = const VerificationMeta(
    'changedAt',
  );
  @override
  late final GeneratedColumn<DateTime> changedAt = GeneratedColumn<DateTime>(
    'changed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _attemptCountMeta = const VerificationMeta(
    'attemptCount',
  );
  @override
  late final GeneratedColumn<int> attemptCount = GeneratedColumn<int>(
    'attempt_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    caseId,
    ownerUid,
    revision,
    operation,
    changedAt,
    attemptCount,
    lastError,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_case_changes';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalCaseChange> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('case_id')) {
      context.handle(
        _caseIdMeta,
        caseId.isAcceptableOrUnknown(data['case_id']!, _caseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_caseIdMeta);
    }
    if (data.containsKey('owner_uid')) {
      context.handle(
        _ownerUidMeta,
        ownerUid.isAcceptableOrUnknown(data['owner_uid']!, _ownerUidMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerUidMeta);
    }
    if (data.containsKey('revision')) {
      context.handle(
        _revisionMeta,
        revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta),
      );
    }
    if (data.containsKey('operation')) {
      context.handle(
        _operationMeta,
        operation.isAcceptableOrUnknown(data['operation']!, _operationMeta),
      );
    } else if (isInserting) {
      context.missing(_operationMeta);
    }
    if (data.containsKey('changed_at')) {
      context.handle(
        _changedAtMeta,
        changedAt.isAcceptableOrUnknown(data['changed_at']!, _changedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_changedAtMeta);
    }
    if (data.containsKey('attempt_count')) {
      context.handle(
        _attemptCountMeta,
        attemptCount.isAcceptableOrUnknown(
          data['attempt_count']!,
          _attemptCountMeta,
        ),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {caseId};
  @override
  LocalCaseChange map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalCaseChange(
      caseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}case_id'],
      )!,
      ownerUid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_uid'],
      )!,
      revision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision'],
      )!,
      operation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operation'],
      )!,
      changedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}changed_at'],
      )!,
      attemptCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempt_count'],
      )!,
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
    );
  }

  @override
  $LocalCaseChangesTable createAlias(String alias) {
    return $LocalCaseChangesTable(attachedDatabase, alias);
  }
}

class LocalCaseChange extends DataClass implements Insertable<LocalCaseChange> {
  final String caseId;
  final String ownerUid;
  final int revision;
  final String operation;
  final DateTime changedAt;
  final int attemptCount;
  final String? lastError;
  const LocalCaseChange({
    required this.caseId,
    required this.ownerUid,
    required this.revision,
    required this.operation,
    required this.changedAt,
    required this.attemptCount,
    this.lastError,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['case_id'] = Variable<String>(caseId);
    map['owner_uid'] = Variable<String>(ownerUid);
    map['revision'] = Variable<int>(revision);
    map['operation'] = Variable<String>(operation);
    map['changed_at'] = Variable<DateTime>(changedAt);
    map['attempt_count'] = Variable<int>(attemptCount);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    return map;
  }

  LocalCaseChangesCompanion toCompanion(bool nullToAbsent) {
    return LocalCaseChangesCompanion(
      caseId: Value(caseId),
      ownerUid: Value(ownerUid),
      revision: Value(revision),
      operation: Value(operation),
      changedAt: Value(changedAt),
      attemptCount: Value(attemptCount),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
    );
  }

  factory LocalCaseChange.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalCaseChange(
      caseId: serializer.fromJson<String>(json['caseId']),
      ownerUid: serializer.fromJson<String>(json['ownerUid']),
      revision: serializer.fromJson<int>(json['revision']),
      operation: serializer.fromJson<String>(json['operation']),
      changedAt: serializer.fromJson<DateTime>(json['changedAt']),
      attemptCount: serializer.fromJson<int>(json['attemptCount']),
      lastError: serializer.fromJson<String?>(json['lastError']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'caseId': serializer.toJson<String>(caseId),
      'ownerUid': serializer.toJson<String>(ownerUid),
      'revision': serializer.toJson<int>(revision),
      'operation': serializer.toJson<String>(operation),
      'changedAt': serializer.toJson<DateTime>(changedAt),
      'attemptCount': serializer.toJson<int>(attemptCount),
      'lastError': serializer.toJson<String?>(lastError),
    };
  }

  LocalCaseChange copyWith({
    String? caseId,
    String? ownerUid,
    int? revision,
    String? operation,
    DateTime? changedAt,
    int? attemptCount,
    Value<String?> lastError = const Value.absent(),
  }) => LocalCaseChange(
    caseId: caseId ?? this.caseId,
    ownerUid: ownerUid ?? this.ownerUid,
    revision: revision ?? this.revision,
    operation: operation ?? this.operation,
    changedAt: changedAt ?? this.changedAt,
    attemptCount: attemptCount ?? this.attemptCount,
    lastError: lastError.present ? lastError.value : this.lastError,
  );
  LocalCaseChange copyWithCompanion(LocalCaseChangesCompanion data) {
    return LocalCaseChange(
      caseId: data.caseId.present ? data.caseId.value : this.caseId,
      ownerUid: data.ownerUid.present ? data.ownerUid.value : this.ownerUid,
      revision: data.revision.present ? data.revision.value : this.revision,
      operation: data.operation.present ? data.operation.value : this.operation,
      changedAt: data.changedAt.present ? data.changedAt.value : this.changedAt,
      attemptCount: data.attemptCount.present
          ? data.attemptCount.value
          : this.attemptCount,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalCaseChange(')
          ..write('caseId: $caseId, ')
          ..write('ownerUid: $ownerUid, ')
          ..write('revision: $revision, ')
          ..write('operation: $operation, ')
          ..write('changedAt: $changedAt, ')
          ..write('attemptCount: $attemptCount, ')
          ..write('lastError: $lastError')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    caseId,
    ownerUid,
    revision,
    operation,
    changedAt,
    attemptCount,
    lastError,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalCaseChange &&
          other.caseId == this.caseId &&
          other.ownerUid == this.ownerUid &&
          other.revision == this.revision &&
          other.operation == this.operation &&
          other.changedAt == this.changedAt &&
          other.attemptCount == this.attemptCount &&
          other.lastError == this.lastError);
}

class LocalCaseChangesCompanion extends UpdateCompanion<LocalCaseChange> {
  final Value<String> caseId;
  final Value<String> ownerUid;
  final Value<int> revision;
  final Value<String> operation;
  final Value<DateTime> changedAt;
  final Value<int> attemptCount;
  final Value<String?> lastError;
  final Value<int> rowid;
  const LocalCaseChangesCompanion({
    this.caseId = const Value.absent(),
    this.ownerUid = const Value.absent(),
    this.revision = const Value.absent(),
    this.operation = const Value.absent(),
    this.changedAt = const Value.absent(),
    this.attemptCount = const Value.absent(),
    this.lastError = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalCaseChangesCompanion.insert({
    required String caseId,
    required String ownerUid,
    this.revision = const Value.absent(),
    required String operation,
    required DateTime changedAt,
    this.attemptCount = const Value.absent(),
    this.lastError = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : caseId = Value(caseId),
       ownerUid = Value(ownerUid),
       operation = Value(operation),
       changedAt = Value(changedAt);
  static Insertable<LocalCaseChange> custom({
    Expression<String>? caseId,
    Expression<String>? ownerUid,
    Expression<int>? revision,
    Expression<String>? operation,
    Expression<DateTime>? changedAt,
    Expression<int>? attemptCount,
    Expression<String>? lastError,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (caseId != null) 'case_id': caseId,
      if (ownerUid != null) 'owner_uid': ownerUid,
      if (revision != null) 'revision': revision,
      if (operation != null) 'operation': operation,
      if (changedAt != null) 'changed_at': changedAt,
      if (attemptCount != null) 'attempt_count': attemptCount,
      if (lastError != null) 'last_error': lastError,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalCaseChangesCompanion copyWith({
    Value<String>? caseId,
    Value<String>? ownerUid,
    Value<int>? revision,
    Value<String>? operation,
    Value<DateTime>? changedAt,
    Value<int>? attemptCount,
    Value<String?>? lastError,
    Value<int>? rowid,
  }) {
    return LocalCaseChangesCompanion(
      caseId: caseId ?? this.caseId,
      ownerUid: ownerUid ?? this.ownerUid,
      revision: revision ?? this.revision,
      operation: operation ?? this.operation,
      changedAt: changedAt ?? this.changedAt,
      attemptCount: attemptCount ?? this.attemptCount,
      lastError: lastError ?? this.lastError,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (caseId.present) {
      map['case_id'] = Variable<String>(caseId.value);
    }
    if (ownerUid.present) {
      map['owner_uid'] = Variable<String>(ownerUid.value);
    }
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (operation.present) {
      map['operation'] = Variable<String>(operation.value);
    }
    if (changedAt.present) {
      map['changed_at'] = Variable<DateTime>(changedAt.value);
    }
    if (attemptCount.present) {
      map['attempt_count'] = Variable<int>(attemptCount.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalCaseChangesCompanion(')
          ..write('caseId: $caseId, ')
          ..write('ownerUid: $ownerUid, ')
          ..write('revision: $revision, ')
          ..write('operation: $operation, ')
          ..write('changedAt: $changedAt, ')
          ..write('attemptCount: $attemptCount, ')
          ..write('lastError: $lastError, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $LocalCasesTable localCases = $LocalCasesTable(this);
  late final $LocalClientsTable localClients = $LocalClientsTable(this);
  late final $LocalCaseChangesTable localCaseChanges = $LocalCaseChangesTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    localCases,
    localClients,
    localCaseChanges,
  ];
}

typedef $$LocalCasesTableCreateCompanionBuilder = LocalCasesCompanion Function({
  required String id,
  required String ownerUid,
  required String caseNumber,
  required String caseTitle,
  required String clientName,
  Value<String> opponentName,
  required String courtName,
  required String caseType,
  required String status,
  Value<DateTime?> nextHearingDate,
  required String handledBy,
  Value<String?> clientPhone,
  Value<bool> isStarred,
  Value<String> documents,
  Value<String> notes,
  Value<String?> assignedUserUid,
  Value<String?> teamId,
  Value<String?> cnr,
  Value<String> caseSource,
  Value<String> lifecycleMode,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<DateTime?> deletedAt,
  Value<bool> isDeleted,
  Value<String> syncState,
  Value<DateTime?> lastSyncedAt,
  Value<int?> cloudVersion,
  Value<String?> cloudId,
  Value<String?> syncError,
  Value<String?> conflictRemoteData,
  Value<int> rowid,
});
typedef $$LocalCasesTableUpdateCompanionBuilder = LocalCasesCompanion Function({
  Value<String> id,
  Value<String> ownerUid,
  Value<String> caseNumber,
  Value<String> caseTitle,
  Value<String> clientName,
  Value<String> opponentName,
  Value<String> courtName,
  Value<String> caseType,
  Value<String> status,
  Value<DateTime?> nextHearingDate,
  Value<String> handledBy,
  Value<String?> clientPhone,
  Value<bool> isStarred,
  Value<String> documents,
  Value<String> notes,
  Value<String?> assignedUserUid,
  Value<String?> teamId,
  Value<String?> cnr,
  Value<String> caseSource,
  Value<String> lifecycleMode,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<bool> isDeleted,
  Value<String> syncState,
  Value<DateTime?> lastSyncedAt,
  Value<int?> cloudVersion,
  Value<String?> cloudId,
  Value<String?> syncError,
  Value<String?> conflictRemoteData,
  Value<int> rowid,
});

class $$LocalCasesTableFilterComposer
    extends Composer<_$AppDatabase, $LocalCasesTable> {
  $$LocalCasesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerUid => $composableBuilder(
    column: $table.ownerUid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get caseNumber => $composableBuilder(
    column: $table.caseNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get caseTitle => $composableBuilder(
    column: $table.caseTitle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get clientName => $composableBuilder(
    column: $table.clientName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get opponentName => $composableBuilder(
    column: $table.opponentName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get courtName => $composableBuilder(
    column: $table.courtName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get caseType => $composableBuilder(
    column: $table.caseType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get nextHearingDate => $composableBuilder(
    column: $table.nextHearingDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get handledBy => $composableBuilder(
    column: $table.handledBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get clientPhone => $composableBuilder(
    column: $table.clientPhone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isStarred => $composableBuilder(
    column: $table.isStarred,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get documents => $composableBuilder(
    column: $table.documents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get assignedUserUid => $composableBuilder(
    column: $table.assignedUserUid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get teamId => $composableBuilder(
    column: $table.teamId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cnr => $composableBuilder(
    column: $table.cnr,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get caseSource => $composableBuilder(
    column: $table.caseSource,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lifecycleMode => $composableBuilder(
    column: $table.lifecycleMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cloudVersion => $composableBuilder(
    column: $table.cloudVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cloudId => $composableBuilder(
    column: $table.cloudId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncError => $composableBuilder(
    column: $table.syncError,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get conflictRemoteData => $composableBuilder(
    column: $table.conflictRemoteData,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalCasesTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalCasesTable> {
  $$LocalCasesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerUid => $composableBuilder(
    column: $table.ownerUid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get caseNumber => $composableBuilder(
    column: $table.caseNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get caseTitle => $composableBuilder(
    column: $table.caseTitle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get clientName => $composableBuilder(
    column: $table.clientName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get opponentName => $composableBuilder(
    column: $table.opponentName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get courtName => $composableBuilder(
    column: $table.courtName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get caseType => $composableBuilder(
    column: $table.caseType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get nextHearingDate => $composableBuilder(
    column: $table.nextHearingDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get handledBy => $composableBuilder(
    column: $table.handledBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get clientPhone => $composableBuilder(
    column: $table.clientPhone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isStarred => $composableBuilder(
    column: $table.isStarred,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get documents => $composableBuilder(
    column: $table.documents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get assignedUserUid => $composableBuilder(
    column: $table.assignedUserUid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get teamId => $composableBuilder(
    column: $table.teamId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cnr => $composableBuilder(
    column: $table.cnr,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get caseSource => $composableBuilder(
    column: $table.caseSource,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lifecycleMode => $composableBuilder(
    column: $table.lifecycleMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cloudVersion => $composableBuilder(
    column: $table.cloudVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cloudId => $composableBuilder(
    column: $table.cloudId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncError => $composableBuilder(
    column: $table.syncError,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get conflictRemoteData => $composableBuilder(
    column: $table.conflictRemoteData,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalCasesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalCasesTable> {
  $$LocalCasesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ownerUid =>
      $composableBuilder(column: $table.ownerUid, builder: (column) => column);

  GeneratedColumn<String> get caseNumber => $composableBuilder(
    column: $table.caseNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get caseTitle =>
      $composableBuilder(column: $table.caseTitle, builder: (column) => column);

  GeneratedColumn<String> get clientName => $composableBuilder(
    column: $table.clientName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get opponentName => $composableBuilder(
    column: $table.opponentName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get courtName =>
      $composableBuilder(column: $table.courtName, builder: (column) => column);

  GeneratedColumn<String> get caseType =>
      $composableBuilder(column: $table.caseType, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get nextHearingDate => $composableBuilder(
    column: $table.nextHearingDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get handledBy =>
      $composableBuilder(column: $table.handledBy, builder: (column) => column);

  GeneratedColumn<String> get clientPhone => $composableBuilder(
    column: $table.clientPhone,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isStarred =>
      $composableBuilder(column: $table.isStarred, builder: (column) => column);

  GeneratedColumn<String> get documents =>
      $composableBuilder(column: $table.documents, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get assignedUserUid => $composableBuilder(
    column: $table.assignedUserUid,
    builder: (column) => column,
  );

  GeneratedColumn<String> get teamId =>
      $composableBuilder(column: $table.teamId, builder: (column) => column);

  GeneratedColumn<String> get cnr =>
      $composableBuilder(column: $table.cnr, builder: (column) => column);

  GeneratedColumn<String> get caseSource => $composableBuilder(
    column: $table.caseSource,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lifecycleMode => $composableBuilder(
    column: $table.lifecycleMode,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get cloudVersion => $composableBuilder(
    column: $table.cloudVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get cloudId =>
      $composableBuilder(column: $table.cloudId, builder: (column) => column);

  GeneratedColumn<String> get syncError =>
      $composableBuilder(column: $table.syncError, builder: (column) => column);

  GeneratedColumn<String> get conflictRemoteData => $composableBuilder(
    column: $table.conflictRemoteData,
    builder: (column) => column,
  );
}

class $$LocalCasesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalCasesTable,
          LocalCase,
          $$LocalCasesTableFilterComposer,
          $$LocalCasesTableOrderingComposer,
          $$LocalCasesTableAnnotationComposer,
          $$LocalCasesTableCreateCompanionBuilder,
          $$LocalCasesTableUpdateCompanionBuilder,
          (
            LocalCase,
            BaseReferences<_$AppDatabase, $LocalCasesTable, LocalCase>,
          ),
          LocalCase,
          PrefetchHooks Function()
        > {
  $$LocalCasesTableTableManager(_$AppDatabase db, $LocalCasesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalCasesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalCasesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalCasesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> ownerUid = const Value.absent(),
                Value<String> caseNumber = const Value.absent(),
                Value<String> caseTitle = const Value.absent(),
                Value<String> clientName = const Value.absent(),
                Value<String> opponentName = const Value.absent(),
                Value<String> courtName = const Value.absent(),
                Value<String> caseType = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime?> nextHearingDate = const Value.absent(),
                Value<String> handledBy = const Value.absent(),
                Value<String?> clientPhone = const Value.absent(),
                Value<bool> isStarred = const Value.absent(),
                Value<String> documents = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<String?> assignedUserUid = const Value.absent(),
                Value<String?> teamId = const Value.absent(),
                Value<String?> cnr = const Value.absent(),
                Value<String> caseSource = const Value.absent(),
                Value<String> lifecycleMode = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<String> syncState = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                Value<int?> cloudVersion = const Value.absent(),
                Value<String?> cloudId = const Value.absent(),
                Value<String?> syncError = const Value.absent(),
                Value<String?> conflictRemoteData = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalCasesCompanion(
                id: id,
                ownerUid: ownerUid,
                caseNumber: caseNumber,
                caseTitle: caseTitle,
                clientName: clientName,
                opponentName: opponentName,
                courtName: courtName,
                caseType: caseType,
                status: status,
                nextHearingDate: nextHearingDate,
                handledBy: handledBy,
                clientPhone: clientPhone,
                isStarred: isStarred,
                documents: documents,
                notes: notes,
                assignedUserUid: assignedUserUid,
                teamId: teamId,
                cnr: cnr,
                caseSource: caseSource,
                lifecycleMode: lifecycleMode,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                isDeleted: isDeleted,
                syncState: syncState,
                lastSyncedAt: lastSyncedAt,
                cloudVersion: cloudVersion,
                cloudId: cloudId,
                syncError: syncError,
                conflictRemoteData: conflictRemoteData,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String ownerUid,
                required String caseNumber,
                required String caseTitle,
                required String clientName,
                Value<String> opponentName = const Value.absent(),
                required String courtName,
                required String caseType,
                required String status,
                Value<DateTime?> nextHearingDate = const Value.absent(),
                required String handledBy,
                Value<String?> clientPhone = const Value.absent(),
                Value<bool> isStarred = const Value.absent(),
                Value<String> documents = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<String?> assignedUserUid = const Value.absent(),
                Value<String?> teamId = const Value.absent(),
                Value<String?> cnr = const Value.absent(),
                Value<String> caseSource = const Value.absent(),
                Value<String> lifecycleMode = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<String> syncState = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                Value<int?> cloudVersion = const Value.absent(),
                Value<String?> cloudId = const Value.absent(),
                Value<String?> syncError = const Value.absent(),
                Value<String?> conflictRemoteData = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalCasesCompanion.insert(
                id: id,
                ownerUid: ownerUid,
                caseNumber: caseNumber,
                caseTitle: caseTitle,
                clientName: clientName,
                opponentName: opponentName,
                courtName: courtName,
                caseType: caseType,
                status: status,
                nextHearingDate: nextHearingDate,
                handledBy: handledBy,
                clientPhone: clientPhone,
                isStarred: isStarred,
                documents: documents,
                notes: notes,
                assignedUserUid: assignedUserUid,
                teamId: teamId,
                cnr: cnr,
                caseSource: caseSource,
                lifecycleMode: lifecycleMode,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                isDeleted: isDeleted,
                syncState: syncState,
                lastSyncedAt: lastSyncedAt,
                cloudVersion: cloudVersion,
                cloudId: cloudId,
                syncError: syncError,
                conflictRemoteData: conflictRemoteData,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LocalCasesTable, LocalCase>(table),
                  BaseReferences<_$AppDatabase, $LocalCasesTable, LocalCase>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalCasesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalCasesTable,
      LocalCase,
      $$LocalCasesTableFilterComposer,
      $$LocalCasesTableOrderingComposer,
      $$LocalCasesTableAnnotationComposer,
      $$LocalCasesTableCreateCompanionBuilder,
      $$LocalCasesTableUpdateCompanionBuilder,
      (LocalCase, BaseReferences<_$AppDatabase, $LocalCasesTable, LocalCase>),
      LocalCase,
      PrefetchHooks Function()
    >;
typedef $$LocalClientsTableCreateCompanionBuilder =
    LocalClientsCompanion Function({
      required String id,
      required String ownerUid,
      required String name,
      Value<String> type,
      Value<String> phone,
      Value<String> email,
      Value<String> address,
      Value<String> notes,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<bool> isDeleted,
      Value<String> syncState,
      Value<DateTime?> lastSyncedAt,
      Value<int?> cloudVersion,
      Value<int> rowid,
    });
typedef $$LocalClientsTableUpdateCompanionBuilder =
    LocalClientsCompanion Function({
      Value<String> id,
      Value<String> ownerUid,
      Value<String> name,
      Value<String> type,
      Value<String> phone,
      Value<String> email,
      Value<String> address,
      Value<String> notes,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<bool> isDeleted,
      Value<String> syncState,
      Value<DateTime?> lastSyncedAt,
      Value<int?> cloudVersion,
      Value<int> rowid,
    });

class $$LocalClientsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalClientsTable> {
  $$LocalClientsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerUid => $composableBuilder(
    column: $table.ownerUid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cloudVersion => $composableBuilder(
    column: $table.cloudVersion,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalClientsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalClientsTable> {
  $$LocalClientsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerUid => $composableBuilder(
    column: $table.ownerUid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cloudVersion => $composableBuilder(
    column: $table.cloudVersion,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalClientsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalClientsTable> {
  $$LocalClientsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ownerUid =>
      $composableBuilder(column: $table.ownerUid, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get cloudVersion => $composableBuilder(
    column: $table.cloudVersion,
    builder: (column) => column,
  );
}

class $$LocalClientsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalClientsTable,
          LocalClient,
          $$LocalClientsTableFilterComposer,
          $$LocalClientsTableOrderingComposer,
          $$LocalClientsTableAnnotationComposer,
          $$LocalClientsTableCreateCompanionBuilder,
          $$LocalClientsTableUpdateCompanionBuilder,
          (
            LocalClient,
            BaseReferences<_$AppDatabase, $LocalClientsTable, LocalClient>,
          ),
          LocalClient,
          PrefetchHooks Function()
        > {
  $$LocalClientsTableTableManager(_$AppDatabase db, $LocalClientsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalClientsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalClientsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalClientsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> ownerUid = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> phone = const Value.absent(),
                Value<String> email = const Value.absent(),
                Value<String> address = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<String> syncState = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                Value<int?> cloudVersion = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalClientsCompanion(
                id: id,
                ownerUid: ownerUid,
                name: name,
                type: type,
                phone: phone,
                email: email,
                address: address,
                notes: notes,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                isDeleted: isDeleted,
                syncState: syncState,
                lastSyncedAt: lastSyncedAt,
                cloudVersion: cloudVersion,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String ownerUid,
                required String name,
                Value<String> type = const Value.absent(),
                Value<String> phone = const Value.absent(),
                Value<String> email = const Value.absent(),
                Value<String> address = const Value.absent(),
                Value<String> notes = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<String> syncState = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                Value<int?> cloudVersion = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalClientsCompanion.insert(
                id: id,
                ownerUid: ownerUid,
                name: name,
                type: type,
                phone: phone,
                email: email,
                address: address,
                notes: notes,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                isDeleted: isDeleted,
                syncState: syncState,
                lastSyncedAt: lastSyncedAt,
                cloudVersion: cloudVersion,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LocalClientsTable, LocalClient>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $LocalClientsTable,
                    LocalClient
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalClientsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalClientsTable,
      LocalClient,
      $$LocalClientsTableFilterComposer,
      $$LocalClientsTableOrderingComposer,
      $$LocalClientsTableAnnotationComposer,
      $$LocalClientsTableCreateCompanionBuilder,
      $$LocalClientsTableUpdateCompanionBuilder,
      (
        LocalClient,
        BaseReferences<_$AppDatabase, $LocalClientsTable, LocalClient>,
      ),
      LocalClient,
      PrefetchHooks Function()
    >;
typedef $$LocalCaseChangesTableCreateCompanionBuilder =
    LocalCaseChangesCompanion Function({
      required String caseId,
      required String ownerUid,
      Value<int> revision,
      required String operation,
      required DateTime changedAt,
      Value<int> attemptCount,
      Value<String?> lastError,
      Value<int> rowid,
    });
typedef $$LocalCaseChangesTableUpdateCompanionBuilder =
    LocalCaseChangesCompanion Function({
      Value<String> caseId,
      Value<String> ownerUid,
      Value<int> revision,
      Value<String> operation,
      Value<DateTime> changedAt,
      Value<int> attemptCount,
      Value<String?> lastError,
      Value<int> rowid,
    });

class $$LocalCaseChangesTableFilterComposer
    extends Composer<_$AppDatabase, $LocalCaseChangesTable> {
  $$LocalCaseChangesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get caseId => $composableBuilder(
    column: $table.caseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerUid => $composableBuilder(
    column: $table.ownerUid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get changedAt => $composableBuilder(
    column: $table.changedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalCaseChangesTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalCaseChangesTable> {
  $$LocalCaseChangesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get caseId => $composableBuilder(
    column: $table.caseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerUid => $composableBuilder(
    column: $table.ownerUid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get changedAt => $composableBuilder(
    column: $table.changedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalCaseChangesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalCaseChangesTable> {
  $$LocalCaseChangesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get caseId =>
      $composableBuilder(column: $table.caseId, builder: (column) => column);

  GeneratedColumn<String> get ownerUid =>
      $composableBuilder(column: $table.ownerUid, builder: (column) => column);

  GeneratedColumn<int> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);

  GeneratedColumn<String> get operation =>
      $composableBuilder(column: $table.operation, builder: (column) => column);

  GeneratedColumn<DateTime> get changedAt =>
      $composableBuilder(column: $table.changedAt, builder: (column) => column);

  GeneratedColumn<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);
}

class $$LocalCaseChangesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalCaseChangesTable,
          LocalCaseChange,
          $$LocalCaseChangesTableFilterComposer,
          $$LocalCaseChangesTableOrderingComposer,
          $$LocalCaseChangesTableAnnotationComposer,
          $$LocalCaseChangesTableCreateCompanionBuilder,
          $$LocalCaseChangesTableUpdateCompanionBuilder,
          (
            LocalCaseChange,
            BaseReferences<
              _$AppDatabase,
              $LocalCaseChangesTable,
              LocalCaseChange
            >,
          ),
          LocalCaseChange,
          PrefetchHooks Function()
        > {
  $$LocalCaseChangesTableTableManager(
    _$AppDatabase db,
    $LocalCaseChangesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalCaseChangesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalCaseChangesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalCaseChangesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> caseId = const Value.absent(),
                Value<String> ownerUid = const Value.absent(),
                Value<int> revision = const Value.absent(),
                Value<String> operation = const Value.absent(),
                Value<DateTime> changedAt = const Value.absent(),
                Value<int> attemptCount = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalCaseChangesCompanion(
                caseId: caseId,
                ownerUid: ownerUid,
                revision: revision,
                operation: operation,
                changedAt: changedAt,
                attemptCount: attemptCount,
                lastError: lastError,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String caseId,
                required String ownerUid,
                Value<int> revision = const Value.absent(),
                required String operation,
                required DateTime changedAt,
                Value<int> attemptCount = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalCaseChangesCompanion.insert(
                caseId: caseId,
                ownerUid: ownerUid,
                revision: revision,
                operation: operation,
                changedAt: changedAt,
                attemptCount: attemptCount,
                lastError: lastError,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LocalCaseChangesTable, LocalCaseChange>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $LocalCaseChangesTable,
                    LocalCaseChange
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalCaseChangesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalCaseChangesTable,
      LocalCaseChange,
      $$LocalCaseChangesTableFilterComposer,
      $$LocalCaseChangesTableOrderingComposer,
      $$LocalCaseChangesTableAnnotationComposer,
      $$LocalCaseChangesTableCreateCompanionBuilder,
      $$LocalCaseChangesTableUpdateCompanionBuilder,
      (
        LocalCaseChange,
        BaseReferences<_$AppDatabase, $LocalCaseChangesTable, LocalCaseChange>,
      ),
      LocalCaseChange,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$LocalCasesTableTableManager get localCases =>
      $$LocalCasesTableTableManager(_db, _db.localCases);
  $$LocalClientsTableTableManager get localClients =>
      $$LocalClientsTableTableManager(_db, _db.localClients);
  $$LocalCaseChangesTableTableManager get localCaseChanges =>
      $$LocalCaseChangesTableTableManager(_db, _db.localCaseChanges);
}
