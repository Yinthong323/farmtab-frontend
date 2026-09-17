import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ShelfService {
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
  // GET SHELVES
  // ============================================================

  Future<List<dynamic>> getShelves({required int siteId}) async {
    final token = await _getAccessToken();

    final response = await http.get(
      Uri.parse('$baseUrl/sites/$siteId/shelves'),
      headers: {'Authorization': 'Bearer $token'},
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    }

    throw Exception(data['detail'] ?? 'Unable to load Shelves.');
  }

  // ============================================================
  // CREATE SHELF
  // ============================================================

  Future<Map<String, dynamic>> createShelf({
    required int siteId,
    required String name,
    String? description,
    required String cropType,
    required String deviceSerialNumber,
    required String imagePath,
  }) async {
    final token = await _getAccessToken();

    if (imagePath.isEmpty) {
      throw Exception('Shelf image is required.');
    }

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/sites/$siteId/shelves'),
    );

    // ----------------------------------------------------------
    // Authorization
    // ----------------------------------------------------------

    request.headers['Authorization'] = 'Bearer $token';

    // ----------------------------------------------------------
    // Text fields
    // ----------------------------------------------------------

    request.fields['name'] = name;

    if (description != null && description.trim().isNotEmpty) {
      request.fields['description'] = description.trim();
    }

    request.fields['crop_type'] = cropType;

    request.fields['device_serial_number'] = deviceSerialNumber;

    // ----------------------------------------------------------
    // Image
    // ----------------------------------------------------------

    final extension = imagePath.split('.').last.toLowerCase();

    String mimeType;

    if (extension == 'png') {
      mimeType = 'png';
    } else if (extension == 'jpg' || extension == 'jpeg') {
      mimeType = 'jpeg';
    } else if (extension == 'webp') {
      mimeType = 'webp';
    } else {
      throw Exception(
        'Unsupported image format. Please select JPG, PNG, or WEBP.',
      );
    }

    request.files.add(
      await http.MultipartFile.fromPath(
        'image',
        imagePath,
        contentType: MediaType('image', mimeType),
      ),
    );

    // ----------------------------------------------------------
    // Send request
    // ----------------------------------------------------------

    final streamedResponse = await request.send();

    final response = await http.Response.fromStream(streamedResponse);

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(data);
    }

    throw Exception(data['detail'] ?? 'Unable to create Shelf.');
  }

  // ============================================================
  // GET ONE SHELF
  // ============================================================

  Future<Map<String, dynamic>> getShelf({
    required int siteId,
    required int shelfId,
  }) async {
    final token = await _getAccessToken();

    final response = await http.get(
      Uri.parse('$baseUrl/sites/$siteId/shelves/$shelfId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(data);
    }

    throw Exception(data['detail'] ?? 'Unable to load Shelf.');
  }

  Future<Map<String, dynamic>?> getLatestSensorReading({
    required int siteId,
    required int shelfId,
  }) async {
    final token = await _getAccessToken();

    final response = await http.get(
      Uri.parse(
        '$baseUrl/sites/$siteId/shelves/$shelfId/sensor-readings/latest',
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

    throw Exception(data['detail'] ?? 'Unable to load latest sensor reading.');
  }

  // ============================================================
  // UPDATE SHELF
  // ============================================================

  Future<Map<String, dynamic>> updateShelf({
    required int siteId,
    required int shelfId,
    required String name,
    String? description,
    required String cropType,
    required String deviceSerialNumber,
    String? imagePath,
  }) async {
    final token = await _getAccessToken();

    final request = http.MultipartRequest(
      'PUT',
      Uri.parse('$baseUrl/sites/$siteId/shelves/$shelfId'),
    );

    request.headers['Authorization'] = 'Bearer $token';

    // -----------------------------
    // Normal shelf information
    // -----------------------------

    request.fields['name'] = name;

    if (description != null && description.trim().isNotEmpty) {
      request.fields['description'] = description.trim();
    }

    request.fields['crop_type'] = cropType;
    request.fields['device_serial_number'] = deviceSerialNumber;

    // -----------------------------
    // Optional new image
    // -----------------------------

    if (imagePath != null && imagePath.isNotEmpty) {
      final extension = imagePath.split('.').last.toLowerCase();

      String mimeType;

      if (extension == 'png') {
        mimeType = 'png';
      } else if (extension == 'jpg' || extension == 'jpeg') {
        mimeType = 'jpeg';
      } else if (extension == 'webp') {
        mimeType = 'webp';
      } else {
        throw Exception(
          'Unsupported image format. Please select JPG, PNG, or WEBP.',
        );
      }

      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          imagePath,
          contentType: MediaType('image', mimeType),
        ),
      );
    }

    // -----------------------------
    // Send request
    // -----------------------------

    final streamedResponse = await request.send();

    final response = await http.Response.fromStream(streamedResponse);

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(data);
    }

    throw Exception(data['detail'] ?? 'Unable to update Shelf.');
  }
  // ============================================================
  // DELETE SHELF
  // ============================================================

  Future<void> deleteShelf({required int siteId, required int shelfId}) async {
    final token = await _getAccessToken();

    final response = await http.delete(
      Uri.parse('$baseUrl/sites/$siteId/shelves/$shelfId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return;
    }

    final data = jsonDecode(response.body);

    throw Exception(data['detail'] ?? 'Unable to delete Shelf.');
  }

  Future<Map<String, dynamic>> getShelfThresholds({
    required int siteId,
    required int shelfId,
  }) async {
    final token = await _getAccessToken();

    final response = await http.get(
      Uri.parse('$baseUrl/sites/$siteId/shelves/$shelfId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(data);
    }

    throw Exception(data['detail'] ?? 'Unable to load Shelf thresholds.');
  }

  Future<Map<String, dynamic>> updateShelfThresholds({
    required int siteId,
    required int shelfId,
    required double phMin,
    required double phMax,
    required double ecMin,
    required double ecMax,
    required double orpMin,
    required double orpMax,
    required double temperatureMin,
    required double temperatureMax,
  }) async {
    final token = await _getAccessToken();

    final response = await http.put(
      Uri.parse('$baseUrl/sites/$siteId/shelves/$shelfId/thresholds'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'ph_min': phMin,
        'ph_max': phMax,
        'ec_min': ecMin,
        'ec_max': ecMax,
        'orp_min': orpMin,
        'orp_max': orpMax,
        'temperature_min': temperatureMin,
        'temperature_max': temperatureMax,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(data);
    }

    throw Exception(data['detail'] ?? 'Unable to update Shelf thresholds.');
  }
}
