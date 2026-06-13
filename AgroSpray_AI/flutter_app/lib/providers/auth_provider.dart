import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;
  StreamSubscription<User?>? _subscription;

  User? _user;
  bool _loading = false;
  String? _error;

  User? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get loading => _loading;
  String? get error => _error;

  void startListening() {
    _subscription ??= _auth.authStateChanges().listen((user) {
      _user = user;
      notifyListeners();
    });
  }

  Future<void> login(String email, String password) async {
    await _execute(() async {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    });
  }

  Future<void> register(String email, String password, String name) async {
    await _execute(() async {
      final credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      await credential.user?.updateDisplayName(name);
      await credential.user?.reload();
    });
  }

  Future<void> resetPassword(String email) async {
    await _execute(() async {
      await _auth.sendPasswordResetEmail(email: email);
    });
  }

  Future<void> logout() async {
    await _execute(() async {
      await _auth.signOut();
    });
  }

  Future<void> _execute(Future<void> Function() action) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      await action();
      _user = _auth.currentUser;
    } on FirebaseAuthException catch (error) {
      _error = error.message ?? error.code;
    } catch (error) {
      _error = error.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
