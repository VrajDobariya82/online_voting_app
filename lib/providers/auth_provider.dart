import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Global state management for the logged-in voter session.
/// Wraps FirebaseAuth + Firestore user document into a single
/// ChangeNotifier so any widget can read session data without
/// re-fetching from Firebase.
class AppAuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _user;
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  StreamSubscription<DocumentSnapshot>? _userDocSub;

  AppAuthProvider() {
    // Listen to auth state changes
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  // ---- Getters ----
  User? get user => _user;
  Map<String, dynamic>? get userData => _userData;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _user != null;

  String get displayName =>
      _userData?['name'] ?? _user?.displayName ?? 'Voter';
  String get email => _userData?['email'] ?? _user?.email ?? '';
  String get phone => _userData?['phone'] ?? '';
  String get voterId => _userData?['voterId'] ?? 'Not Set';
  bool get isVerified => _userData?['isVerified'] ?? false;
  String get uid => _user?.uid ?? '';

  // ---- Auth state listener ----
  void _onAuthStateChanged(User? firebaseUser) {
    _user = firebaseUser;

    // Cancel previous Firestore listener
    _userDocSub?.cancel();
    _userDocSub = null;

    if (firebaseUser != null) {
      // Listen to user document in Firestore
      _userDocSub = _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .snapshots()
          .listen((snapshot) {
        _userData = snapshot.data();
        _isLoading = false;
        notifyListeners();
      }, onError: (_) {
        _userData = null;
        _isLoading = false;
        notifyListeners();
      });
    } else {
      _userData = null;
      _isLoading = false;
      notifyListeners();
    }
  }

  // ---- Auth Actions ----

  /// Sign in with email and password. Returns null on success, error message on failure.
  Future<String?> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return null; // success
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Login failed';
    } catch (e) {
      return 'Login failed: $e';
    }
  }

  /// Register a new user. Returns null on success, error message on failure.
  Future<String?> register({
    required String name,
    required String email,
    required String phone,
    required String voterId,
    required String password,
  }) async {
    try {
      UserCredential credential =
          await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      await credential.user?.updateDisplayName(name.trim());

      await _firestore
          .collection('users')
          .doc(credential.user!.uid)
          .set({
        'name': name.trim(),
        'email': email.trim(),
        'phone': phone.trim(),
        'voterId': voterId.trim(),
        'isVerified': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return null; // success
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Registration failed';
    } catch (e) {
      return 'Registration failed: $e';
    }
  }

  /// Update the current user's profile in both Auth and Firestore.
  Future<String?> updateProfile({
    required String name,
    String? phone,
  }) async {
    if (_user == null) return 'Not logged in';
    try {
      await _user!.updateDisplayName(name.trim());
      await _user!.reload();

      final updateData = <String, dynamic>{
        'name': name.trim(),
      };
      if (phone != null) {
        updateData['phone'] = phone.trim();
      }

      await _firestore
          .collection('users')
          .doc(_user!.uid)
          .update(updateData);

      return null;
    } catch (e) {
      return 'Update failed: $e';
    }
  }

  /// Change password
  Future<String?> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (_user == null || _user!.email == null) return 'Not logged in';
    try {
      // Re-authenticate first
      final credential = EmailAuthProvider.credential(
        email: _user!.email!,
        password: currentPassword,
      );
      await _user!.reauthenticateWithCredential(credential);
      await _user!.updatePassword(newPassword);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Password change failed';
    } catch (e) {
      return 'Password change failed: $e';
    }
  }

  /// Sign out the current user.
  Future<void> signOut() async {
    await _auth.signOut();
  }

  @override
  void dispose() {
    _userDocSub?.cancel();
    super.dispose();
  }
}
