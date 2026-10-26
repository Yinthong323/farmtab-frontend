// import 'dart:convert';

// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';

// class LayerService {
//   static const String baseUrl = 'http://cyphyai.usm.my:6000';

//   Future<String> _getAccessToken() async {
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('access_token');

//     if (token == null || token.isEmpty) {
//       throw Exception('Access token not found. Please login again.');
//     }

//     return token;
//   }

//   // Reads the backend's error message ("detail") from a failed response.
//   String _errorMessage(http.Response response, String fallback) {
//     try {
//       final body = jsonDecode(response.body);

//       if (body is Map && body['detail'] is String) {
//         return body['detail'] as String;
//       }

//       // Validation errors (422) come back as a list
//       if (body is Map && body['detail'] is List) {
//         return 'Please check the values you entered.';
//       }
//     } catch (_) {
//       // Keep the fallback message.
//     }

//     return fallback;
//   }

//   String _dateString(DateTime date) {
//     return '${date.year.toString().padLeft(4, '0')}-'
//         '${date.month.toString().padLeft(2, '0')}-'
//         '${date.day.toString().padLeft(2, '0')}';
//   }

//   // ------------------------------------------------------------
//   // The six camera layers of a shelf, each with its latest image,
//   // canopy measurement and active growing cycle (if any).
//   // ------------------------------------------------------------
//   Future<List<Map<String, dynamic>>> getShelfLayers({
//     required int siteId,
//     required int shelfId,
//   }) async {
//     final token = await _getAccessToken();

//     final response = await http.get(
//       Uri.parse('$baseUrl/sites/$siteId/shelves/$shelfId/layers'),
//       headers: {'Authorization': 'Bearer $token'},
//     );

//     if (response.statusCode != 200) {
//       throw Exception(
//         _errorMessage(response, 'Unable to load growth monitoring layers.'),
//       );
//     }

//     final data = jsonDecode(response.body) as List<dynamic>;

//     return data.map((item) => Map<String, dynamic>.from(item as Map)).toList();
//   }

//   // ------------------------------------------------------------
//   // Start a growing cycle on one layer.
//   // The result contains "first_capture":
//   //   requested   - a photo is being taken now
//   //   existing    - photos taken since the transplant date were attached
//   //   tonight_8pm - the first photo arrives at the 8 PM capture
//   // ------------------------------------------------------------
//   Future<Map<String, dynamic>> startCycle({
//     required int siteId,
//     required int shelfId,
//     required int layerId,
//     required DateTime transplantDate,
//     required int plantCount,
//     required String variety,
//     String? notes,
//   }) async {
//     final token = await _getAccessToken();

//     final response = await http.post(
//       Uri.parse(
//         '$baseUrl/sites/$siteId/shelves/$shelfId/layers/$layerId/cycles',
//       ),
//       headers: {
//         'Authorization': 'Bearer $token',
//         'Content-Type': 'application/json',
//       },
//       body: jsonEncode({
//         'transplant_date': _dateString(transplantDate),
//         'plant_count': plantCount,
//         'variety': variety,
//         if (notes != null && notes.isNotEmpty) 'notes': notes,
//       }),
//     );

//     if (response.statusCode != 200) {
//       throw Exception(
//         _errorMessage(response, 'Unable to start growing cycle.'),
//       );
//     }

//     return Map<String, dynamic>.from(jsonDecode(response.body) as Map);
//   }

//   // ------------------------------------------------------------
//   // Abort an active cycle (started by mistake, or a failed batch).
//   // ------------------------------------------------------------
//   Future<void> abortCycle({
//     required int siteId,
//     required int shelfId,
//     required int layerId,
//     required int cycleId,
//     String? reason,
//   }) async {
//     final token = await _getAccessToken();

//     final response = await http.post(
//       Uri.parse(
//         '$baseUrl/sites/$siteId/shelves/$shelfId/layers/$layerId'
//         '/cycles/$cycleId/abort',
//       ),
//       headers: {
//         'Authorization': 'Bearer $token',
//         'Content-Type': 'application/json',
//       },
//       body: jsonEncode({
//         if (reason != null && reason.isNotEmpty) 'reason': reason,
//       }),
//     );

//     if (response.statusCode != 200) {
//       throw Exception(
//         _errorMessage(response, 'Unable to abort growing cycle.'),
//       );
//     }
//   }

//   // ------------------------------------------------------------
//   // HARVEST
//   // ------------------------------------------------------------

//   String _cyclePath(int siteId, int shelfId, int layerId, int cycleId) {
//     return '$baseUrl/sites/$siteId/shelves/$shelfId/layers/$layerId'
//         '/cycles/$cycleId';
//   }

