import '../repositories/auth_repository.dart';
import '../entities/user.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<User?> execute(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      throw ArgumentError('Email and Password are required.');
    }
    return repository.loginWithEmail(email, password);
  }
}
