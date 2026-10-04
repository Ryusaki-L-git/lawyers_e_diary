import 'package:cloud_firestore/cloud_firestore.dart';

/// Client legal entity in Lawyer's E-Diary.
class ClientModel {
  const ClientModel({
    required this.id,
    required this.userId,
    required this.name,
    this.type = 'Individual',
    this.phone = '',
    this.email = '',
    this.address = '',
    this.notes = '',
    this.isDeleted = false,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  final String id;
  final String userId;
  final String name;
  final String type; // 'Individual', 'Corporate', 'Government', 'Other'
  final String phone;
  final String email;
  final String address;
  final String notes;
  final bool isDeleted;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;

  factory ClientModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data() ?? {};
    return ClientModel.fromMap(snapshot.id, data);
  }

  factory ClientModel.fromMap(String id, Map<String, dynamic> data) {
    DateTime? parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is DateTime) return val;
      if (val is String) return DateTime.tryParse(val);
      return null;
    }

    return ClientModel(
      id: id,
      userId: data['userId'] as String? ?? '',
      name: data['name'] as String? ?? 'Unnamed Client',
      type: data['type'] as String? ?? 'Individual',
      phone: data['phone'] as String? ?? '',
      email: data['email'] as String? ?? '',
      address: data['address'] as String? ?? '',
      notes: data['notes'] as String? ?? '',
      isDeleted: data['isDeleted'] as bool? ?? false,
      createdAt: parseDate(data['createdAt']),
      updatedAt: parseDate(data['updatedAt']),
      deletedAt: parseDate(data['deletedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name.trim(),
      'type': type.trim(),
      'phone': phone.trim(),
      'email': email.trim(),
      'address': address.trim(),
      'notes': notes.trim(),
      'isDeleted': isDeleted,
      if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
      if (updatedAt != null) 'updatedAt': Timestamp.fromDate(updatedAt!),
      if (deletedAt != null) 'deletedAt': Timestamp.fromDate(deletedAt!),
    };
  }

  ClientModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? type,
    String? phone,
    String? email,
    String? address,
    String? notes,
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return ClientModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      type: type ?? this.type,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      notes: notes ?? this.notes,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}

