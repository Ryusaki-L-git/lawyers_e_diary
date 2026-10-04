import 'dart:async';

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
  String? get currentUserName => _auth.currentUser?.displayName ?? 'Counsel';

  Future<String> _currentProfileName() async {
    final uid = currentUserId;
    if (uid == null) return currentUserName ?? 'Counsel';

    final profile = await _db.collection('users').doc(uid).get();
    final name = profile.data()?['name'] as String?;
    if (name?.trim().isNotEmpty == true) return name!.trim();
    return currentUserName ?? 'Counsel';
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Teams Querying & Watching
  // ─────────────────────────────────────────────────────────────────────────

  /// Stream of teams the current user belongs to or owns.
  Stream<List<TeamModel>> watchUserTeams() {
    final uid = currentUserId;
    if (uid == null) return Stream.value([]);

    final ownerTeams = _db
        .collection('teams')
        .where('ownerId', isEqualTo: uid)
        .where('isActive', isEqualTo: true)
        .snapshots();
    final userMemberships = _db
        .collectionGroup('members')
        .where('userId', isEqualTo: uid)
        .snapshots();
    final userProfile = _db.collection('users').doc(uid).get();

    return Stream<List<TeamModel>>.multi((controller) {
      QuerySnapshot<Map<String, dynamic>>? ownerSnapshot;
      QuerySnapshot<Map<String, dynamic>>? membershipSnapshot;
      var generation = 0;

      Future<void> emitTeams() async {
        final owners = ownerSnapshot;
        final memberships = membershipSnapshot;
        if (owners == null || memberships == null) return;

        final currentGeneration = ++generation;
        final profilesExist = (await userProfile).exists;
        final teams = <String, TeamModel>{
          for (final doc in owners.docs)
            doc.id: TeamModel.fromMap(doc.id, doc.data()),
        };

        if (profilesExist) {
          for (final memberDoc in memberships.docs) {
            if (memberDoc.id != uid ||
                memberDoc.data()['userId'] != uid ||
                memberDoc.data()['isActive'] != true) {
              continue;
            }
            final teamRef = memberDoc.reference.parent.parent;
            if (teamRef == null) continue;
            final teamSnapshot = await teamRef.get();
            final teamData = teamSnapshot.data();
            if (teamSnapshot.exists && teamData?['isActive'] != false) {
              teams[teamRef.id] = TeamModel.fromMap(teamRef.id, teamData!);
            }
          }
        }

        if (currentGeneration == generation) {
          controller.add(teams.values.toList(growable: false));
        }
      }

      void refreshTeams() {
        unawaited(
          emitTeams().catchError((Object error, StackTrace stackTrace) {
            controller.addError(error, stackTrace);
          }),
        );
      }

      final ownerSubscription = ownerTeams.listen((snapshot) {
        ownerSnapshot = snapshot;
        refreshTeams();
      }, onError: controller.addError);
      final membershipSubscription = userMemberships.listen((snapshot) {
        membershipSnapshot = snapshot;
        refreshTeams();
      }, onError: controller.addError);

      controller.onCancel = () async {
        await ownerSubscription.cancel();
        await membershipSubscription.cancel();
      };
    });
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
        .asyncMap((snap) async {
          final members = await Future.wait(
            snap.docs.map((memberDoc) async {
              final profileSnapshot = await _db
                  .collection('users')
                  .doc(memberDoc.id)
                  .get();
              return TeamMembership.fromMap(
                memberDoc.id,
                teamId,
                memberDoc.data(),
                hasFirebaseIdentity: profileSnapshot.exists,
                userProfile: profileSnapshot.data(),
              );
            }),
          );
          return members;
        });
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
    final ownerProfileSnapshot = await _db.collection('users').doc(uid).get();
    final ownerProfile = ownerProfileSnapshot.data() ?? {};
    final ownerName = (ownerProfile['name'] as String?)?.trim();
    final ownerDisplayName = ownerName == null || ownerName.isEmpty
        ? currentUserName
        : ownerName;

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
      'displayName': ownerDisplayName,
      'email':
          ownerProfile['email'] as String? ?? _auth.currentUser?.email ?? '',
      'phone': ownerProfile['phone'] as String? ?? '',
      'ledId': ownerProfile['ledId'] as String? ?? '',
      'advocateType':
          ownerProfile['advocateType'] as String? ?? 'Managing Partner',
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
      'actorName': ownerDisplayName,
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
    final data = <String, dynamic>{'updatedAt': FieldValue.serverTimestamp()};
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
    if (newOwnerId.isEmpty) {
      throw StateError('Ownership can only be transferred to an LED user.');
    }
    final newOwnerProfile = await _db.collection('users').doc(newOwnerId).get();
    final newOwnerMembership = await _db
        .collection('teams')
        .doc(teamId)
        .collection('members')
        .doc(newOwnerId)
        .get();
    if (!newOwnerProfile.exists ||
        !newOwnerMembership.exists ||
        newOwnerMembership.data()?['isActive'] != true) {
      throw StateError(
        'Ownership can only be transferred to an active LED member.',
      );
    }

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

  /// Finds an existing LED profile by its assigned LED ID only.
  Future<LedUserProfile?> findLedUserById(String ledId) async {
    final normalizedLedId = ledId.trim();
    if (normalizedLedId.isEmpty) {
      throw ArgumentError.value(ledId, 'ledId', 'LED ID is required.');
    }

    final snapshot = await _db
        .collection('users')
        .where('ledId', isEqualTo: normalizedLedId)
        .limit(2)
        .get();
    if (snapshot.docs.isEmpty) return null;
    if (snapshot.docs.length > 1) {
      throw StateError('More than one LED profile uses this LED ID.');
    }

    final profile = LedUserProfile.fromMap(
      snapshot.docs.single.id,
      snapshot.docs.single.data(),
    );
    if (snapshot.docs.single.data()['profileCompleted'] != true) {
      throw StateError('This LED account does not have a completed profile.');
    }
    if (profile.name.trim().isEmpty) {
      throw StateError('The LED profile does not have a completed name.');
    }
    return profile;
  }

  /// Adds an existing LED user, keyed by the user's Firebase Auth UID.
  Future<void> addExistingLedUser({
    required String teamId,
    required LedUserProfile user,
    required TeamRole role,
    MemberPermissions permissions = const MemberPermissions(),
  }) async {
    final ownerUid = currentUserId;
    if (ownerUid == null) {
      throw StateError('Sign in before adding a team member.');
    }

    final teamRef = _db.collection('teams').doc(teamId);
    final profileRef = _db.collection('users').doc(user.uid);
    final memberRef = teamRef.collection('members').doc(user.uid);

    var wasActivated = false;
    var addedMemberName = user.name.trim();
    await _db.runTransaction<void>((transaction) async {
      final profileSnapshot = await transaction.get(profileRef);
      final memberSnapshot = await transaction.get(memberRef);
      final teamSnapshot = await transaction.get(teamRef);

      if (!profileSnapshot.exists) {
        throw StateError('The selected LED profile no longer exists.');
      }
      if (!teamSnapshot.exists) {
        throw StateError('The selected team no longer exists.');
      }
      if (teamSnapshot.data()?['ownerId'] == user.uid) {
        throw StateError('The team owner is already on the team.');
      }

      final isAlreadyActive =
          memberSnapshot.exists && memberSnapshot.data()?['isActive'] == true;
      wasActivated = !isAlreadyActive;

      final profileData = profileSnapshot.data()!;
      final displayName = profileData['name'] as String? ?? '';
      if (displayName.trim().isEmpty) {
        throw StateError('The LED profile does not have a completed name.');
      }
      addedMemberName = displayName.trim();
      if ((profileData['ledId'] as String?) != user.ledId) {
        throw StateError('The selected LED profile has changed. Search again.');
      }

      final memberData = <String, dynamic>{
        'userId': user.uid,
        'teamId': teamId,
        'role': role.value,
        'displayName': displayName.trim(),
        'email': profileData['email'] as String? ?? '',
        'phone': profileData['phone'] as String? ?? '',
        'ledId': profileData['ledId'] as String? ?? user.ledId,
        'advocateType':
            profileData['advocateType'] as String? ?? 'Associate Advocate',
        'isActive': true,
        'invitedBy': ownerUid,
        'permissions': permissions.toMap(),
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (!isAlreadyActive) {
        memberData['joinedAt'] = FieldValue.serverTimestamp();
      }

      transaction.set(memberRef, memberData, SetOptions(merge: true));
      if (wasActivated) {
        transaction.update(teamRef, {
          'memberCount': FieldValue.increment(1),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    });

    await logActivity(
      teamId: teamId,
      action: 'added_member',
      targetId: user.uid,
      targetTitle: addedMemberName,
      meta: {
        'memberName': addedMemberName,
        'memberUid': user.uid,
        'role': role.label,
      },
    );
  }

  /// Builds share-ready copy only; no external message provider is called.
  Future<String> buildTeamInvitationMessage({
    required String teamId,
    required String recipient,
  }) async {
    final ownerUid = currentUserId;
    if (ownerUid == null) {
      throw StateError('Sign in before preparing an invitation.');
    }

    final ownerProfile = await _db.collection('users').doc(ownerUid).get();
    final storedOwnerName = ownerProfile.data()?['name'] as String?;
    final ownerName = storedOwnerName?.trim().isNotEmpty == true
        ? storedOwnerName!.trim()
        : _auth.currentUser?.displayName?.trim().isNotEmpty == true
        ? _auth.currentUser!.displayName!.trim()
        : 'Team owner';
    final ownerLedId = ownerProfile.data()?['ledId'] as String?;
    final teamSnapshot = await _db.collection('teams').doc(teamId).get();
    if (!teamSnapshot.exists) {
      throw StateError('The selected team no longer exists.');
    }
    final teamName = teamSnapshot.data()?['name'] as String? ?? 'our team';
    final lawFirm = teamSnapshot.data()?['lawFirm'] as String? ?? '';

    return 'You are invited to join ${lawFirm.isEmpty ? teamName : '$lawFirm · $teamName'} '
        'on Lawyer\'s E-Diary.\n\n'
        'From: $ownerName${ownerLedId?.isNotEmpty == true ? ' (LED ID: $ownerLedId)' : ''}\n'
        'Invitation for: $recipient\n'
        'Team ID: $teamId\n\n'
        'To join, install/open Lawyer\'s E-Diary, create or complete your LED profile, '
        'then share your LED ID with $ownerName so they can add your verified profile '
        'to this team.\n\n'
        'App download: [Official download link is not configured]\n'
        'Team join link: [No join link is configured; use Team ID $teamId]';
  }

  /// Update role of a team member.
  Future<void> updateMemberRole(
    String teamId,
    String memberId,
    TeamRole newRole,
  ) async {
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
  Future<void> removeMember(
    String teamId,
    String memberId,
    String memberName,
  ) async {
    final memberRef = _db
        .collection('teams')
        .doc(teamId)
        .collection('members')
        .doc(memberId);
    final teamRef = _db.collection('teams').doc(teamId);
    var wasActive = false;
    await _db.runTransaction<void>((transaction) async {
      wasActive = false;
      final memberSnapshot = await transaction.get(memberRef);
      final teamSnapshot = await transaction.get(teamRef);
      if (!memberSnapshot.exists || !teamSnapshot.exists) {
        throw StateError('The team member or team no longer exists.');
      }
      if (memberSnapshot.data()?['isActive'] != true) return;

      wasActive = true;
      transaction.update(memberRef, {'isActive': false});
      transaction.update(teamRef, {
        'memberCount': FieldValue.increment(-1),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
    if (!wasActive) return;

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
    await removeMember(teamId, uid, await _currentProfileName());
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
    Query<Map<String, dynamic>> query = _db
        .collection('cases')
        .where('teamId', isEqualTo: teamId);

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
    if (memberId.isEmpty) {
      throw StateError('Cases can only be assigned to a verified LED user.');
    }
    final memberSnapshot = await _db
        .collection('teams')
        .doc(teamId)
        .collection('members')
        .doc(memberId)
        .get();
    final userSnapshot = await _db.collection('users').doc(memberId).get();
    if (!memberSnapshot.exists ||
        memberSnapshot.data()?['isActive'] != true ||
        !userSnapshot.exists) {
      throw StateError('Cases can only be assigned to an active LED member.');
    }

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
    Query<Map<String, dynamic>> query = _db
        .collection('teams')
        .doc(teamId)
        .collection('groups');

    if (memberId != null) {
      query = query.where('memberIds', arrayContains: memberId);
    }

    return query.snapshots().map(
      (snap) => snap.docs
          .map((d) => TeamGroup.fromMap(d.id, teamId, d.data()))
          .toList(),
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
  Future<void> deleteGroup(
    String teamId,
    String groupId,
    String groupName,
  ) async {
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
        .map(
          (snap) => snap.docs
              .map((d) => TeamMessage.fromMap(d.id, teamId, d.data()))
              .toList(),
        );
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
    final senderName = await _currentProfileName();

    final doc = _db
        .collection('teams')
        .doc(teamId)
        .collection('messages')
        .doc();
    final message = TeamMessage(
      id: doc.id,
      teamId: teamId,
      senderId: uid,
      senderName: senderName,
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
  Stream<List<TeamActivity>> watchActivityLogs(
    String teamId, {
    int limit = 50,
  }) {
    return _db
        .collection('teams')
        .doc(teamId)
        .collection('activity')
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => TeamActivity.fromMap(d.id, teamId, d.data()))
              .toList(),
        );
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
      final doc = _db
          .collection('teams')
          .doc(teamId)
          .collection('activity')
          .doc();
      await doc.set({
        'teamId': teamId,
        'actorId': uid,
        'actorName': await _currentProfileName(),
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
