// lib/providers/auth_provider.dart
// FULL FILE — select all and replace, do not append

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final authStateProvider = StreamProvider.autoDispose<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

final currentUserProvider = FutureProvider.autoDispose<UserModel?>((ref) async {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return null;
  return ref.read(authServiceProvider).getUserProfile(user.uid);
});

class AuthNotifier extends StateNotifier<AsyncValue<void>> {
  final AuthService _svc;

  AuthNotifier(this._svc) : super(const AsyncValue.data(null));

  Future<void> signUp({
    required String email,
    required String password,
  }) async {
    if (state.isLoading) return;
    state = const AsyncValue.loading();
    try {
      await _svc.signUp(email: email, password: password);
      // Immediately sign out to require them to log in after verifying
      await _svc.signOut();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    if (state.isLoading) return;
    state = const AsyncValue.loading();
    try {
      await _svc.signIn(email: email, password: password);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    try {
      await _svc.signOut();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void clearError() => state = const AsyncValue.data(null);
}

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<void>>(
  (ref) => AuthNotifier(ref.watch(authServiceProvider)),
);
