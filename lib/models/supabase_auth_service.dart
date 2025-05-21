import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../global.dart';
import '../supabase_client.dart';
import 'user_model.dart';
import 'user_repository.dart';

/// Authentication service for handling Supabase Authentication
class SupabaseAuthService extends ChangeNotifier {
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
  static SupabaseAuthService? _instance;
  static Future<SupabaseAuthService> getInstance() async {
    _instance ??= SupabaseAuthService._();
    return _instance!;
  }

  SupabaseAuthService._() {
    _init();
  }

  void _init() async {
    try {
      // Get the current user from Supabase
      final session = SupabaseClient.instance.auth.currentSession;
      if (session != null) {
        _user = session.user;
      }

      // Listen for auth state changes
      SupabaseClient.instance.auth.onAuthStateChange.listen((data) {
        final AuthChangeEvent event = data.event;
        final Session? session = data.session;

        switch (event) {
          case AuthChangeEvent.signedIn:
            _user = session?.user;
            notifyListeners();
            break;
          case AuthChangeEvent.signedOut:
            _user = null;
            notifyListeners();
            break;
          case AuthChangeEvent.userUpdated:
            _user = session?.user;
            notifyListeners();
            break;
          case AuthChangeEvent.passwordRecovery:
            // Handle password recovery
            break;
          case AuthChangeEvent.tokenRefreshed:
            _user = session?.user;
            notifyListeners();
            break;
          case AuthChangeEvent.userDeleted:
            _user = null;
            notifyListeners();
            break;
          case AuthChangeEvent.mfaChallengeVerified:
            // Handle MFA challenge verified
            break;
        }
      });

      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      logger.severe('Error initializing auth service: $e');
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Sign in with email and password
  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      _setLoading(true);
      final response = await SupabaseClient.instance.auth.signInWithPassword(
        email: email,
        password: password,
      );

      _user = response.user;
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
      final response = await SupabaseClient.instance.auth.signUp(
        email: email,
        password: password,
      );

      _user = response.user;

      // Create user in database
      if (_user != null) {
        await UserRepository.instance.createUser(_user!);
      }

      return _user;
    } catch (e) {
      logger.severe('Error registering: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      _setLoading(true);
      await SupabaseClient.instance.auth.signOut();
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
      final session = SupabaseClient.instance.auth.currentSession;
      if (session != null) {
        _user = session.user;
        notifyListeners();
      }
    } catch (e) {
      logger.severe('Error reloading user: $e');
      rethrow;
    }
  }

  // Refresh session to get latest user data
  Future<void> refreshSession() async {
    try {
      _setLoading(true);

      // Get the current session
      final session = SupabaseClient.instance.auth.currentSession;
      if (session == null) {
        return;
      }

      // Refresh the session
      final response = await SupabaseClient.instance.auth.refreshSession();
      _user = response.user;
      notifyListeners();
    } catch (e) {
      logger.severe('Error refreshing session: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      _setLoading(true);
      await SupabaseClient.instance.auth.resetPasswordForEmail(email);
    } catch (e) {
      logger.severe('Error sending password reset email: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Sign in with Google
  Future<User?> signInWithGoogle() async {
    try {
      _setLoading(true);

      // Start the Google sign-in process
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        // User canceled the sign-in flow
        return null;
      }

      // Get auth details from Google
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Sign in with Supabase using Google token
      final response = await SupabaseClient.instance.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: googleAuth.idToken!,
        accessToken: googleAuth.accessToken,
      );

      _user = response.user;

      // Check if this is a new user
      if (response.session?.accessToken != null) {
        // Create or update user in database
        await UserRepository.instance.createOrUpdateUser(_user!);
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

      // Trigger the Facebook sign-in flow
      final LoginResult result = await FacebookAuth.instance.login();

      if (result.status != LoginStatus.success) {
        // User canceled the sign-in flow or it failed
        return null;
      }

      // Sign in with Supabase using Facebook token
      final response = await SupabaseClient.instance.auth.signInWithIdToken(
        provider: OAuthProvider.facebook,
        idToken: result.accessToken!.token,
      );

      _user = response.user;

      // Check if this is a new user
      if (response.session?.accessToken != null) {
        // Create or update user in database
        await UserRepository.instance.createOrUpdateUser(_user!);
      }

      return _user;
    } catch (e) {
      logger.severe('Error signing in with Facebook: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }
}
