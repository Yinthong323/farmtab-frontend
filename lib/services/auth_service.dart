import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl = 'http://98.88.222.75:8000';

  // ============================================================
  // SIGN UP
  // ============================================================

  static Future<Map<String, dynamic>> signup({
    required String username,
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/signup'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    }

    throw Exception(data['detail'] ?? 'Signup failed.');
  }

  // ============================================================
  // VERIFY EMAIL
  // ============================================================

  static Future<Map<String, dynamic>> verifyEmail({
    required String email,
    required String code,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/verify'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'code': code}),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    }

    throw Exception(data['detail'] ?? 'Verification failed.');
  }

  // ============================================================
  // RESEND VERIFICATION CODE
  // ============================================================

  static Future<Map<String, dynamic>> resendCode({
    required String email,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/resend-code'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    }

    throw Exception(data['detail'] ?? 'Unable to resend code.');
  }

  // ============================================================
  // LOGIN
  // ============================================================

  static Future<Map<String, dynamic>> login({
    required String login,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'login': login, 'password': password}),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      final accessToken = data['access_token'];

      if (accessToken != null && accessToken.toString().isNotEmpty) {
        final prefs = await SharedPreferences.getInstance();

        await prefs.setString('access_token', accessToken.toString());
      }

      return data;
    }

    throw Exception(data['detail'] ?? 'Login failed.');
  }

  // ============================================================
  // FORGOT PASSWORD
  // ============================================================

  static Future<Map<String, dynamic>> forgotPassword({
    required String email,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/forgot-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    }

    throw Exception(data['detail'] ?? 'Unable to reset password.');
  }

  // ============================================================
  // VERIFY PASSWORD RESET CODE
  // ============================================================

  static Future<Map<String, dynamic>> verifyResetCode({
    required String email,
    required String code,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/reset-password/verify'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'code': code}),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    }

    throw Exception(data['detail'] ?? 'Invalid reset code.');
  }

  // ============================================================
  // RESET PASSWORD
  // ============================================================

  static Future<Map<String, dynamic>> resetPassword({
    required String resetToken,
    required String newPassword,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/reset-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'reset_token': resetToken,
        'new_password': newPassword,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    }

    throw Exception(data['detail'] ?? 'Unable to reset password.');
  }

  // ============================================================
  // RESEND PASSWORD RESET CODE
  // ============================================================

  static Future<Map<String, dynamic>> resendResetCode({
    required String email,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/reset-password/resend-code'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    }

    throw Exception(data['detail'] ?? 'Unable to resend reset code.');
  }
}
