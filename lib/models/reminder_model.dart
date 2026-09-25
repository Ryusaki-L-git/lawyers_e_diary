import 'package:cloud_firestore/cloud_firestore.dart';

/// Repeat recurrence type for a reminder.
enum ReminderRepeat { none, daily, weekly, monthly }

extension ReminderRepeatExt on ReminderRepeat {
  String get value {
    switch (this) {
      case ReminderRepeat.none:
        return 'none';
      case ReminderRepeat.daily:
        return 'daily';
      case ReminderRepeat.weekly:
        return 'weekly';
      case ReminderRepeat.monthly:
        return 'monthly';
    }
  }

  String get label {
    switch (this) {
      case ReminderRepeat.none:
        return 'No Repeat';
      case ReminderRepeat.daily:
        return 'Daily';
      case ReminderRepeat.weekly:
        return 'Weekly';
      case ReminderRepeat.monthly:
        return 'Monthly';
    }
  }

  static ReminderRepeat fromString(String? value) {
    switch (value) {
      case 'daily':
        return ReminderRepeat.daily;
      case 'weekly':
        return ReminderRepeat.weekly;
      case 'monthly':
        return ReminderRepeat.monthly;
      default:
        return ReminderRepeat.none;
    }
  }
}

/// Domain model for a user reminder stored in Firestore `reminders` collection.
class ReminderModel {
  const ReminderModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.dueDateTime,
    this.description,
    this.caseId,
    this.caseTitle,
    this.clientName,
    this.repeatRule = ReminderRepeat.none,
    this.isCompleted = false,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String userId;
  final String title;
  final DateTime dueDateTime;
  final String? description;
  final String? caseId;
  final String? caseTitle;
  final String? clientName;
  final ReminderRepeat repeatRule;
  final bool isCompleted;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get isPending => !isCompleted && dueDateTime.isAfter(DateTime.now());
  bool get isOverdue => !isCompleted && dueDateTime.isBefore(DateTime.now());

  factory ReminderModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data() ?? {};
    return ReminderModel.fromMap(snapshot.id, data);
  }

  factory ReminderModel.fromMap(String id, Map<String, dynamic> data) {
    DateTime? parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is DateTime) return val;
      if (val is String) return DateTime.tryParse(val);
      return null;
    }

    return ReminderModel(
      id: id,
      userId: data['userId'] as String? ?? '',
      title: data['title'] as String? ?? 'Reminder',
      dueDateTime: parseDate(data['dueDateTime']) ?? DateTime.now(),
      description: data['description'] as String?,
      caseId: data['caseId'] as String?,
      caseTitle: data['caseTitle'] as String?,
      clientName: data['clientName'] as String?,
      repeatRule: ReminderRepeatExt.fromString(data['repeatRule'] as String?),
      isCompleted: data['isCompleted'] as bool? ?? false,
      createdAt: parseDate(data['createdAt']),
      updatedAt: parseDate(data['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'dueDateTime': Timestamp.fromDate(dueDateTime),
      if (description != null) 'description': description,
      if (caseId != null) 'caseId': caseId,
      if (caseTitle != null) 'caseTitle': caseTitle,
      if (clientName != null) 'clientName': clientName,
      'repeatRule': repeatRule.value,
      'isCompleted': isCompleted,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  ReminderModel copyWith({
    String? title,
    DateTime? dueDateTime,
    String? description,
    String? caseId,
    String? caseTitle,
    String? clientName,
    ReminderRepeat? repeatRule,
    bool? isCompleted,
  }) {
    return ReminderModel(
      id: id,
      userId: userId,
      title: title ?? this.title,
      dueDateTime: dueDateTime ?? this.dueDateTime,
      description: description ?? this.description,
      caseId: caseId ?? this.caseId,
      caseTitle: caseTitle ?? this.caseTitle,
      clientName: clientName ?? this.clientName,
      repeatRule: repeatRule ?? this.repeatRule,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
