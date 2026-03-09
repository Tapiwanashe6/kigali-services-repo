import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

class User {
  final String uid;
  final String email;
  final String? displayName;
  final bool emailVerified;
  final DateTime? createdAt;

  User({
    required this.uid,
    required this.email,
    this.displayName,
    required this.emailVerified,
    this.createdAt,
  });

  // Create User from Firebase Auth
  factory User.fromFirebaseUser(firebase_auth.User firebaseUser) {
    return User(
      uid: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      displayName: firebaseUser.displayName,
      emailVerified: firebaseUser.emailVerified,
      createdAt: firebaseUser.metadata.creationTime,
    );
  }

  // Create User from Firestore document
  factory User.fromMap(String uid, Map<String, dynamic> data) {
    return User(
      uid: uid,
      email: data['email'] ?? '',
      displayName: data['displayName'],
      emailVerified: data['emailVerified'] ?? false,
      createdAt: data['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(data['createdAt'].millisecondsSinceEpoch)
          : null,
    );
  }

  // Convert User to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'emailVerified': emailVerified,
      'createdAt': createdAt?.millisecondsSinceEpoch,
    };
  }
}

