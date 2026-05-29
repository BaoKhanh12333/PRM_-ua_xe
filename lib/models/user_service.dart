import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  static const String _usersKey = 'racing_users_data';

  // Lấy toàn bộ dữ liệu users từ SharedPreferences
  static Future<Map<String, dynamic>> _getUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_usersKey);
    if (data == null) return {};
    return Map<String, dynamic>.from(json.decode(data));
  }

  // Lưu toàn bộ dữ liệu users
  static Future<void> _saveUsers(Map<String, dynamic> users) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_usersKey, json.encode(users));
  }

  // Đăng ký tài khoản mới
  static Future<bool> register(String username, String password) async {
    final users = await _getUsers();
    if (users.containsKey(username)) return false; // Tài khoản đã tồn tại
    users[username] = {
      'password': password,
      'balance': 1000000.0,
    };
    await _saveUsers(users);
    return true;
  }

  // Đăng nhập
  static Future<bool> login(String username, String password) async {
    final users = await _getUsers();
    if (!users.containsKey(username)) return false;
    return users[username]['password'] == password;
  }

  // Lấy số dư tài khoản
  static Future<double> getBalance(String username) async {
    final users = await _getUsers();
    if (!users.containsKey(username)) return 1000000.0;
    return (users[username]['balance'] as num).toDouble();
  }

  // Cập nhật số dư tài khoản
  static Future<void> updateBalance(String username, double balance) async {
    final users = await _getUsers();
    if (users.containsKey(username)) {
      users[username]['balance'] = balance;
      await _saveUsers(users);
    }
  }

  // Reset số dư về mặc định (khi cháy túi)
  static Future<void> resetBalance(String username) async {
    await updateBalance(username, 1000000.0);
  }

  // Format tiền VNĐ có dấu phẩy
  static String formatMoney(double amount) {
    String str = amount.toStringAsFixed(0);
    bool isNegative = str.startsWith('-');
    if (isNegative) str = str.substring(1);

    String result = '';
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      count++;
      result = str[i] + result;
      if (count % 3 == 0 && i != 0) {
        result = ',$result';
      }
    }
    return (isNegative ? '-' : '') + result;
  }
}
