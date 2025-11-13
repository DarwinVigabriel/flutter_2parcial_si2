import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  late SharedPreferences _prefs;

  StorageService._internal();

  factory StorageService() {
    return _instance;
  }

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Token
  Future<void> saveToken(String token) async {
    await _prefs.setString('auth_token', token);
  }

  String? getToken() {
    return _prefs.getString('auth_token');
  }

  Future<void> clearToken() async {
    await _prefs.remove('auth_token');
  }

  // User
  Future<void> saveUser(Map<String, dynamic> user) async {
    await _prefs.setString('user_data', user.toString());
  }

  Future<void> clearUser() async {
    await _prefs.remove('user_data');
  }

  // Cart ID
  Future<void> saveCartId(String cartId) async {
    await _prefs.setString('cart_id', cartId);
  }

  String? getCartId() {
    return _prefs.getString('cart_id');
  }

  Future<void> clearCartId() async {
    await _prefs.remove('cart_id');
  }

  // Device Info
  Future<void> saveDeviceInfo(Map<String, String> deviceInfo) async {
    await _prefs.setString('device_model', deviceInfo['model'] ?? '');
    await _prefs.setString('device_os', deviceInfo['os'] ?? '');
  }

  // Logout
  Future<void> logout() async {
    await clearToken();
    await clearUser();
    await clearCartId();
  }
}
