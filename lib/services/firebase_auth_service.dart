import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthService {
  FirebaseAuthService({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<UserCredential> login({required String email, required String password}) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential> register({required String email, required String password}) {
    return _auth.createUserWithEmailAndPassword(email: email, password: password);
  }

  Future<void> sendPasswordResetEmail(String email) {
    return _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> updatePassword(String password) async {
    final user = currentUser;
    if (user == null) {
      throw FirebaseAuthException(code: 'no-user', message: 'No signed in user found.');
    }
    await user.updatePassword(password);
  }

  Future<void> updateDisplayName(String name) async {
    final user = currentUser;
    if (user == null) {
      throw FirebaseAuthException(code: 'no-user', message: 'No signed in user found.');
    }
    await user.updateDisplayName(name);
    await user.reload();
  }

  Future<void> signOut() => _auth.signOut();
}
