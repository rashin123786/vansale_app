// ─────────────────────────────────────────────
//  core/network/app_storage.dart
// ─────────────────────────────────────────────

import 'package:shared_preferences/shared_preferences.dart';

class AppStorage {
  static const _tokenKey = 'auth_token';
  static const _userIdKey = 'user_id';
  static const _storeIdKey = 'store_id';
  static const _routeIdKey = 'route_id';
  static const _vanIdKey = 'van_id';

  final SharedPreferences _prefs;
  AppStorage(this._prefs);

  // ── Token ──
  String? get token => _prefs.getString(_tokenKey);
  Future<void> saveToken(String token) => _prefs.setString(_tokenKey, token);

  // ── User / Store / Route / Van ──
  String? get userId => _prefs.getString(_userIdKey);
  String? get storeId => _prefs.getString(_storeIdKey);
  String? get routeId => _prefs.getString(_routeIdKey);
  String? get vanId => _prefs.getString(_vanIdKey);

  Future<void> saveUserSession({
    required String userId,
    required String storeId,
    required String routeId,
    required String vanId,
  }) async {
    await _prefs.setString(_userIdKey, userId);
    await _prefs.setString(_storeIdKey, storeId);
    await _prefs.setString(_routeIdKey, routeId);
    await _prefs.setString(_vanIdKey, vanId);
  }

  Future<void> clear() => _prefs.clear();
  bool get isLoggedIn => token != null && token!.isNotEmpty;
}
