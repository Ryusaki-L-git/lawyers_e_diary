import 'package:cloud_firestore/cloud_firestore.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Role Enum
// ─────────────────────────────────────────────────────────────────────────────

enum TeamRole { owner, leader, member }

extension TeamRoleExt on TeamRole {
  String get value {
    switch (this) {
      case TeamRole.owner:
        return 'owner';
      case TeamRole.leader:
        return 'leader';
      case TeamRole.member:
        return 'member';
    }
  }

  String get label {
    switch (this) {
      case TeamRole.owner:
        return 'Owner';
      case TeamRole.leader:
        return 'Leader';
      case TeamRole.member:
        return 'Member';
    }
  }

  static TeamRole fromString(String? s) {
    switch (s) {
      case 'owner':
        return TeamRole.owner;
      case 'leader':
        return TeamRole.leader;
      default:
        return TeamRole.member;
    }
  }

  bool get canManageTeam => this == TeamRole.owner || this == TeamRole.leader;
  bool get isOwner => this == TeamRole.owner;
}

// ─────────────────────────────────────────────────────────────────────────────
// TeamModel  —  stored in  teams/{teamId}
// ─────────────────────────────────────────────────────────────────────────────

class TeamModel {
  const TeamModel({
    required this.id,
    required this.name,
    required this.ownerId,
    this.description = '',
    this.lawFirm = '',
    this.logoUrl,
    this.memberCount = 1,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String name;
  final String ownerId;
  final String description;
  final String lawFirm;
  final String? logoUrl;
  final int memberCount;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory TeamModel.fromMap(String id, Map<String, dynamic> data) {
    return TeamModel(
      id: id,
      name: data['name'] as String? ?? 'Unnamed Team',
      ownerId: data['ownerId'] as String? ?? '',
      description: data['description'] as String? ?? '',
      lawFirm: data['lawFirm'] as String? ?? '',
      logoUrl: data['logoUrl'] as String?,
      memberCount: (data['memberCount'] as int?) ?? 1,
      isActive: (data['isActive'] as bool?) ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'ownerId': ownerId,
        'description': description,
        'lawFirm': lawFirm,
        if (logoUrl != null) 'logoUrl': logoUrl,
        'memberCount': memberCount,
        'isActive': isActive,
        'updatedAt': FieldValue.serverTimestamp(),
      };

  TeamModel copyWith({
    String? name,
    String? description,
    String? lawFirm,
    String? logoUrl,
    int? memberCount,
    bool? isActive,
  }) =>
      TeamModel(
        id: id,
        ownerId: ownerId,
        name: name ?? this.name,
        description: description ?? this.description,
        lawFirm: lawFirm ?? this.lawFirm,
        logoUrl: logoUrl ?? this.logoUrl,
        memberCount: memberCount ?? this.memberCount,
        isActive: isActive ?? this.isActive,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// TeamMembership  —  stored in  teams/{teamId}/members/{memberDocumentId}
// ─────────────────────────────────────────────────────────────────────────────

class LedUserProfile {
  const LedUserProfile({
    required this.uid,
    required this.ledId,
    required this.name,
    this.email = '',
    this.phone = '',
    this.advocateType = '',
  });

  final String uid;
  final String ledId;
  final String name;
  final String email;
  final String phone;
  final String advocateType;

  factory LedUserProfile.fromMap(String uid, Map<String, dynamic> data) {
    return LedUserProfile(
      uid: uid,
      ledId: data['ledId'] as String? ?? '',
      name: data['name'] as String? ?? '',
      email: data['email'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      advocateType: data['advocateType'] as String? ?? '',
    );
  }
}

class TeamMembership {
  const TeamMembership({
    required this.userId,
    required this.teamId,
    required this.role,
    this.membershipDocumentId,
    this.hasFirebaseIdentity = true,
    this.displayName = '',
    this.email = '',
    this.phone = '',
    this.advocateType = '',
    this.isActive = true,
    this.invitedBy,
    this.joinedAt,
    this.permissions = const MemberPermissions(),
  });

  /// Firebase Auth UID; empty for legacy memberships without a user profile.
  final String userId;
  final String teamId;
  final TeamRole role;
  /// Actual document key retained for safe management of legacy membership docs.
  final String? membershipDocumentId;
  final bool hasFirebaseIdentity;
  final String displayName;
  final String email;
  final String phone;
  final String advocateType;
  final bool isActive;
  final String? invitedBy;
  final DateTime? joinedAt;
  final MemberPermissions permissions;

  String get initials {
    final parts = displayName.trim().split(' ');
    if (parts.isEmpty || displayName.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  factory TeamMembership.fromMap(
    String documentId,
    String teamId,
    Map<String, dynamic> data, {
    bool hasFirebaseIdentity = true,
    Map<String, dynamic>? userProfile,
  }) {
    final userId = hasFirebaseIdentity ? documentId : '';
    final storedName = data['displayName'] as String? ?? '';
    final storedEmail = data['email'] as String? ?? '';
    final storedPhone = data['phone'] as String? ?? '';
    final storedAdvocateType = data['advocateType'] as String? ?? '';
    final profileName = userProfile?['name'];
    final profileEmail = userProfile?['email'];
    final profilePhone = userProfile?['phone'];
    final profileAdvocateType = userProfile?['advocateType'];
    return TeamMembership(
      userId: userId,
      teamId: teamId,
      membershipDocumentId: documentId,
      hasFirebaseIdentity: hasFirebaseIdentity,
      role: TeamRoleExt.fromString(data['role'] as String?),
      displayName: hasFirebaseIdentity && profileName is String
          ? profileName
          : storedName,
      email: hasFirebaseIdentity && profileEmail is String
          ? profileEmail
          : storedEmail,
      phone: hasFirebaseIdentity && profilePhone is String
          ? profilePhone
          : storedPhone,
      advocateType:
          hasFirebaseIdentity && profileAdvocateType is String
              ? profileAdvocateType
              : storedAdvocateType,
      isActive: (data['isActive'] as bool?) ?? true,
      invitedBy: data['invitedBy'] as String?,
      joinedAt: (data['joinedAt'] as Timestamp?)?.toDate(),
      permissions: MemberPermissions.fromMap(data['permissions'] as Map<String, dynamic>?),
    );
  }

  Map<String, dynamic> toMap() => {
        if (userId.isNotEmpty) 'userId': userId,
        'teamId': teamId,
        'role': role.value,
        'displayName': displayName,
        'email': email,
        'phone': phone,
        'advocateType': advocateType,
        'isActive': isActive,
        if (invitedBy != null) 'invitedBy': invitedBy,
        'permissions': permissions.toMap(),
      };

  TeamMembership copyWith({
    TeamRole? role,
    String? displayName,
    String? email,
    String? phone,
    String? advocateType,
    bool? isActive,
    MemberPermissions? permissions,
  }) =>
      TeamMembership(
        userId: userId,
        teamId: teamId,
        membershipDocumentId: membershipDocumentId,
        hasFirebaseIdentity: hasFirebaseIdentity,
        role: role ?? this.role,
        displayName: displayName ?? this.displayName,
        email: email ?? this.email,
        phone: phone ?? this.phone,
        advocateType: advocateType ?? this.advocateType,
        isActive: isActive ?? this.isActive,
        invitedBy: invitedBy,
        joinedAt: joinedAt,
        permissions: permissions ?? this.permissions,
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// TeamMessage  —  stored in  teams/{teamId}/messages/{messageId}
// ─────────────────────────────────────────────────────────────────────────────

enum MessageType { text, caseLink, file, system }

extension MessageTypeExt on MessageType {
  String get value {
    switch (this) {
      case MessageType.text:
        return 'text';
      case MessageType.caseLink:
        return 'case_link';
      case MessageType.file:
        return 'file';
      case MessageType.system:
        return 'system';
    }
  }

  static MessageType fromString(String? s) {
    switch (s) {
      case 'case_link':
        return MessageType.caseLink;
      case 'file':
        return MessageType.file;
      case 'system':
        return MessageType.system;
      default:
        return MessageType.text;
    }
  }
}

class TeamMessage {
  const TeamMessage({
    required this.id,
    required this.teamId,
    required this.senderId,
    required this.senderName,
    required this.text,
    this.type = MessageType.text,
    this.caseId,
    this.caseTitle,
    this.fileUrl,
    this.fileName,
    this.sentAt,
    this.isDeleted = false,
  });

  final String id;
  final String teamId;
  final String senderId;
  final String senderName;
  final String text;
  final MessageType type;
  final String? caseId;
  final String? caseTitle;
  final String? fileUrl;
  final String? fileName;
  final DateTime? sentAt;
  final bool isDeleted;

  factory TeamMessage.fromMap(String id, String teamId, Map<String, dynamic> data) {
    return TeamMessage(
      id: id,
      teamId: teamId,
      senderId: data['senderId'] as String? ?? '',
      senderName: data['senderName'] as String? ?? 'Unknown',
      text: data['text'] as String? ?? '',
      type: MessageTypeExt.fromString(data['type'] as String?),
      caseId: data['caseId'] as String?,
      caseTitle: data['caseTitle'] as String?,
      fileUrl: data['fileUrl'] as String?,
      fileName: data['fileName'] as String?,
      sentAt: (data['sentAt'] as Timestamp?)?.toDate(),
      isDeleted: (data['isDeleted'] as bool?) ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
        'teamId': teamId,
        'senderId': senderId,
        'senderName': senderName,
        'text': text,
        'type': type.value,
        if (caseId != null) 'caseId': caseId,
        if (caseTitle != null) 'caseTitle': caseTitle,
        if (fileUrl != null) 'fileUrl': fileUrl,
        if (fileName != null) 'fileName': fileName,
        'sentAt': FieldValue.serverTimestamp(),
        'isDeleted': false,
      };
}

// ─────────────────────────────────────────────────────────────────────────────
// TeamActivity  —  stored in  teams/{teamId}/activity/{activityId}
// ─────────────────────────────────────────────────────────────────────────────

class TeamActivity {
  const TeamActivity({
    required this.id,
    required this.teamId,
    required this.actorId,
    required this.actorName,
    required this.action,
    this.targetId,
    this.targetTitle,
    this.meta = const {},
    this.timestamp,
  });

  final String id;
  final String teamId;
  final String actorId;
  final String actorName;
  final String action; // 'added_member', 'removed_member', 'assigned_case', etc.
  final String? targetId;
  final String? targetTitle;
  final Map<String, dynamic> meta;
  final DateTime? timestamp;

  String get description {
    switch (action) {
      case 'added_member':
        return '$actorName added ${meta['memberName'] ?? targetTitle ?? 'a member'}';
      case 'removed_member':
        return '$actorName removed ${meta['memberName'] ?? targetTitle ?? 'a member'}';
      case 'assigned_case':
        return '$actorName assigned case "${targetTitle ?? ''}" to ${meta['assigneeName'] ?? ''}';
      case 'unassigned_case':
        return '$actorName unassigned case "${targetTitle ?? ''}"';
      case 'promoted_member':
        return '$actorName promoted ${meta['memberName'] ?? ''} to ${meta['newRole'] ?? ''}';
      case 'created_team':
        return '$actorName created the team';
      default:
        return '$actorName performed $action';
    }
  }

  factory TeamActivity.fromMap(String id, String teamId, Map<String, dynamic> data) {
    return TeamActivity(
      id: id,
      teamId: teamId,
      actorId: data['actorId'] as String? ?? '',
      actorName: data['actorName'] as String? ?? '',
      action: data['action'] as String? ?? '',
      targetId: data['targetId'] as String?,
      targetTitle: data['targetTitle'] as String?,
      meta: (data['meta'] as Map<String, dynamic>?) ?? {},
      timestamp: (data['timestamp'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
        'teamId': teamId,
        'actorId': actorId,
        'actorName': actorName,
        'action': action,
        if (targetId != null) 'targetId': targetId,
        if (targetTitle != null) 'targetTitle': targetTitle,
        'meta': meta,
        'timestamp': FieldValue.serverTimestamp(),
      };
}

// ─────────────────────────────────────────────────────────────────────────────
// MemberPermissions  —  embedded in TeamMembership
// ─────────────────────────────────────────────────────────────────────────────

class MemberPermissions {
  const MemberPermissions({
    this.canCreateCases = true,
    this.canDeleteCases = false,
    this.canInviteMembers = false,
    this.canExportAudit = false,
  });

  final bool canCreateCases;
  final bool canDeleteCases;
  final bool canInviteMembers;
  final bool canExportAudit;

  factory MemberPermissions.fromMap(Map<String, dynamic>? data) {
    if (data == null) return const MemberPermissions();
    return MemberPermissions(
      canCreateCases: (data['canCreateCases'] as bool?) ?? true,
      canDeleteCases: (data['canDeleteCases'] as bool?) ?? false,
      canInviteMembers: (data['canInviteMembers'] as bool?) ?? false,
      canExportAudit: (data['canExportAudit'] as bool?) ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
        'canCreateCases': canCreateCases,
        'canDeleteCases': canDeleteCases,
        'canInviteMembers': canInviteMembers,
        'canExportAudit': canExportAudit,
      };

  MemberPermissions copyWith({
    bool? canCreateCases,
    bool? canDeleteCases,
    bool? canInviteMembers,
    bool? canExportAudit,
  }) =>
      MemberPermissions(
        canCreateCases: canCreateCases ?? this.canCreateCases,
        canDeleteCases: canDeleteCases ?? this.canDeleteCases,
        canInviteMembers: canInviteMembers ?? this.canInviteMembers,
        canExportAudit: canExportAudit ?? this.canExportAudit,
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// TeamGroup  —  stored in  teams/{teamId}/groups/{groupId}
// ─────────────────────────────────────────────────────────────────────────────

class TeamGroup {
  const TeamGroup({
    required this.id,
    required this.teamId,
    required this.name,
    this.description = '',
    this.practiceArea = '',
    this.memberIds = const [],
    this.leaderId,
    this.caseCount = 0,
    this.createdAt,
  });

  final String id;
  final String teamId;
  final String name;
  final String description;
  final String practiceArea;
  final List<String> memberIds;
  final String? leaderId;
  final int caseCount;
  final DateTime? createdAt;

  factory TeamGroup.fromMap(String id, String teamId, Map<String, dynamic> data) {
    return TeamGroup(
      id: id,
      teamId: teamId,
      name: data['name'] as String? ?? 'Unnamed Group',
      description: data['description'] as String? ?? '',
      practiceArea: data['practiceArea'] as String? ?? '',
      memberIds: List<String>.from(data['memberIds'] as List? ?? []),
      leaderId: data['leaderId'] as String?,
      caseCount: (data['caseCount'] as int?) ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
        'teamId': teamId,
        'name': name,
        'description': description,
        'practiceArea': practiceArea,
        'memberIds': memberIds,
        if (leaderId != null) 'leaderId': leaderId,
        'caseCount': caseCount,
        'createdAt': FieldValue.serverTimestamp(),
      };

  TeamGroup copyWith({
    String? name,
    String? description,
    String? practiceArea,
    List<String>? memberIds,
    String? leaderId,
    int? caseCount,
  }) =>
      TeamGroup(
        id: id,
        teamId: teamId,
        name: name ?? this.name,
        description: description ?? this.description,
        practiceArea: practiceArea ?? this.practiceArea,
        memberIds: memberIds ?? this.memberIds,
        leaderId: leaderId ?? this.leaderId,
        caseCount: caseCount ?? this.caseCount,
        createdAt: createdAt,
      );
}
