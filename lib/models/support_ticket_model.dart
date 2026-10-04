import 'package:cloud_firestore/cloud_firestore.dart';

/// In-app support request ticket model in Lawyer's E-Diary.
class SupportTicketModel {
  const SupportTicketModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.category,
    required this.subject,
    required this.message,
    this.status = 'pending',
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String userId;
  final String type; // 'inquiry', 'bug', 'feature', 'feedback'
  final String category; // 'Case Management', 'Cloud Sync', 'Billing & Fees', 'Other'
  final String subject;
  final String message;
  final String status; // 'pending', 'under_review', 'resolved'
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory SupportTicketModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data() ?? {};
    return SupportTicketModel.fromMap(snapshot.id, data);
  }

  factory SupportTicketModel.fromMap(String id, Map<String, dynamic> data) {
    DateTime? parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is DateTime) return val;
      if (val is String) return DateTime.tryParse(val);
      return null;
    }

    return SupportTicketModel(
      id: id,
      userId: data['userId'] as String? ?? '',
      type: data['type'] as String? ?? 'inquiry',
      category: data['category'] as String? ?? 'Other',
      subject: data['subject'] as String? ?? 'Support Request',
      message: data['message'] as String? ?? '',
      status: data['status'] as String? ?? 'pending',
      createdAt: parseDate(data['createdAt']),
      updatedAt: parseDate(data['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'type': type,
      'category': category,
      'subject': subject.trim(),
      'message': message.trim(),
      'status': status,
      if (createdAt != null)
        'createdAt': Timestamp.fromDate(createdAt!)
      else
        'createdAt': FieldValue.serverTimestamp(),
      if (updatedAt != null) 'updatedAt': Timestamp.fromDate(updatedAt!),
    };
  }

  SupportTicketModel copyWith({
    String? id,
    String? userId,
    String? type,
    String? category,
    String? subject,
    String? message,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SupportTicketModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      category: category ?? this.category,
      subject: subject ?? this.subject,
      message: message ?? this.message,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

