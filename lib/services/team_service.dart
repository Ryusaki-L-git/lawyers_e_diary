import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/case_model.dart';
import '../models/team_model.dart';

/// Comprehensive Firestore service for all Team operations in Lawyer's E-Diary.
class TeamService {
  TeamService._();
  static final TeamService instance = TeamService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;
  String? get currentUserName =>
      _auth.currentUser?.displayName ?? _auth.currentUser?.email?.split('@').first ?? 'Counsel';

  // ─────────────────────────────────────────────────────────────────────────
  // Teams Querying & Watching
  // ─────────────────────────────────────────────────────────────────────────

  /// Stream of teams the current user belongs to or owns.
  Stream<List<TeamModel>> watchUserTeams() {
    final uid = currentUserId;
    if (uid == null) return Stream.value([]);

    // First query teams where current user is owner
    return _db
        .collection('teams')
        .where('ownerId', isEqualTo: uid)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => TeamModel.fromMap(d.id, d.data())).toList());
  }

  /// Watch a specific team by ID.
  Stream<TeamModel?> watchTeam(String teamId) {
    return _db.collection('teams').doc(teamId).snapshots().map((snap) {
      if (!snap.exists) return null;
      return TeamModel.fromMap(snap.id, snap.data()!);
    });
  }

  /// Watch current user's membership in a specific team.
  Stream<TeamMembership?> watchMyMembership(String teamId) {
    final uid = currentUserId;
    if (uid == null) return Stream.value(null);

    return _db
        .collection('teams')
        .doc(teamId)
        .collection('members')
        .doc(uid)
        .snapshots()
        .map((snap) {
      if (!snap.exists) return null;
      return TeamMembership.fromMap(snap.id, teamId, snap.data()!);
    });
  }

  /// Watch all active members of a team.
  Stream<List<TeamMembership>> watchMembers(String teamId) {
    return _db
        .collection('teams')
        .doc(teamId)
        .collection('members')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => TeamMembership.fromMap(d.id, teamId, d.data())).toList());
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Team Lifecycle (Create, Edit, Archive, Delete)
  // ─────────────────────────────────────────────────────────────────────────

  /// Create a new team with the current user as the Owner.
  Future<String> createTeam({
    required String name,
    required String lawFirm,
    String description = '',
  }) async {
    final uid = currentUserId;
    if (uid == null) throw Exception('Must be signed in to create a team');

    final teamDoc = _db.collection('teams').doc();
    final teamId = teamDoc.id;

    final batch = _db.batch();

    // 1. Team document
    batch.set(teamDoc, {
      'name': name.trim(),
      'lawFirm': lawFirm.trim(),
      'description': description.trim(),
      'ownerId': uid,
      'memberCount': 1,
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // 2. Add owner membership
    final memberDoc = teamDoc.collection('members').doc(uid);
    batch.set(memberDoc, {
      'userId': uid,
      'teamId': teamId,
      'role': TeamRole.owner.value,
      'displayName': currentUserName,
      'email': _auth.currentUser?.email ?? '',
      'phone': '',
      'advocateType': 'Managing Partner',
      'isActive': true,
      'joinedAt': FieldValue.serverTimestamp(),
      'permissions': const MemberPermissions(
        canCreateCases: true,
        canDeleteCases: true,
        canInviteMembers: true,
        canExportAudit: true,
      ).toMap(),
    });

    // 3. Initial activity log
    final actDoc = teamDoc.collection('activity').doc();
    batch.set(actDoc, {
      'teamId': teamId,
      'actorId': uid,
      'actorName': currentUserName,
      'action': 'created_team',
      'targetTitle': name.trim(),
      'meta': {'firm': lawFirm.trim()},
      'timestamp': FieldValue.serverTimestamp(),
    });

    await batch.commit();
    return teamId;
  }

  /// Update basic team details.
  Future<void> updateTeam(
    String teamId, {
    String? name,
    String? lawFirm,
    String? description,
  }) async {
    final data = <String, dynamic>{
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (name != null) data['name'] = name.trim();
    if (lawFirm != null) data['lawFirm'] = lawFirm.trim();
    if (description != null) data['description'] = description.trim();

    await _db.collection('teams').doc(teamId).update(data);
    await logActivity(
      teamId: teamId,
      action: 'updated_team',
      targetTitle: name ?? 'Team Settings',
    );
  }

  /// Transfer ownership of the team to another member.
  Future<void> transferOwnership({
    required String teamId,
    required String newOwnerId,
    required String newOwnerName,
  }) async {
    final uid = currentUserId;
    if (uid == null) return;

    final batch = _db.batch();

    // Update team document
    batch.update(_db.collection('teams').doc(teamId), {
      'ownerId': newOwnerId,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // Promote new owner
    batch.update(
      _db.collection('teams').doc(teamId).collection('members').doc(newOwnerId),
      {'role': TeamRole.owner.value},
    );

    // Demote current owner to leader
    batch.update(
      _db.collection('teams').doc(teamId).collection('members').doc(uid),
      {'role': TeamRole.leader.value},
    );

    await batch.commit();

    await logActivity(
      teamId: teamId,
      action: 'transferred_ownership',
      targetTitle: newOwnerName,
      meta: {'newOwnerId': newOwnerId},
    );
  }

  /// Soft archive team.
  Future<void> archiveTeam(String teamId) async {
    await _db.collection('teams').doc(teamId).update({
      'isActive': false,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    await logActivity(teamId: teamId, action: 'archived_team');
  }

  /// Permanent delete team.
  Future<void> deleteTeam(String teamId) async {
    await _db.collection('teams').doc(teamId).delete();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Member Management & Invitations
  // ─────────────────────────────────────────────────────────────────────────

  /// Invite/Add a member to the team directly.
  Future<void> inviteMember({
    required String teamId,
    required String email,
    required String displayName,
    required TeamRole role,
    String advocateType = 'Associate Advocate',
    String phone = '',
    MemberPermissions permissions = const MemberPermissions(),
  }) async {
    final uid = currentUserId;
    // Generate an ID for the member slot
    final memberId = email.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_').toLowerCase();

    final batch = _db.batch();

    final memberDoc = _db.collection('teams').doc(teamId).collection('members').doc(memberId);
    batch.set(memberDoc, {
      'userId': memberId,
      'teamId': teamId,
      'role': role.value,
      'displayName': displayName.trim(),
      'email': email.trim().toLowerCase(),
      'phone': phone.trim(),
      'advocateType': advocateType,
      'isActive': true,
      'invitedBy': uid,
      'joinedAt': FieldValue.serverTimestamp(),
      'permissions': permissions.toMap(),
    });

    // Increment member count on team
    batch.update(_db.collection('teams').doc(teamId), {
      'memberCount': FieldValue.increment(1),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();

    await logActivity(
      teamId: teamId,
      action: 'added_member',
      targetTitle: displayName.trim(),
      meta: {'memberName': displayName.trim(), 'role': role.label},
    );
  }

  /// Update role of a team member.
  Future<void> updateMemberRole(String teamId, String memberId, TeamRole newRole) async {
    await _db
        .collection('teams')
        .doc(teamId)
        .collection('members')
        .doc(memberId)
        .update({'role': newRole.value});

    await logActivity(
      teamId: teamId,
      action: 'promoted_member',
      targetTitle: memberId,
      meta: {'newRole': newRole.label},
    );
  }

  /// Update permissions of a team member.
  Future<void> updateMemberPermissions(
    String teamId,
    String memberId,
    MemberPermissions permissions,
  ) async {
    await _db
        .collection('teams')
        .doc(teamId)
        .collection('members')
        .doc(memberId)
        .update({'permissions': permissions.toMap()});
  }

  /// Remove a member from the team.
  Future<void> removeMember(String teamId, String memberId, String memberName) async {
    final batch = _db.batch();
    batch.update(
      _db.collection('teams').doc(teamId).collection('members').doc(memberId),
      {'isActive': false},
    );
    batch.update(_db.collection('teams').doc(teamId), {
      'memberCount': FieldValue.increment(-1),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    await batch.commit();

    await logActivity(
      teamId: teamId,
      action: 'removed_member',
      targetTitle: memberName,
      meta: {'memberName': memberName},
    );
  }

  /// Leave team (member self-exit).
  Future<void> leaveTeam(String teamId) async {
    final uid = currentUserId;
    if (uid == null) return;
    await removeMember(teamId, uid, currentUserName ?? 'Member');
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Team Cases & Assignment Matrix
  // ─────────────────────────────────────────────────────────────────────────

  /// Stream cases belonging to a team.
  Stream<List<CaseModel>> watchTeamCases(
    String teamId, {
    String? assignedTo,
    bool unassignedOnly = false,
  }) {
    Query<Map<String, dynamic>> query =
        _db.collection('cases').where('teamId', isEqualTo: teamId);

    if (assignedTo != null && assignedTo.isNotEmpty) {
      query = query.where('assignedTo', isEqualTo: assignedTo);
    } else if (unassignedOnly) {
      query = query.where('assignedTo', isNull: true);
    }

    return query.snapshots().map((snap) {
      return snap.docs.map((d) => CaseModel.fromMap(d.id, d.data())).toList();
    });
  }

  /// Assign a case to a specific member.
  Future<void> assignCase({
    required String teamId,
    required String caseId,
    required String caseTitle,
    required String memberId,
    required String memberName,
  }) async {
    await _db.collection('cases').doc(caseId).update({
      'teamId': teamId,
      'assignedTo': memberId,
      'assignedToName': memberName,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await logActivity(
      teamId: teamId,
      action: 'assigned_case',
      targetId: caseId,
      targetTitle: caseTitle,
      meta: {'assigneeName': memberName, 'assigneeId': memberId},
    );
  }

  /// Unassign a case.
  Future<void> unassignCase({
    required String teamId,
    required String caseId,
    required String caseTitle,
  }) async {
    await _db.collection('cases').doc(caseId).update({
      'assignedTo': null,
      'assignedToName': null,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await logActivity(
      teamId: teamId,
      action: 'unassigned_case',
      targetId: caseId,
      targetTitle: caseTitle,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Team Practice Groups
  // ─────────────────────────────────────────────────────────────────────────

  /// Stream of practice groups in a team.
  Stream<List<TeamGroup>> watchGroups(String teamId, {String? memberId}) {
    Query<Map<String, dynamic>> query =
        _db.collection('teams').doc(teamId).collection('groups');

    if (memberId != null) {
      query = query.where('memberIds', arrayContains: memberId);
    }

    return query.snapshots().map(
          (snap) => snap.docs.map((d) => TeamGroup.fromMap(d.id, teamId, d.data())).toList(),
        );
  }

  /// Create a new practice group.
  Future<String> createGroup({
    required String teamId,
    required String name,
    required String practiceArea,
    String description = '',
    List<String> memberIds = const [],
    String? leaderId,
  }) async {
    final doc = _db.collection('teams').doc(teamId).collection('groups').doc();
    await doc.set({
      'teamId': teamId,
      'name': name.trim(),
      'practiceArea': practiceArea.trim(),
      'description': description.trim(),
      'memberIds': memberIds,
      // ignore: use_null_aware_elements
      if (leaderId != null) 'leaderId': leaderId,
      'caseCount': 0,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await logActivity(
      teamId: teamId,
      action: 'created_group',
      targetTitle: name.trim(),
    );

    return doc.id;
  }

  /// Update a practice group.
  Future<void> updateGroup(
    String teamId,
    String groupId, {
    String? name,
    String? practiceArea,
    String? description,
    List<String>? memberIds,
    String? leaderId,
  }) async {
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name.trim();
    if (practiceArea != null) data['practiceArea'] = practiceArea.trim();
    if (description != null) data['description'] = description.trim();
    if (memberIds != null) data['memberIds'] = memberIds;
    if (leaderId != null) data['leaderId'] = leaderId;

    await _db
        .collection('teams')
        .doc(teamId)
        .collection('groups')
        .doc(groupId)
        .update(data);
  }

  /// Delete a practice group.
  Future<void> deleteGroup(String teamId, String groupId, String groupName) async {
    await _db
        .collection('teams')
        .doc(teamId)
        .collection('groups')
        .doc(groupId)
        .delete();

    await logActivity(
      teamId: teamId,
      action: 'deleted_group',
      targetTitle: groupName,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Team Production Chat
  // ─────────────────────────────────────────────────────────────────────────

  /// Stream messages in a team chat channel.
  Stream<List<TeamMessage>> watchMessages(String teamId, {int limit = 60}) {
    return _db
        .collection('teams')
        .doc(teamId)
        .collection('messages')
        .orderBy('sentAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => TeamMessage.fromMap(d.id, teamId, d.data())).toList());
  }

  /// Send a message to team chat.
  Future<void> sendMessage({
    required String teamId,
    required String text,
    MessageType type = MessageType.text,
    String? caseId,
    String? caseTitle,
    String? fileUrl,
    String? fileName,
  }) async {
    final uid = currentUserId;
    if (uid == null) return;

    final doc = _db.collection('teams').doc(teamId).collection('messages').doc();
    final message = TeamMessage(
      id: doc.id,
      teamId: teamId,
      senderId: uid,
      senderName: currentUserName ?? 'Counsel',
      text: text.trim(),
      type: type,
      caseId: caseId,
      caseTitle: caseTitle,
      fileUrl: fileUrl,
      fileName: fileName,
    );

    await doc.set(message.toMap());
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Activity & Audit Log
  // ─────────────────────────────────────────────────────────────────────────

  /// Stream audit activity logs.
  Stream<List<TeamActivity>> watchActivityLogs(String teamId, {int limit = 50}) {
    return _db
        .collection('teams')
        .doc(teamId)
        .collection('activity')
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => TeamActivity.fromMap(d.id, teamId, d.data())).toList());
  }

  /// Log an action to the team activity log.
  Future<void> logActivity({
    required String teamId,
    required String action,
    String? targetId,
    String? targetTitle,
    Map<String, dynamic> meta = const {},
  }) async {
    try {
      final uid = currentUserId ?? 'system';
      final doc = _db.collection('teams').doc(teamId).collection('activity').doc();
      await doc.set({
        'teamId': teamId,
        'actorId': uid,
        'actorName': currentUserName ?? 'Counsel',
        'action': action,
        // ignore: use_null_aware_elements
        if (targetId != null) 'targetId': targetId,
        // ignore: use_null_aware_elements
        if (targetTitle != null) 'targetTitle': targetTitle,
        'meta': meta,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error logging team activity: $e');
    }
  }
}
