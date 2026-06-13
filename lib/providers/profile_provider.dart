import 'package:agro_spray/core/utils/request_state.dart';
import 'package:agro_spray/models/app_user.dart';
import 'package:agro_spray/repositories/profile_repository.dart';
import 'package:flutter/material.dart';

class ProfileProvider extends ChangeNotifier {
  ProfileProvider({required ProfileRepository profileRepository}) : _profileRepository = profileRepository;

  final ProfileRepository _profileRepository;
  RequestStatus _status = RequestStatus.idle;
  String? _errorMessage;
  AppUser? _user;

  RequestStatus get status => _status;
  String? get errorMessage => _errorMessage;
  AppUser? get user => _user;

  void syncUser(AppUser? user) {
    _user = user;
    notifyListeners();
  }

  Future<void> updateName(String name) async {
    _status = RequestStatus.loading;
    notifyListeners();
    try {
      await _profileRepository.updateName(name);
      if (_user != null) {
        _user = AppUser(
          uid: _user!.uid,
          email: _user!.email,
          name: name,
          photoUrl: _user!.photoUrl,
          phone: _user!.phone,
          role: _user!.role,
          createdAt: _user!.createdAt,
          updatedAt: DateTime.now(),
        );
      }
      _status = RequestStatus.success;
    } catch (error) {
      _status = RequestStatus.error;
      _errorMessage = error.toString();
    }
    notifyListeners();
  }

  Future<void> changePassword(String password) async {
    _status = RequestStatus.loading;
    notifyListeners();
    try {
      await _profileRepository.changePassword(password);
      _status = RequestStatus.success;
    } catch (error) {
      _status = RequestStatus.error;
      _errorMessage = error.toString();
    }
    notifyListeners();
  }

  Future<void> logout() => _profileRepository.logout();
}
