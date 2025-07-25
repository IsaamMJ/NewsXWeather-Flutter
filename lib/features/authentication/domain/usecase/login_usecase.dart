import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<User?> execute({
    required String phone,
    required String otp,
  }) {
    if (phone.isEmpty || otp.isEmpty) {
      throw ArgumentError('Phone number and OTP are required.');
    }

    return repository.loginWithPhoneOtp(phone, otp);
  }
}
