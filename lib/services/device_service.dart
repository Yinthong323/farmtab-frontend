import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class DeviceService {
  static const String baseUrl = 'http://98.88.222.75:8000';

  Future<String> _getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();

    final token = prefs.getString('access_token');

    if (token == null || token.isEmpty) {
      throw Exception('Access token not found. Please login again.');
    }

    return token;
  }

  Future<List<Map<String, dynamic>>> getDevices({
    required int organisationId,
  }) async {
    final token = await _getAccessToken();

    final response = await http.get(
      Uri.parse('$baseUrl/organisations/$organisationId/devices'),
      headers: {'Authorization': 'Bearer $token'},
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(data);
    }

    if (data is Map<String, dynamic> && data['detail'] != null) {
      throw Exception(data['detail']);
    }

    throw Exception('Unable to load devices.');
  }

  Future<Map<String, dynamic>> updateDeviceSerialNumber({
    required int siteId,
    required int shelfId,
    required String deviceSerialNumber,
  }) async {
    final token = await _getAccessToken();

    final uri = Uri.parse('$baseUrl/sites/$siteId/shelves/$shelfId/device')
        .replace(queryParameters: {'device_serial_number': deviceSerialNumber});

    final response = await http.put(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(data);
    }

    if (data is Map<String, dynamic> && data['detail'] != null) {
      throw Exception(data['detail']);
    }

    throw Exception('Unable to update device.');
  }
}
