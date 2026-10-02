import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class OrganisationService {
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
  // ACCESS TOKEN HEADERS
  // ============================================================

  Future<Map<String, String>> _accessHeaders() async {
    final token = await _getAccessToken();

    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  // ============================================================
  // SETUP TOKEN HEADERS
  // ============================================================

  Map<String, String> _setupHeaders(String setupToken) {
    return {
      'Authorization': 'Bearer $setupToken',
      'Content-Type': 'application/json',
    };
  }

  // ============================================================
  // GET SHARED ORGANISATIONS
  // Uses setup token
  // ============================================================

  Future<List<dynamic>> getSharedOrganisations({
    required String setupToken,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/organisations/shared'),
      headers: _setupHeaders(setupToken),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data['organisations'] ?? [];
    }

    throw Exception(data['detail'] ?? 'Unable to load organisations.');
  }

  // ============================================================
  // CREATE ORGANISATION
  // Uses setup token
  // ============================================================

  Future<Map<String, dynamic>> createOrganisation({
    required String setupToken,
    required String name,
    required String description,
    String? website,
    String? phoneNumber,
    required String organisationType,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/organisations'),
      headers: _setupHeaders(setupToken),
      body: jsonEncode({
        'name': name,
        'description': description,
        'website': website,
        'phone_number': phoneNumber,
        'organisation_type': organisationType,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return data;
    }

    throw Exception(data['detail'] ?? 'Unable to create organisation.');
  }

  // ============================================================
  // REQUEST TO JOIN
  // Uses access token
  // ============================================================
  Future<Map<String, dynamic>> requestToJoin({
    required int organisationId,
    required String setupToken,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/organisations/$organisationId/join'),
      headers: _setupHeaders(setupToken),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return data;
    }

    throw Exception(data['detail'] ?? 'Unable to send join request.');
  }

  // Future<Map<String, dynamic>> requestToJoin({
  //   required int organisationId,
  // }) async {
  //   final response = await http.post(
  //     Uri.parse('$baseUrl/organisations/$organisationId/join'),
  //     headers: await _accessHeaders(),
  //   );

  //   final data = jsonDecode(response.body);

  //   if (response.statusCode == 200 || response.statusCode == 201) {
  //     return data;
  //   }

  //   throw Exception(data['detail'] ?? 'Unable to send join request.');
  // }

  // ============================================================
  // CANCEL JOIN REQUEST
  // ============================================================

  Future<Map<String, dynamic>> cancelJoinRequest({
    required int organisationId,
  }) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/organisations/$organisationId/join'),
      headers: await _accessHeaders(),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    }

    throw Exception(data['detail'] ?? 'Unable to cancel join request.');
  }

  // ============================================================
  // GET JOIN REQUEST STATUS
  // ============================================================

  Future<Map<String, dynamic>> getJoinRequestStatus({
    required int organisationId,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/organisations/$organisationId/join/status'),
      headers: await _accessHeaders(),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    }

    throw Exception(data['detail'] ?? 'Unable to check request status.');
  }

  // ============================================================
  // GET ORGANISATION MEMBERS
  // ============================================================

  Future<List<dynamic>> getOrganisationMembers({
    required int organisationId,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/organisations/$organisationId/members'),
      headers: await _accessHeaders(),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data['members'] ?? [];
    }

    throw Exception(data['detail'] ?? 'Unable to load organisation members.');
  }

  // ============================================================
  // GET JOIN REQUESTS
  // ============================================================

  Future<List<dynamic>> getJoinRequests({required int organisationId}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/organisations/$organisationId/join-requests'),
      headers: await _accessHeaders(),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data['requests'] ?? [];
    }

    throw Exception(data['detail'] ?? 'Unable to load join requests.');
  }

  // ============================================================
  // APPROVE JOIN REQUEST
  // ============================================================

  Future<void> approveJoinRequest({
    required int organisationId,
    required int userId,
  }) async {
    final response = await http.put(
      Uri.parse(
        '$baseUrl/organisations/$organisationId/'
        'join-requests/$userId/approve',
      ),
      headers: await _accessHeaders(),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return;
    }

    throw Exception(data['detail'] ?? 'Unable to approve join request.');
  }

  // ============================================================
  // REJECT JOIN REQUEST
  // ============================================================

  Future<void> rejectJoinRequest({
    required int organisationId,
    required int userId,
  }) async {
    final response = await http.put(
      Uri.parse(
        '$baseUrl/organisations/$organisationId/'
        'join-requests/$userId/reject',
      ),
      headers: await _accessHeaders(),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return;
    }

    throw Exception(data['detail'] ?? 'Unable to reject join request.');
  }

  // ============================================================
  // CHANGE MEMBER ROLE
  // ============================================================

  Future<void> changeMemberRole({
    required int organisationId,
    required int userId,
    required String newRole,
  }) async {
    final response = await http.put(
      Uri.parse(
        '$baseUrl/organisations/$organisationId/'
        'members/$userId/role?new_role=$newRole',
      ),
      headers: await _accessHeaders(),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return;
    }

    throw Exception(data['detail'] ?? 'Unable to change member role.');
  }

  // ============================================================
  // REMOVE MEMBER
  // ============================================================

  Future<void> removeMember({
    required int organisationId,
    required int userId,
  }) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/organisations/$organisationId/members/$userId'),
      headers: await _accessHeaders(),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return;
    }

    throw Exception(data['detail'] ?? 'Unable to remove member.');
  }

  // ============================================================
  // UPDATE ORGANISATION
  // ============================================================

  Future<Map<String, dynamic>> updateOrganisation({
    required int organisationId,
    required String name,
    required String description,
    String? website,
    String? phoneNumber,
    required String organisationType,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/organisations/$organisationId'),
      headers: await _accessHeaders(),
      body: jsonEncode({
        'name': name,
        'description': description,
        'website': website,
        'phone_number': phoneNumber,
        'organisation_type': organisationType,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    }

    throw Exception(data['detail'] ?? 'Unable to update organisation.');
  }
}
