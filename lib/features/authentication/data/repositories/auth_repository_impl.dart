import 'package:firebase_auth/firebase_auth.dart' as fb;
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final fb.FirebaseAuth _firebaseAuth;

  AuthRepositoryImpl(this._firebaseAuth);

  String? _verificationId; // Stores verificationId for OTP validation

  @override
  Future<void> signUpWithPhone(String phone) async {
    await _firebaseAuth.verifyPhoneNumber(
      phoneNumber: phone,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (fb.PhoneAuthCredential credential) async {
        // Optional: auto sign-in if verification completes automatically
        try {
          await _firebaseAuth.signInWithCredential(credential);
        } catch (e) {
          print('Auto-verification failed: $e');
        }
      },
      verificationFailed: (fb.FirebaseAuthException e) {
        throw Exception('Phone verification failed: ${e.message}');
      },
      codeSent: (String verificationId, int? resendToken) {
        _verificationId = verificationId;
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        _verificationId = verificationId;
      },
    );
  }

  @override
  Future<User?> loginWithPhoneOtp(String phone, String otp) async {
    if (_verificationId == null) {
      throw Exception('No verification ID. Please request OTP again.');
    }

    try {
      final credential = fb.PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otp,
      );

      final result = await _firebaseAuth.signInWithCredential(credential);
      final fbUser = result.user;

      if (fbUser == null) return null;

      return User(
        id: fbUser.uid,
        phone: fbUser.phoneNumber ?? '',
      );
    } catch (e) {
      throw Exception('OTP verification failed: $e');
    }
  }

  @override
  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }
}
