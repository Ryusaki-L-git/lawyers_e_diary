import 'package:flutter_test/flutter_test.dart';
import 'package:lawyers_e_diary/models/team_model.dart';

void main() {
  group('TeamMembership identity', () {
    test('keeps legacy document keys separate from Firebase user IDs', () {
      const legacyDocumentId = 'advocate_example_com';
      final membership = TeamMembership.fromMap(
        legacyDocumentId,
        'team-1',
        const {
          'userId': legacyDocumentId,
          'displayName': 'Legacy associate',
          'isActive': true,
        },
        hasFirebaseIdentity: false,
      );

      expect(membership.userId, isEmpty);
      expect(membership.membershipDocumentId, legacyDocumentId);
      expect(membership.hasFirebaseIdentity, isFalse);
      expect(membership.toMap().containsKey('userId'), isFalse);
    });

    test('uses the profile document ID and profile data for LED members', () {
      final membership = TeamMembership.fromMap(
        'firebase-uid-1',
        'team-1',
        const {
          'userId': 'not-the-uid',
          'displayName': 'Stale copied name',
          'isActive': true,
        },
        userProfile: const {
          'name': 'Verified Profile Name',
          'email': 'profile@example.com',
        },
      );

      expect(membership.userId, 'firebase-uid-1');
      expect(membership.membershipDocumentId, 'firebase-uid-1');
      expect(membership.hasFirebaseIdentity, isTrue);
      expect(membership.displayName, 'Verified Profile Name');
      expect(membership.email, 'profile@example.com');
    });
  });
}
