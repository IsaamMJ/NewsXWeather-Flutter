import '../entities/user.dart';

abstract class AuthRepository {
  Future<void> signUpWithEmail(String email, String password);  // Updated to use email for signup
  Future<User?> loginWithEmail(String email, String password);  // Updated to use email for login
  Future<void> logout();  // Keep logout method for signing out
}
