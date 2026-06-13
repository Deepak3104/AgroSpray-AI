import 'package:agro_spray/repositories/auth_repository.dart';
import 'package:agro_spray/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileRepository {
  ProfileRepository({
    required AuthRepository authRepository,
    required FirestoreService firestoreService,
  })  : _authRepository = authRepository,
        _firestoreService = firestoreService;

  final AuthRepository _authRepository;
  final FirestoreService _firestoreService;

  Future<void> updateName(String name) => _authRepository.updateDisplayName(name);

  Future<void> changePassword(String password) => _authRepository.changePassword(password);

  Future<void> logout() => _authRepository.logout();

  Future<void> updateProfilePhoto(String uid, String photoUrl) async {
    await _firestoreService.updateDocument(
      collectionPath: 'users',
      documentId: uid,
      data: {'photoUrl': photoUrl, 'updatedAt': DateTime.now().toIso8601String()},
    );
  }

  User? get currentUser => _authRepository.currentUser;
}
