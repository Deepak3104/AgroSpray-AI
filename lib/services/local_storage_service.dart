import 'package:agro_spray/core/constants/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  LocalStorageService._();

  static final LocalStorageService instance = LocalStorageService._();

  late final SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> saveThemeMode(String value) => _prefs.setString(AppConstants.userThemeKey, value);

  String? getThemeMode() => _prefs.getString(AppConstants.userThemeKey);

  Future<void> saveLastEmail(String email) => _prefs.setString(AppConstants.lastEmailKey, email);

  String? getLastEmail() => _prefs.getString(AppConstants.lastEmailKey);
}
