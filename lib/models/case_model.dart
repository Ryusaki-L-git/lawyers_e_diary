import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents an attached file/document on a case.
class CaseDocumentModel {
  const CaseDocumentModel({
    required this.name,
    required this.type,
    this.size = '1.2 MB',
    this.url,
  });

  final String name;
  final String type;
  final String size;
  final String? url;

  factory CaseDocumentModel.fromMap(Map<String, dynamic> map) {
    return CaseDocumentModel(
      name: map['name'] as String? ?? 'Document.pdf',
      type: map['type'] as String? ?? 'PDF',
      size: map['size'] as String? ?? '1.2 MB',
      url: map['url'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'type': type,
      'size': size,
      if (url != null) 'url': url,
    };
  }
}

/// Core model representing a legal case docket in Lawyer's E-Diary.
class CaseModel {
  const CaseModel({
    required this.id,
    required this.caseTitle,
    required this.caseNumber,
    required this.clientName,
    this.opponentName = '',
    this.courtName = 'Court Room 3',
    this.caseType = 'Civil Case',
    this.status = 'active',
    this.nextHearingDate,
    this.handledBy = 'Advocate',
    this.userId = '',
    this.clientPhone,
    this.documents = const [],
    this.notes = const [],
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  final String id;
  final String caseTitle;
  final String caseNumber;
  final String clientName;
  final String opponentName;
  final String courtName;
  final String caseType;
  final String status; // active, upcoming, urgent, completed, deleted
  final DateTime? nextHearingDate;
  final String handledBy;
  final String userId;
  final String? clientPhone;
  final List<CaseDocumentModel> documents;
  final List<String> notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;

  bool get isDeleted => status.toLowerCase() == 'deleted';
  bool get isCompleted => status.toLowerCase() == 'completed';
  bool get isActive => status.toLowerCase() == 'active';
  bool get isUpcoming => status.toLowerCase() == 'upcoming';
  bool get isUrgent => status.toLowerCase() == 'urgent';

  factory CaseModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data() ?? {};
    return CaseModel.fromMap(snapshot.id, data);
  }

  factory CaseModel.fromMap(String id, Map<String, dynamic> data) {
    DateTime? parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is DateTime) return val;
      if (val is String) return DateTime.tryParse(val);
      return null;
    }

    final rawDocs = data['documents'];
    final docList = <CaseDocumentModel>[];
    if (rawDocs is List) {
      for (final item in rawDocs) {
        if (item is Map<String, dynamic>) {
          docList.add(CaseDocumentModel.fromMap(item));
        } else if (item is String) {
          docList.add(CaseDocumentModel(name: item, type: 'Document'));
        }
      }
    }

    final rawNotes = data['notes'];
    final noteList = <String>[];
    if (rawNotes is List) {
      for (final n in rawNotes) {
        if (n != null) noteList.add(n.toString());
      }
    }

    return CaseModel(
      id: id,
      caseTitle: data['caseTitle'] as String? ??
          data['title'] as String? ??
          'Untitled Case',
      caseNumber: data['cnrNumber'] as String? ??
          data['caseNumber'] as String? ??
          'ID: C-2024-001',
      clientName: data['clientName'] as String? ?? 'Client',
      opponentName: data['opponentName'] as String? ?? '',
      courtName: data['courtName'] as String? ?? 'High Court',
      caseType: data['caseType'] as String? ?? 'Civil Case',
      status: (data['status'] as String? ?? 'active').toLowerCase(),
      nextHearingDate: parseDate(data['nextHearingDate']),
      handledBy: data['handledBy'] as String? ?? 'Adv. Counsel',
      userId: data['userId'] as String? ?? '',
      clientPhone: data['clientPhone'] as String? ??
          data['phone'] as String? ??
          data['whatsappNumber'] as String?,
      documents: docList,
      notes: noteList,
      createdAt: parseDate(data['createdAt']),
      updatedAt: parseDate(data['updatedAt'] ?? data['lastUpdated']),
      deletedAt: parseDate(data['deletedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'caseTitle': caseTitle,
      'cnrNumber': caseNumber,
      'clientName': clientName,
      'opponentName': opponentName,
      'courtName': courtName,
      'caseType': caseType,
      'status': status,
      if (nextHearingDate != null)
        'nextHearingDate': Timestamp.fromDate(nextHearingDate!),
      'handledBy': handledBy,
      'userId': userId,
      if (clientPhone != null) 'clientPhone': clientPhone,
      'documents': documents.map((d) => d.toMap()).toList(),
      'notes': notes,
      if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
      if (updatedAt != null) 'updatedAt': Timestamp.fromDate(updatedAt!),
      if (deletedAt != null) 'deletedAt': Timestamp.fromDate(deletedAt!),
    };
  }

  CaseModel copyWith({
    String? caseTitle,
    String? caseNumber,
    String? clientName,
    String? opponentName,
    String? courtName,
    String? caseType,
    String? status,
    DateTime? nextHearingDate,
    String? handledBy,
    String? userId,
    String? clientPhone,
    List<CaseDocumentModel>? documents,
    List<String>? notes,
    DateTime? deletedAt,
  }) {
    return CaseModel(
      id: id,
      caseTitle: caseTitle ?? this.caseTitle,
      caseNumber: caseNumber ?? this.caseNumber,
      clientName: clientName ?? this.clientName,
      opponentName: opponentName ?? this.opponentName,
      courtName: courtName ?? this.courtName,
      caseType: caseType ?? this.caseType,
      status: status ?? this.status,
      nextHearingDate: nextHearingDate ?? this.nextHearingDate,
      handledBy: handledBy ?? this.handledBy,
      userId: userId ?? this.userId,
      clientPhone: clientPhone ?? this.clientPhone,
      documents: documents ?? this.documents,
      notes: notes ?? this.notes,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}
