import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/app_user.dart';
import 'auth_repository.dart';

class LocalAuthRepository implements AuthRepository {
  LocalAuthRepository(this._preferences);

  final SharedPreferences _preferences;

  static const _sessionKey = 'auth.session';

  @override
  Future<AppUser?> restoreSession() async {
    final raw = _preferences.getString(_sessionKey);
    if (raw == null || raw.isEmpty) return null;
    return AppUser.fromMap(Map<String, dynamic>.from(jsonDecode(raw) as Map));
  }

  @override
  Future<AppUser> signIn({required String name, required String email}) async {
    final user = AppUser(
      id: email.trim().toLowerCase(),
      name: name.trim(),
      email: email.trim().toLowerCase(),
    );
    await _preferences.setString(_sessionKey, jsonEncode(user.toMap()));
    return user;
  }

  @override
  Future<void> signOut() async {
    await _preferences.remove(_sessionKey);
  }
}
