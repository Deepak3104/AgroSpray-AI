import 'package:agro_spray/core/utils/request_state.dart';
import 'package:agro_spray/models/app_user.dart';
import 'package:agro_spray/repositories/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider({required AuthRepository authRepository}) : _authRepository = authRepository;

  final AuthRepository _authRepository;
  RequestStatus _status = RequestStatus.idle;
  String? _errorMessage;
  AppUser? _user;
  Stream<User?>? _subscriptionStream;

  RequestStatus get status => _status;
  String? get errorMessage => _errorMessage;
  AppUser? get user => _user;
  bool get isAuthenticated => _authRepository.currentUser != null;
  String? get lastEmail => _authRepository.currentUser?.email;

  void initialize() {
    _subscriptionStream = _authRepository.authStateChanges();
    _subscriptionStream!.listen((firebaseUser) {
      _user = firebaseUser == null
          ? null
          : AppUser(
              uid: firebaseUser.uid,
              email: firebaseUser.email ?? '',
              name: firebaseUser.displayName ?? '',
              photoUrl: firebaseUser.photoURL,
            );
      notifyListeners();
    });
  }

  Future<void> login(String email, String password) async {
    await _runTask(() async {
      _user = await _authRepository.login(email: email, password: password);
    });
  }

  Future<void> register(String name, String email, String password) async {
    await _runTask(() async {
      _user = await _authRepository.register(email: email, password: password, name: name);
    });
  }

  Future<void> forgotPassword(String email) async {
    await _runTask(() async {
      await _authRepository.sendPasswordResetEmail(email);
    });
  }

  Future<void> logout() async {
    await _runTask(() async {
      await _authRepository.logout();
      _user = null;
    });
  }

  Future<void> _runTask(Future<void> Function() action) async {
    _status = RequestStatus.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      await action();
      _status = RequestStatus.success;
    } on FirebaseAuthException catch (error) {
      _status = RequestStatus.error;
      _errorMessage = error.message ?? error.code;
    } catch (error) {
      _status = RequestStatus.error;
      _errorMessage = error.toString();
    }
    notifyListeners();
  }
}
