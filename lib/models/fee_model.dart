import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a single service/charge line item in a fee calculation.
class FeeLineItem {
  const FeeLineItem({
    required this.serviceName,
    required this.rate,
    this.quantity = 1,
  });

  final String serviceName;
  final double rate;
  final int quantity;

  double get subtotal => rate * quantity;

  factory FeeLineItem.fromMap(Map<String, dynamic> map) {
    return FeeLineItem(
      serviceName: map['serviceName'] as String? ?? 'Legal Service',
      rate: (map['rate'] as num?)?.toDouble() ?? 0.0,
      quantity: (map['quantity'] as num?)?.toInt() ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'serviceName': serviceName,
      'rate': rate,
      'quantity': quantity,
      'subtotal': subtotal,
    };
  }

  FeeLineItem copyWith({String? serviceName, double? rate, int? quantity}) {
    return FeeLineItem(
      serviceName: serviceName ?? this.serviceName,
      rate: rate ?? this.rate,
      quantity: quantity ?? this.quantity,
    );
  }
}

/// Payment status of a fee record.
enum FeeStatus { quoted, partiallyPaid, settled }

extension FeeStatusExt on FeeStatus {
  String get value {
    switch (this) {
      case FeeStatus.quoted:
        return 'quoted';
      case FeeStatus.partiallyPaid:
        return 'partially_paid';
      case FeeStatus.settled:
        return 'settled';
    }
  }

  String get label {
    switch (this) {
      case FeeStatus.quoted:
        return 'Quoted';
      case FeeStatus.partiallyPaid:
        return 'Partially Paid';
      case FeeStatus.settled:
        return 'Settled';
    }
  }

  static FeeStatus fromString(String? value) {
    switch (value) {
      case 'partially_paid':
        return FeeStatus.partiallyPaid;
      case 'settled':
        return FeeStatus.settled;
      default:
        return FeeStatus.quoted;
    }
  }
}

/// A single payment transaction recorded against a fee.
class FeeTransaction {
  const FeeTransaction({
    required this.id,
    required this.amount,
    required this.paymentDate,
    this.paymentMode = 'Cash',
    this.receiptNumber,
  });

  final String id;
  final double amount;
  final DateTime paymentDate;
  final String paymentMode;
  final String? receiptNumber;

  factory FeeTransaction.fromMap(String id, Map<String, dynamic> map) {
    DateTime? parseDate(dynamic v) {
      if (v is Timestamp) return v.toDate();
      if (v is DateTime) return v;
      if (v is String) return DateTime.tryParse(v);
      return null;
    }

    return FeeTransaction(
      id: id,
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      paymentDate: parseDate(map['paymentDate']) ?? DateTime.now(),
      paymentMode: map['paymentMode'] as String? ?? 'Cash',
      receiptNumber: map['receiptNumber'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'amount': amount,
      'paymentDate': Timestamp.fromDate(paymentDate),
      'paymentMode': paymentMode,
      if (receiptNumber != null) 'receiptNumber': receiptNumber,
    };
  }
}

/// Domain model for a fee record linked to a client/case.
class FeeModel {
  const FeeModel({
    required this.id,
    required this.userId,
    required this.clientName,
    required this.caseTitle,
    required this.services,
    this.caseId,
    this.agreedTotal = 0.0,
    this.collectedTotal = 0.0,
    this.status = FeeStatus.quoted,
    this.notes,
    this.createdAt,
    this.updatedAt,
    this.transactions = const [],
  });

  final String id;
  final String userId;
  final String clientName;
  final String caseTitle;
  final String? caseId;
  final List<FeeLineItem> services;
  final double agreedTotal;
  final double collectedTotal;
  final FeeStatus status;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// In-memory transactions (loaded separately from subcollection)
  final List<FeeTransaction> transactions;

  double get pendingTotal => (agreedTotal - collectedTotal).clamp(0.0, double.infinity);
  double get calculatedTotal => services.fold(0.0, (s, i) => s + i.subtotal);

  factory FeeModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data() ?? {};
    return FeeModel.fromMap(snapshot.id, data);
  }

  factory FeeModel.fromMap(String id, Map<String, dynamic> data) {
    DateTime? parseDate(dynamic v) {
      if (v is Timestamp) return v.toDate();
      if (v is DateTime) return v;
      if (v is String) return DateTime.tryParse(v);
      return null;
    }

    final rawServices = data['services'];
    final serviceList = <FeeLineItem>[];
    if (rawServices is List) {
      for (final item in rawServices) {
        if (item is Map<String, dynamic>) {
          serviceList.add(FeeLineItem.fromMap(item));
        }
      }
    }

    return FeeModel(
      id: id,
      userId: data['userId'] as String? ?? '',
      clientName: data['clientName'] as String? ?? 'Client',
      caseTitle: data['caseTitle'] as String? ?? 'Untitled Case',
      caseId: data['caseId'] as String?,
      services: serviceList,
      agreedTotal: (data['agreedTotal'] as num?)?.toDouble() ?? 0.0,
      collectedTotal: (data['collectedTotal'] as num?)?.toDouble() ?? 0.0,
      status: FeeStatusExt.fromString(data['status'] as String?),
      notes: data['notes'] as String?,
      createdAt: parseDate(data['createdAt']),
      updatedAt: parseDate(data['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'clientName': clientName,
      'caseTitle': caseTitle,
      if (caseId != null) 'caseId': caseId,
      'services': services.map((s) => s.toMap()).toList(),
      'agreedTotal': agreedTotal,
      'collectedTotal': collectedTotal,
      'pendingTotal': pendingTotal,
      'status': status.value,
      if (notes != null) 'notes': notes,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  FeeModel copyWith({
    String? clientName,
    String? caseTitle,
    String? caseId,
    List<FeeLineItem>? services,
    double? agreedTotal,
    double? collectedTotal,
    FeeStatus? status,
    String? notes,
  }) {
    return FeeModel(
      id: id,
      userId: userId,
      clientName: clientName ?? this.clientName,
      caseTitle: caseTitle ?? this.caseTitle,
      caseId: caseId ?? this.caseId,
      services: services ?? this.services,
      agreedTotal: agreedTotal ?? this.agreedTotal,
      collectedTotal: collectedTotal ?? this.collectedTotal,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