//   // Which photo will be the final harvest photo?
//   // The result has a "state":
//   //   needs_capture  - no usable photo today; ask the camera for one
//   //   waiting        - the camera has not answered yet
//   //   measuring      - the photo arrived, the canopy is being measured
//   //   ready          - usable ("image" is included)
//   //   measure_failed - the photo could not be measured ("image" is included)
//   //   expired        - the camera did not answer in time
//   Future<Map<String, dynamic>> getHarvestPhoto({
//     required int siteId,
//     required int shelfId,
//     required int layerId,
//     required int cycleId,
//     int? requestId,
//   }) async {
//     final token = await _getAccessToken();

//     final query = requestId == null ? '' : '?request_id=$requestId';

//     final response = await http.get(
//       Uri.parse(
//         '${_cyclePath(siteId, shelfId, layerId, cycleId)}/harvest-photo$query',
//       ),
//       headers: {'Authorization': 'Bearer $token'},
//     );

//     if (response.statusCode != 200) {
//       throw Exception(
//         _errorMessage(response, 'Unable to check the harvest photo.'),
//       );
//     }

//     return Map<String, dynamic>.from(jsonDecode(response.body) as Map);
//   }

//   // Asks the layer's camera to take a photo now. Returns the request id.
//   Future<int> requestHarvestCapture({
//     required int siteId,
//     required int shelfId,
//     required int layerId,
//     required int cycleId,
//   }) async {
//     final token = await _getAccessToken();

//     final response = await http.post(
//       Uri.parse(
//         '${_cyclePath(siteId, shelfId, layerId, cycleId)}/harvest/capture',
//       ),
//       headers: {'Authorization': 'Bearer $token'},
//     );

//     if (response.statusCode != 200) {
//       throw Exception(_errorMessage(response, 'Unable to request a photo.'));
//     }

//     final body = jsonDecode(response.body) as Map;

//     return body['request_id'] as int;
//   }

//   // Ends the cycle and records its final result.
//   Future<Map<String, dynamic>> harvestCycle({
//     required int siteId,
//     required int shelfId,
//     required int layerId,
//     required int cycleId,
//     int? imageId,
//     double? finalWeightG,
//     String? note,
//   }) async {
//     final token = await _getAccessToken();

//     final response = await http.post(
//       Uri.parse('${_cyclePath(siteId, shelfId, layerId, cycleId)}/harvest'),
//       headers: {
//         'Authorization': 'Bearer $token',
//         'Content-Type': 'application/json',
//       },
//       body: jsonEncode({
//         'image_id': imageId,
//         'final_weight_g': finalWeightG,
//         if (note != null && note.isNotEmpty) 'harvest_note': note,
//       }),
//     );

//     if (response.statusCode != 200) {
//       throw Exception(
//         _errorMessage(response, 'Unable to harvest the growing cycle.'),
//       );
//     }

//     return Map<String, dynamic>.from(jsonDecode(response.body) as Map);
//   }

