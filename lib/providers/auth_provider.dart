import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

enum AuthState {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  AuthState _state = AuthState.initial;
  User? _user;
  String? _errorMessage;
  bool _emailVerified = false;

  // Getters
  AuthState get state => _state;
  User? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _state == AuthState.authenticated;
  bool get emailVerified => _emailVerified;
  bool get isLoading => _state == AuthState.loading;

  // Initialize auth state listener
  void initializeAuthListener() {
    _authService.authStateChanges.listen((User? user) {
      if (user != null) {
        _user = user;
        _emailVerified = user.emailVerified;
        _state = AuthState.authenticated;
      } else {
        _user = null;
        _emailVerified = false;
        _state = AuthState.unauthenticated;
      }
      notifyListeners();
    });
  }

  // Sign up
  Future<bool> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final User? user = await _authService.signUp(
        email: email,
        password: password,
        displayName: displayName,
      );

      if (user != null) {
        _user = user;
        _emailVerified = false;
        _state = AuthState.authenticated;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Failed to create account';
        _state = AuthState.error;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _state = AuthState.error;
      notifyListeners();
      return false;
    }
  }

  // Sign in
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final User? user = await _authService.signIn(
        email: email,
        password: password,
      );

      if (user != null) {
        _user = user;
        _emailVerified = user.emailVerified;
        
        if (!_emailVerified) {
          _errorMessage = 'Please verify your email before logging in.';
          _state = AuthState.error;
          notifyListeners();
          return false;
        } else {
          _state = AuthState.authenticated;
          notifyListeners();
          return true;
        }
      } else {
        _errorMessage = 'Failed to sign in';
        _state = AuthState.error;
        notifyListeners();
        return false;
      }
    } catch (e) {
      // Clean up error message - remove "Exception: " prefix if present
      String errorMsg = e.toString();
      if (errorMsg.contains('Exception: ')) {
        errorMsg = errorMsg.split('Exception: ').last;
      }
      _errorMessage = errorMsg;
      _state = AuthState.error;
      notifyListeners();
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    _state = AuthState.loading;
    notifyListeners();

    try {
      await _authService.signOut();
      _user = null;
      _emailVerified = false;
      _state = AuthState.unauthenticated;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _state = AuthState.error;
      notifyListeners();
    }
  }

  // Reload user to check email verification status
  Future<void> reloadUser() async {
    try {
      final User? updatedUser = await _authService.reloadUser();
      if (updatedUser != null) {
        _user = updatedUser;
        _emailVerified = updatedUser.emailVerified;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Mark email as verified in Firestore
  Future<void> markEmailAsVerified() async {
    try {
      if (_user != null) {
        await _authService.markEmailAsVerified(_user!.uid);
        _emailVerified = true;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Send password reset email
  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      await _authService.sendPasswordResetEmail(email);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Resend verification email
  Future<bool> resendVerificationEmail() async {
    try {
      await _authService.resendVerificationEmail();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Reset state
  void resetState() {
    _state = AuthState.initial;
    _user = null;
    _errorMessage = null;
    _emailVerified = false;
    notifyListeners();
  }
}

