import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class GrowingCycleService {
  static const String baseUrl = 'http://98.88.222.75:8000';

  // ============================================================
  // GET ACCESS TOKEN
  // ============================================================

  Future<String> _getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();

    final token = prefs.getString('access_token');

    if (token == null || token.isEmpty) {
      throw Exception('Access token not found. Please login again.');
    }

    return token;
  }

  // ============================================================
  // GET ACTIVE GROWING CYCLE
  // ============================================================

  Future<Map<String, dynamic>?> getActiveGrowingCycle({
    required int siteId,
    required int shelfId,
  }) async {
    final token = await _getAccessToken();

    final response = await http.get(
      Uri.parse(
        '$baseUrl/sites/$siteId/shelves/$shelfId/growing-cycles/active',
      ),
      headers: {'Authorization': 'Bearer $token'},
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      if (data == null) {
        return null;
      }

      return Map<String, dynamic>.from(data);
    }

    throw Exception(data['detail'] ?? 'Unable to load active growing cycle.');
  }

  // ============================================================
  // GET ALL GROWING CYCLES
  // ============================================================

  Future<List<dynamic>> getGrowingCycles({
    required int siteId,
    required int shelfId,
  }) async {
    final token = await _getAccessToken();

    final response = await http.get(
      Uri.parse('$baseUrl/sites/$siteId/shelves/$shelfId/growing-cycles'),
      headers: {'Authorization': 'Bearer $token'},
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    }

    throw Exception(data['detail'] ?? 'Unable to load growing cycles.');
  }

  // ============================================================
  // CREATE GROWING CYCLE
  // ============================================================

  Future<Map<String, dynamic>> createGrowingCycle({
    required int siteId,
    required int shelfId,
    required String startDate,
    required int targetHarvestDays,
  }) async {
    final token = await _getAccessToken();

    final response = await http.post(
      Uri.parse('$baseUrl/sites/$siteId/shelves/$shelfId/growing-cycles'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'start_date': startDate,
        'target_harvest_days': targetHarvestDays,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(data);
    }

    throw Exception(data['detail'] ?? 'Unable to start growing cycle.');
  }

  Future<Map<String, dynamic>> stopGrowingCycle({
    required int siteId,
    required int shelfId,
    required int cycleId,
    String? stopReason,
  }) async {
    final token = await _getAccessToken();

    final response = await http.put(
      Uri.parse(
        '$baseUrl/sites/$siteId/shelves/$shelfId/growing-cycles/$cycleId/stop',
      ),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'stop_reason': stopReason}),
    );

    if (response.statusCode != 200) {
      throw Exception(
        jsonDecode(response.body)['detail'] ?? 'Failed to stop growing cycle.',
      );
    }

    return jsonDecode(response.body);
  }
}
