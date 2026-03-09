import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';

class AuthService {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser != null) {
      return User.fromFirebaseUser(firebaseUser);
    }
    return null;
  }

  // Stream of auth state changes
  Stream<User?> get authStateChanges {
    return _auth.authStateChanges().map((firebaseUser) {
      if (firebaseUser != null) {
        return User.fromFirebaseUser(firebaseUser);
      }
      return null;
    });
  }

  // Sign up with email and password
  Future<User?> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      // Create user in Firebase Auth
      final firebase_auth.UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = credential.user;

      if (firebaseUser != null) {
        // Send email verification
        await firebaseUser.sendEmailVerification();

        // Update display name if provided
        if (displayName != null && displayName.isNotEmpty) {
          await firebaseUser.updateDisplayName(displayName);
        }

        // Create user profile in Firestore
        await _createUserProfile(firebaseUser.uid, email, displayName);

        return User.fromFirebaseUser(firebaseUser);
      }
      return null;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Sign in with email and password
  Future<User?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final firebase_auth.UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = credential.user;

      if (firebaseUser != null) {
        // Check if user exists in Firestore database
        final userProfile = await getUserProfile(firebaseUser.uid);
        if (userProfile == null) {
          // User exists in Firebase Auth but not in Firestore - sign them out and throw error
          await _auth.signOut();
          throw Exception('Your account is not found in our system. Please sign up.');
        }
        
        return User.fromFirebaseUser(firebaseUser);
      }
      return null;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw Exception(_handleAuthException(e));
    } catch (e) {
      // Re-throw any other exceptions (like our custom "not in database" exception)
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Resend verification email
  Future<void> resendVerificationEmail() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser != null) {
      if (!firebaseUser.emailVerified) {
        await firebaseUser.sendEmailVerification();
      } else {
        throw Exception('Email is already verified.');
      }
    } else {
      throw Exception('No user is currently signed in.');
    }
  }

  // Reload user to get updated verification status
  Future<User?> reloadUser() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser != null) {
      await firebaseUser.reload();
      return User.fromFirebaseUser(firebaseUser);
    }
    return null;
  }

  // Check if email is verified
  bool isEmailVerified() {
    return _auth.currentUser?.emailVerified ?? false;
  }

  // Mark email as verified in Firestore
  Future<void> markEmailAsVerified(String uid) async {
    await _firestore.collection('users').doc(uid).update({
      'emailVerified': true,
    });
  }

  // Create user profile in Firestore
  Future<void> _createUserProfile(String uid, String email, String? displayName) async {
    await _firestore.collection('users').doc(uid).set({
      'email': email,
      'displayName': displayName ?? '',
      'emailVerified': false,
      'createdAt': DateTime.now().millisecondsSinceEpoch,
    });
  }

  // Get user profile from Firestore
  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    try {
      final DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user profile: $e');
    }
  }

  // Update user profile in Firestore
  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    await _firestore.collection('users').doc(uid).update(data);
  }

  // Handle auth exceptions
  String _handleAuthException(firebase_auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'operation-not-allowed':
        return 'Operation not allowed. Please contact support.';
      case 'weak-password':
        return 'Password is too weak. Please use a stronger password.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'invalid-credential':
        return 'Invalid credentials. Please try again.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      default:
        return 'An error occurred. Please try again.';
    }
  }
}

