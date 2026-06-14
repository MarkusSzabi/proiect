import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';

class SignInUseCase {
  const SignInUseCase(this._repository);
  final AuthRepository _repository;

  Future<AppUser> execute({
    required String email,
    required String password,
  }) async {
    if (email.isEmpty || password.isEmpty) {
      throw ArgumentError('Email and password cannot be empty');
    }
    return _repository.signInWithEmailPassword(email, password);
  }
}