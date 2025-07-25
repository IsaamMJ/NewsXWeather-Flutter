import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class SignUpUseCase {
  final AuthRepository repository;

  SignUpUseCase(this.repository);

  /// Sends OTP to the provided phone number
  Future<void> sendOtp(String phone) async {
    await repository.signUpWithPhone(phone); // triggers OTP sending
  }

  /// Verifies OTP and signs up the user
  Future<User?> execute({required String phone, required String otp}) async {
    if (phone.isEmpty || otp.isEmpty) {
      throw ArgumentError('Phone number and OTP are required.');
    }

    return repository.loginWithPhoneOtp(phone, otp); // same as login, Supabase auto creates user
  }
}
