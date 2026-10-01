import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static const String baseUrl = 'http://98.88.222.75:8000';

  Future<String> _getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    if (token == null || token.isEmpty) {
      throw Exception('Access token not found. Please login again.');
    }

    return token;
  }

  Future<Map<String, String>> _authHeaders() async {
    final token = await _getAccessToken();

    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  /// Get notifications for the current user's approved organisations.
  Future<List<Map<String, dynamic>>> getNotifications({int limit = 50}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/notifications?limit=$limit'),
      headers: await _authHeaders(),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(data);
    }

    throw Exception(data['detail'] ?? 'Unable to load notifications.');
  }

  /// Mark one notification as read.
  Future<void> markAsRead(int notificationId) async {
    final response = await http.put(
      Uri.parse('$baseUrl/notifications/$notificationId/read'),
      headers: await _authHeaders(),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return;
    }

    throw Exception(data['detail'] ?? 'Unable to mark notification as read.');
  }

  Future<List<Map<String, dynamic>>> getShelfNotifications({
    required int shelfId,
    int limit = 50,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/notifications/shelf/$shelfId?limit=$limit'),
      headers: await _authHeaders(),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(data);
    }

    throw Exception(data['detail'] ?? 'Unable to load shelf notifications.');
  }

  Future<void> markShelfNotificationsAsRead({required int shelfId}) async {
    final response = await http.put(
      Uri.parse('$baseUrl/notifications/shelf/$shelfId/read-all'),
      headers: await _authHeaders(),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return;
    }

    throw Exception(
      data['detail'] ?? 'Unable to mark shelf notifications as read.',
    );
  }
}
