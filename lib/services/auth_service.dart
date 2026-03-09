// lib/services/auth_service.dart
// FULL FILE — select all and replace, do not append

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserModel> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // SEND REAL VERIFICATION EMAIL
      if (cred.user != null && !cred.user!.emailVerified) {
        await cred.user!.sendEmailVerification();
      }

      final model = UserModel(
        uid: cred.user!.uid,
        email: email.trim(),
        createdAt: DateTime.now(),
      );
      await _db
          .collection('users')
          .doc(cred.user!.uid)
          .set(model.toMap(), SetOptions(merge: true));

      return model;
    } on FirebaseAuthException catch (e) {
      debugPrint('🔴 signUp: ${e.code}');
      throw _msg(e.code);
    } catch (e) {
      debugPrint('🔴 signUp unknown: $e');
      throw 'Registration failed. Please try again.';
    }
  }

  Future<User> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (!cred.user!.emailVerified) {
        await _auth.signOut(); // Keep them out until they verify
        throw 'Please verify your email address before logging in. Check your inbox!';
      }

      return cred.user!;
    } on FirebaseAuthException catch (e) {
      debugPrint('🔴 signIn: ${e.code}');
      throw _msg(e.code);
    } catch (e) {
      debugPrint('🔴 signIn unknown: $e');
      throw 'Sign in failed. Check your connection.';
    }
  }

  Future<void> signOut() => _auth.signOut();

  Future<UserModel?> getUserProfile(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (!doc.exists) return null;
      return UserModel.fromMap(doc.data()!, uid);
    } catch (e) {
      return null;
    }
  }

  String _msg(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'An account with this email already exists.\nPlease sign in instead.';
      case 'invalid-email':
        return 'That email address is not valid.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'operation-not-allowed':
        return 'Email/password sign-in is not enabled. Contact support.';
      case 'user-not-found':
        return 'No account found with this email.\nPlease register first.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-credential':
        return 'Invalid email or password.\nPlease check your details and try again.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many failed attempts.\nPlease wait a few minutes and try again.';
      case 'network-request-failed':
        return 'No internet connection.\nPlease check your network.';
      default:
        debugPrint('🔴 Unhandled Firebase code: $code');
        return 'Something went wrong (code: $code).\nPlease try again.';
    }
  }
}
