import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';

class SignUpUseCase {
  const SignUpUseCase(this._repository);
  final AuthRepository _repository;

  Future<AppUser> execute({
    required String email,
    required String password,
    required String displayName,
  }) async {
    if (email.isEmpty || password.isEmpty || displayName.isEmpty) {
      throw ArgumentError('All fields are required');
    }
    if (password.length < 8) {
      throw ArgumentError('Password must be at least 8 characters');
    }
    return _repository.signUpWithEmailPassword(
      email: email,
      password: password,
      displayName: displayName,
    );
  }
}