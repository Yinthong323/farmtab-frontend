import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SiteService {
  static const String baseUrl = 'http://98.88.222.75:8000';

  // ============================================================
  // GET SITES
  // ============================================================

  Future<List<dynamic>> getSites({required int organisationId}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    final response = await http.get(
      Uri.parse('$baseUrl/organisations/$organisationId/sites'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data['sites'] ?? [];
    }

    throw Exception(data['detail'] ?? 'Unable to load Sites.');
  }

  Future<Map<String, dynamic>> createSite({
    required int organisationId,
    required String name,
    String? description,
    required String imagePath,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    if (token == null || token.isEmpty) {
      throw Exception('Access token not found. Please login again.');
    }

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/organisations/$organisationId/sites'),
    );

    // Authentication
    request.headers['Authorization'] = 'Bearer $token';

    // Text fields
    request.fields['name'] = name;

    if (description != null && description.trim().isNotEmpty) {
      request.fields['description'] = description.trim();
    }

    // Image file
    final extension = imagePath.split('.').last.toLowerCase();

    String mimeType;

    if (extension == 'png') {
      mimeType = 'png';
    } else if (extension == 'jpg' || extension == 'jpeg') {
      mimeType = 'jpeg';
    } else if (extension == 'webp') {
      mimeType = 'webp';
    } else {
      throw Exception('Unsupported image format.');
    }

    request.files.add(
      await http.MultipartFile.fromPath(
        'image',
        imagePath,
        contentType: MediaType('image', mimeType),
      ),
    );

    // Send request
    final streamedResponse = await request.send();

    // Convert streamed response to normal response
    final response = await http.Response.fromStream(streamedResponse);

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return data;
    }

    throw Exception(data['detail'] ?? 'Unable to create Site.');
  }

  Future<Map<String, dynamic>> updateSite({
    required int organisationId,
    required int siteId,
    required String name,
    String? description,
    String? imagePath,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    if (token == null || token.isEmpty) {
      throw Exception('Access token not found. Please login again.');
    }

    final request = http.MultipartRequest(
      'PUT',
      Uri.parse('$baseUrl/organisations/$organisationId/sites/$siteId'),
    );

    request.headers['Authorization'] = 'Bearer $token';

    request.fields['name'] = name;

    if (description != null && description.trim().isNotEmpty) {
      request.fields['description'] = description.trim();
    }

    // Only upload a new image if the user selected one.
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
        throw Exception('Unsupported image format.');
      }

      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          imagePath,
          contentType: MediaType('image', mimeType),
        ),
      );
    }

    final streamedResponse = await request.send();

    final response = await http.Response.fromStream(streamedResponse);

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    }

    throw Exception(data['detail'] ?? 'Unable to update Site.');
  }

  Future<void> deleteSite({
    required int organisationId,
    required int siteId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    if (token == null || token.isEmpty) {
      throw Exception('Access token not found. Please login again.');
    }

    final response = await http.delete(
      Uri.parse('$baseUrl/organisations/$organisationId/sites/$siteId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return;
    }

    final data = jsonDecode(response.body);

    throw Exception(data['detail'] ?? 'Unable to delete Site.');
  }
}
