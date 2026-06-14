import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/firebase_auth_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/sign_in_usecase.dart';
import '../../domain/usecases/sign_up_usecase.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>(
  (_) => FirebaseAuth.instance,
);

final firestoreProvider = Provider<FirebaseFirestore>(
  (_) => FirebaseFirestore.instance,
);

final authDataSourceProvider = Provider<FirebaseAuthDataSource>((ref) {
  return FirebaseAuthDataSource(
    firebaseAuth: ref.read(firebaseAuthProvider),
    firestore: ref.read(firestoreProvider),
  );
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.read(authDataSourceProvider));
});

final signInUseCaseProvider = Provider<SignInUseCase>((ref) {
  return SignInUseCase(ref.read(authRepositoryProvider));
});

final signUpUseCaseProvider = Provider<SignUpUseCase>((ref) {
  return SignUpUseCase(ref.read(authRepositoryProvider));
});

final authStateProvider = StreamProvider<AppUser?>((ref) {
  return ref.read(authRepositoryProvider).authStateChanges;
});

// ── Auth State ────────────────────────────────────────────

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState {
  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
  });

  final AuthStatus status;
  final AppUser? user;
  final String? errorMessage;

  bool get isLoading => status == AuthStatus.loading;

  AuthState copyWith({
    AuthStatus? status,
    AppUser? user,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._signIn, this._signUp, this._repository)
      : super(const AuthState());

  final SignInUseCase _signIn;
  final SignUpUseCase _signUp;
  final AuthRepository _repository;

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final user = await _signIn.execute(email: email, password: password);
      state = state.copyWith(status: AuthStatus.authenticated, user: user);
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final user = await _signUp.execute(
        email: email,
        password: password,
        displayName: displayName,
      );
      state = state.copyWith(status: AuthStatus.authenticated, user: user);
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> signOut() async {
    await _repository.signOut();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  void clearError() {
    state = state.copyWith(status: AuthStatus.initial, errorMessage: null);
  }

  // ── Update display name ───────────────────────────────
  Future<void> updateDisplayName(String newName) async {
    try {
      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser == null) throw Exception('Not authenticated');

      await firebaseUser.updateDisplayName(newName);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(firebaseUser.uid)
          .update({'displayName': newName});
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  // ── Change password ───────────────────────────────────
  Future<void> changePassword({
    required String email,
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser == null) throw Exception('Not authenticated');

      // Re-autentificare necesară înainte de schimbarea parolei
      final credential = EmailAuthProvider.credential(
        email: email,
        password: currentPassword,
      );
      await firebaseUser.reauthenticateWithCredential(credential);
      await firebaseUser.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'wrong-password':
          throw Exception('Current password is incorrect');
        case 'weak-password':
          throw Exception('New password is too weak');
        case 'requires-recent-login':
          throw Exception(
              'Please log out and log in again before changing your password');
        default:
          throw Exception(e.message ?? 'Failed to change password');
      }
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }
}

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    ref.read(signInUseCaseProvider),
    ref.read(signUpUseCaseProvider),
    ref.read(authRepositoryProvider),
  );
});
