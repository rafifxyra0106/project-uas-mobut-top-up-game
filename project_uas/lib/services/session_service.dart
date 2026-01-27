import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  static Future<void> saveSession({
    required int userId,
    required String name,
    required String role,
    required String token,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('logged_in', true);
    await prefs.setInt('user_id', userId); // ✅ INT
    await prefs.setString('name', name);
    await prefs.setString('role', role);
    await prefs.setString('token', token);
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('logged_in') ?? false;
  }

  static Future<int> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('user_id') ?? 0; // ✅ INT
  }

  static Future<String> getName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('name') ?? 'User';
  }

  static Future<String> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('role') ?? 'user';
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
