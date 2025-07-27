import 'package:firebase_auth/firebase_auth.dart' as fb;

class AuthDataSource {
  final fb.FirebaseAuth _firebaseAuth;

  AuthDataSource(this._firebaseAuth);

  // Sign up with email and password
  Future<fb.UserCredential> createUserWithEmailAndPassword(String email, String password) async {
    return await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
  }

  // Sign in with email and password
  Future<fb.UserCredential> signInWithEmailAndPassword(String email, String password) async {
    return await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
  }

  // Sign out
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
