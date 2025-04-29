import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

import '../global.dart';
import 'user_repository.dart';

/// Authentication service for handling Firebase Authentication
class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  bool _isInitialized = false;
  bool _isLoading = false;

  // Getters
  User? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;
  bool get isEmailVerified => _user?.emailVerified ?? false;

  // Singleton pattern
  static AuthService? _instance;
  static Future<AuthService> getInstance() async {
    _instance ??= AuthService._();
    return _instance!;
  }

  AuthService._() {
    _init();
  }

  // Initialize the auth service
  Future<void> _init() async {
    try {
      // Listen for auth state changes
      _auth.authStateChanges().listen((User? user) {
        _user = user;
        _isInitialized = true;
        notifyListeners();
        logger.info('Auth state changed: ${user?.email}');
      });
    } catch (e) {
      logger.severe('Error initializing auth service: $e');
      _isInitialized = true;
      notifyListeners();
    }
  }

  // Set loading state
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Sign in with email and password
  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      _setLoading(true);
      final UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _user = result.user;
      return _user;
    } catch (e) {
      logger.severe('Error signing in: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Register with email and password
  Future<User?> registerWithEmailAndPassword(String email, String password) async {
    try {
      _setLoading(true);
      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      _user = result.user;

      // Send email verification
      await sendEmailVerification();

      return _user;
    } catch (e) {
      logger.severe('Error registering: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Send email verification
  Future<void> sendEmailVerification() async {
    try {
      if (_user != null && !_user!.emailVerified) {
        await _user!.sendEmailVerification();
      }
    } catch (e) {
      logger.severe('Error sending email verification: $e');
      rethrow;
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      _setLoading(true);
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      logger.severe('Error resetting password: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      _setLoading(true);
      await _auth.signOut();
      _user = null;
    } catch (e) {
      logger.severe('Error signing out: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Reload user
  Future<void> reloadUser() async {
    try {
      _setLoading(true);
      await _user?.reload();
      _user = _auth.currentUser;
      notifyListeners();
    } catch (e) {
      logger.severe('Error reloading user: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Update display name
  Future<void> updateDisplayName(String displayName) async {
    try {
      _setLoading(true);
      await _user?.updateDisplayName(displayName);
      await reloadUser();
    } catch (e) {
      logger.severe('Error updating display name: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Update email
  Future<void> updateEmail(String email) async {
    try {
      _setLoading(true);
      await _user?.verifyBeforeUpdateEmail(email);
      await reloadUser();
    } catch (e) {
      logger.severe('Error updating email: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Update password
  Future<void> updatePassword(String password) async {
    try {
      _setLoading(true);
      await _user?.updatePassword(password);
    } catch (e) {
      logger.severe('Error updating password: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Delete account
  Future<void> deleteAccount() async {
    try {
      _setLoading(true);
      await _user?.delete();
      _user = null;
    } catch (e) {
      logger.severe('Error deleting account: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Sign in with Google
  Future<User?> signInWithGoogle() async {
    try {
      _setLoading(true);

      // Begin interactive sign-in process
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      // Obtain auth details from request
      if (googleUser == null) {
        // User canceled the sign-in flow
        return null;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create new credential
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in with credential
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      _user = userCredential.user;

      // Check if this is a new user
      if (userCredential.additionalUserInfo?.isNewUser ?? false) {
        // Create user in Firestore
        await UserRepository.instance.createUser(_user!);
      } else {
        // Update last login time
        await UserRepository.instance.updateLastLogin(_user!.uid);
      }

      return _user;
    } catch (e) {
      logger.severe('Error signing in with Google: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Sign in with Facebook
  Future<User?> signInWithFacebook() async {
    try {
      _setLoading(true);

      // Trigger the sign-in flow
      final LoginResult result = await FacebookAuth.instance.login();

      if (result.status != LoginStatus.success) {
        // User canceled the sign-in flow or it failed
        return null;
      }

      // Create a credential from the access token
      final OAuthCredential credential = FacebookAuthProvider.credential(
        result.accessToken!.token,
      );

      // Sign in with credential
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      _user = userCredential.user;

      // Check if this is a new user
      if (userCredential.additionalUserInfo?.isNewUser ?? false) {
        // Create user in Firestore
        await UserRepository.instance.createUser(_user!);
      } else {
        // Update last login time
        await UserRepository.instance.updateLastLogin(_user!.uid);
      }

      return _user;
    } catch (e) {
      logger.severe('Error signing in with Facebook: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Link Google account to existing account
  Future<User?> linkWithGoogle() async {
    try {
      _setLoading(true);

      if (_user == null) {
        throw Exception('No user is currently signed in');
      }

      // Begin interactive sign-in process
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      // Obtain auth details from request
      if (googleUser == null) {
        // User canceled the sign-in flow
        return null;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create new credential
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Link credential to current user
      final UserCredential userCredential = await _user!.linkWithCredential(credential);
      _user = userCredential.user;

      return _user;
    } catch (e) {
      logger.severe('Error linking with Google: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Link Facebook account to existing account
  Future<User?> linkWithFacebook() async {
    try {
      _setLoading(true);

      if (_user == null) {
        throw Exception('No user is currently signed in');
      }

      // Trigger the sign-in flow
      final LoginResult result = await FacebookAuth.instance.login();

      if (result.status != LoginStatus.success) {
        // User canceled the sign-in flow or it failed
        return null;
      }

      // Create a credential from the access token
      final OAuthCredential credential = FacebookAuthProvider.credential(
        result.accessToken!.token,
      );

      // Link credential to current user
      final UserCredential userCredential = await _user!.linkWithCredential(credential);
      _user = userCredential.user;

      return _user;
    } catch (e) {
      logger.severe('Error linking with Facebook: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Unlink provider from account
  Future<User?> unlinkProvider(String providerId) async {
    try {
      _setLoading(true);

      if (_user == null) {
        throw Exception('No user is currently signed in');
      }

      // Unlink provider
      final User? user = (await _user!.unlink(providerId)).user;
      _user = user;

      return _user;
    } catch (e) {
      logger.severe('Error unlinking provider: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Get list of linked providers
  List<String> getLinkedProviders() {
    if (_user == null) return [];
    return _user!.providerData.map((userInfo) => userInfo.providerId).toList();
  }

  // Check if a specific provider is linked
  bool isProviderLinked(String providerId) {
    return getLinkedProviders().contains(providerId);
  }
}
