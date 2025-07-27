import 'package:firebase_auth/firebase_auth.dart' as fb;
import '../../domain/repositories/auth_repository.dart';
import '../../domain/entities/user.dart';
import '../datasource/auth_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthDataSource _dataSource;

  AuthRepositoryImpl(this._dataSource);

  @override
  Future<void> signUpWithEmail(String email, String password) async {
    try {
      await _dataSource.createUserWithEmailAndPassword(email, password);
    } catch (e) {
      throw Exception('Failed to create account: $e');
    }
  }

  @override
  Future<User?> loginWithEmail(String email, String password) async {
    try {
      final result = await _dataSource.signInWithEmailAndPassword(email, password);
      final fbUser = result.user;

      if (fbUser == null) return null;

      return User(
        id: fbUser.uid,
        phone: fbUser.phoneNumber ?? '',
      );
    } catch (e) {
      throw Exception('Failed to login: $e');
    }
  }

  @override
  Future<void> logout() async {
    await _dataSource.signOut();
  }
}
