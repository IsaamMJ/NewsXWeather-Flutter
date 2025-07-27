import '../repositories/auth_repository.dart';

class SignUpUseCase {
  final AuthRepository repository;

  SignUpUseCase(this.repository);

  Future<void> execute(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      throw ArgumentError('Email and Password are required.');
    }
    await repository.signUpWithEmail(email, password);
  }
}
