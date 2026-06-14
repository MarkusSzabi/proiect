import '../entities/app_user.dart';

abstract class AuthRepository {
  Stream<AppUser?> get authStateChanges;
  Future<AppUser> signInWithEmailPassword(String email, String password);
  Future<AppUser> signUpWithEmailPassword({
    required String email,
    required String password,
    required String displayName,
  });
  Future<void> signOut();
  Future<void> sendPasswordResetEmail(String email);
  AppUser? get currentUser;
}