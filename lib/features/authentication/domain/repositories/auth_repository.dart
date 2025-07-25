import '../entities/user.dart';

abstract class AuthRepository {
  Future<User?> loginWithPhoneOtp(String phone, String otp);
  Future<void> signUpWithPhone(String phone); // ✅ FIXED
  Future<void> logout();
}
