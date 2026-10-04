import 'package:firebase_auth/firebase_auth.dart';

abstract class AppIdentity {
  String? get currentUserId;
}

class FirebaseAuthIdentity implements AppIdentity {
  const FirebaseAuthIdentity();

  static const FirebaseAuthIdentity instance = FirebaseAuthIdentity();

  @override
  String? get currentUserId => FirebaseAuth.instance.currentUser?.uid;
}

class TestAuthIdentity implements AppIdentity {
  const TestAuthIdentity(this.uid);

  final String? uid;

  @override
  String? get currentUserId => uid;
}
