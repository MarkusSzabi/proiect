import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/firebase_auth_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._dataSource);
  final FirebaseAuthDataSource _dataSource;

  @override
  Stream<AppUser?> get authStateChanges => _dataSource.authStateChanges;

  @override
  AppUser? get currentUser => _dataSource.currentUser;

  @override
  Future<AppUser> signInWithEmailPassword(String email, String password) =>
      _dataSource.signInWithEmailPassword(email, password);

  @override
  Future<AppUser> signUpWithEmailPassword({
    required String email,
    required String password,
    required String displayName,
  }) =>
      _dataSource.signUpWithEmailPassword(
        email: email,
        password: password,
        displayName: displayName,
      );

  @override
  Future<void> signOut() => _dataSource.signOut();

  @override
  Future<void> sendPasswordResetEmail(String email) =>
      _dataSource.sendPasswordResetEmail(email);
}