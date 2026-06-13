import 'package:agro_spray/core/constants/app_constants.dart';
import 'package:agro_spray/models/app_user.dart';
import 'package:agro_spray/services/firebase_auth_service.dart';
import 'package:agro_spray/services/firestore_service.dart';
import 'package:agro_spray/services/local_storage_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {
  AuthRepository({
    required FirebaseAuthService firebaseAuthService,
    required FirestoreService firestoreService,
    required LocalStorageService localStorageService,
  })  : _firebaseAuthService = firebaseAuthService,
        _firestoreService = firestoreService,
        _localStorageService = localStorageService;

  final FirebaseAuthService _firebaseAuthService;
  final FirestoreService _firestoreService;
  final LocalStorageService _localStorageService;

  Stream<User?> authStateChanges() => _firebaseAuthService.authStateChanges();

  User? get currentUser => _firebaseAuthService.currentUser;

  Future<AppUser?> login({required String email, required String password}) async {
    final credential = await _firebaseAuthService.login(email: email, password: password);
    await _localStorageService.saveLastEmail(email);
    return _mapFirebaseUser(credential.user);
  }

  Future<AppUser?> register({required String email, required String password, required String name}) async {
    final credential = await _firebaseAuthService.register(email: email, password: password);
    final user = credential.user;
    if (user == null) {
      return null;
    }
    await user.updateDisplayName(name);
    await _firestoreService.setDocument(
      collectionPath: AppConstants.usersCollection,
      documentId: user.uid,
      data: AppUser(
        uid: user.uid,
        email: email,
        name: name,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ).toMap(),
    );
    return _mapFirebaseUser(user);
  }

  Future<void> sendPasswordResetEmail(String email) {
    return _firebaseAuthService.sendPasswordResetEmail(email);
  }

  Future<void> changePassword(String password) {
    return _firebaseAuthService.updatePassword(password);
  }

  Future<void> logout() => _firebaseAuthService.signOut();

  Future<void> updateDisplayName(String name) async {
    await _firebaseAuthService.updateDisplayName(name);
    final user = currentUser;
    if (user != null) {
      await _firestoreService.updateDocument(
        collectionPath: AppConstants.usersCollection,
        documentId: user.uid,
        data: {'name': name, 'updatedAt': DateTime.now().toIso8601String()},
      );
    }
  }

  AppUser? _mapFirebaseUser(User? user) {
    if (user == null) {
      return null;
    }
    return AppUser(
      uid: user.uid,
      email: user.email ?? '',
      name: user.displayName ?? '',
      photoUrl: user.photoURL,
    );
  }
}