//   // Turns '/uploads/layers/...' into a full URL the app can load.
//   static String imageUrl(String path) => '$baseUrl$path';
// }
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LayerService {
  static const String baseUrl = 'http://cyphyai.usm.my:6000';

  Future<String> _getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    if (token == null || token.isEmpty) {
      throw Exception('Access token not found. Please login again.');
    }

    return token;
  }

  // Reads the backend's error message ("detail") from a failed response.
  String _errorMessage(http.Response response, String fallback) {
    try {
      final body = jsonDecode(response.body);

      if (body is Map && body['detail'] is String) {
        return body['detail'] as String;
      }

      // Validation errors (422) come back as a list
      if (body is Map && body['detail'] is List) {
        return 'Please check the values you entered.';
      }
    } catch (_) {
      // Keep the fallback message.
    }

    return fallback;
  }

  String _dateString(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  // ------------------------------------------------------------
  // The six camera layers of a shelf, each with its latest image,
  // canopy measurement and active growing cycle (if any).
  // ------------------------------------------------------------
  Future<List<Map<String, dynamic>>> getShelfLayers({
    required int siteId,
    required int shelfId,
  }) async {
    final token = await _getAccessToken();

    final response = await http.get(
      Uri.parse('$baseUrl/sites/$siteId/shelves/$shelfId/layers'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception(
        _errorMessage(response, 'Unable to load growth monitoring layers.'),
      );
    }

    final data = jsonDecode(response.body) as List<dynamic>;

    return data.map((item) => Map<String, dynamic>.from(item as Map)).toList();
  }

  // ------------------------------------------------------------
  // Start a growing cycle on one layer.
  // The result contains "first_capture":
  //   requested   - a photo is being taken now
  //   existing    - photos taken since the transplant date were attached
  //   tonight_8pm - the first photo arrives at the 8 PM capture
  // ------------------------------------------------------------
  Future<Map<String, dynamic>> startCycle({
    required int siteId,
    required int shelfId,
    required int layerId,
    required DateTime transplantDate,
    required int plantCount,
    required String variety,
    String? notes,
  }) async {
    final token = await _getAccessToken();

    final response = await http.post(
      Uri.parse(
        '$baseUrl/sites/$siteId/shelves/$shelfId/layers/$layerId/cycles',
      ),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'transplant_date': _dateString(transplantDate),
        'plant_count': plantCount,
        'variety': variety,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        _errorMessage(response, 'Unable to start growing cycle.'),
      );
    }

    return Map<String, dynamic>.from(jsonDecode(response.body) as Map);
  }

  // ------------------------------------------------------------
  // Abort an active cycle (started by mistake, or a failed batch).
  // ------------------------------------------------------------
  Future<void> abortCycle({
    required int siteId,
    required int shelfId,
    required int layerId,
    required int cycleId,
    String? reason,
  }) async {
    final token = await _getAccessToken();

    final response = await http.post(
      Uri.parse(
        '$baseUrl/sites/$siteId/shelves/$shelfId/layers/$layerId'
        '/cycles/$cycleId/abort',
      ),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        if (reason != null && reason.isNotEmpty) 'reason': reason,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        _errorMessage(response, 'Unable to abort growing cycle.'),
      );
    }
  }

  // ------------------------------------------------------------
  // One layer's cycle, day by day (Layer Detail page).
  // Without cycleId: the active cycle, or the latest harvested one.
  // ------------------------------------------------------------
  Future<Map<String, dynamic>> getLayerDetail({
    required int siteId,
    required int shelfId,
    required int layerId,
    int? cycleId,
  }) async {
    final token = await _getAccessToken();

    final query = cycleId == null ? '' : '?cycle_id=$cycleId';

    final response = await http.get(
      Uri.parse(
        '$baseUrl/sites/$siteId/shelves/$shelfId/layers/$layerId/detail$query',
      ),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception(_errorMessage(response, 'Unable to load layer details.'));
    }

    return Map<String, dynamic>.from(jsonDecode(response.body) as Map);
  }

  // ------------------------------------------------------------
  // HARVEST
  // ------------------------------------------------------------

  String _cyclePath(int siteId, int shelfId, int layerId, int cycleId) {
    return '$baseUrl/sites/$siteId/shelves/$shelfId/layers/$layerId'
        '/cycles/$cycleId';
  }

  // Which photo will be the final harvest photo?
  // The result has a "state":
  //   needs_capture  - no usable photo today; ask the camera for one
  //   waiting        - the camera has not answered yet
  //   measuring      - the photo arrived, the canopy is being measured
  //   ready          - usable ("image" is included)
  //   measure_failed - the photo could not be measured ("image" is included)
  //   expired        - the camera did not answer in time
  Future<Map<String, dynamic>> getHarvestPhoto({
    required int siteId,
    required int shelfId,
    required int layerId,
    required int cycleId,
    int? requestId,
  }) async {
    final token = await _getAccessToken();

    final query = requestId == null ? '' : '?request_id=$requestId';

    final response = await http.get(
      Uri.parse(
        '${_cyclePath(siteId, shelfId, layerId, cycleId)}/harvest-photo$query',
      ),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception(
        _errorMessage(response, 'Unable to check the harvest photo.'),
      );
    }

    return Map<String, dynamic>.from(jsonDecode(response.body) as Map);
  }

  // Asks the layer's camera to take a photo now. Returns the request id.
  Future<int> requestHarvestCapture({
    required int siteId,
    required int shelfId,
    required int layerId,
    required int cycleId,
  }) async {
    final token = await _getAccessToken();

    final response = await http.post(
      Uri.parse(
        '${_cyclePath(siteId, shelfId, layerId, cycleId)}/harvest/capture',
      ),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception(_errorMessage(response, 'Unable to request a photo.'));
    }

    final body = jsonDecode(response.body) as Map;

    return body['request_id'] as int;
  }

  // Ends the cycle and records its final result.
  Future<Map<String, dynamic>> harvestCycle({
    required int siteId,
    required int shelfId,
    required int layerId,
    required int cycleId,
    int? imageId,
    double? finalWeightG,
    String? note,
  }) async {
    final token = await _getAccessToken();

    final response = await http.post(
      Uri.parse('${_cyclePath(siteId, shelfId, layerId, cycleId)}/harvest'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'image_id': imageId,
        'final_weight_g': finalWeightG,
        if (note != null && note.isNotEmpty) 'harvest_note': note,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        _errorMessage(response, 'Unable to harvest the growing cycle.'),
      );
    }

    return Map<String, dynamic>.from(jsonDecode(response.body) as Map);
  }

  // Turns '/uploads/layers/...' into a full URL the app can load.
  static String imageUrl(String path) => '$baseUrl$path';
}
