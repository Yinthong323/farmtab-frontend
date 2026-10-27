// // import 'dart:async';
// // import 'dart:convert';
// // import 'dart:typed_data';

// // import 'package:http/http.dart' as http;
// // import 'package:shared_preferences/shared_preferences.dart';

// // class AssistantService {
// //   static const String baseUrl = 'http://cyphyai.usm.my:6000';

// //   Future<String> _getAccessToken() async {
// //     final prefs = await SharedPreferences.getInstance();
// //     final token = prefs.getString('access_token');

// //     if (token == null || token.isEmpty) {
// //       throw Exception('Access token not found. Please login again.');
// //     }

// //     return token;
// //   }

// //   // Reads the backend's error message ("detail") from a failed response.
// //   String _errorMessage(http.Response response) {
// //     try {
// //       final body = jsonDecode(utf8.decode(response.bodyBytes));

// //       if (body is Map && body['detail'] is String) {
// //         return body['detail'] as String;
// //       }
// //     } catch (_) {
// //       // Keep the fallback message.
// //     }

// //     return 'The assistant could not answer right now.';
// //   }

// //   // ------------------------------------------------------------
// //   // Ask a question, optionally with a photo.
// //   //
// //   // history: the earlier messages, oldest first, as
// //   //          [{'role': 'user' | 'assistant', 'text': '...'}]
// //   // The server adds the shelf's live data and asks Claude.
// //   // ------------------------------------------------------------
// //   Future<String> sendMessage({
// //     required int siteId,
// //     required int shelfId,
// //     required String message,
// //     required List<Map<String, String>> history,
// //     Uint8List? imageBytes,
// //     String? imageName,
// //   }) async {
// //     final token = await _getAccessToken();

// //     final request = http.MultipartRequest(
// //       'POST',
// //       Uri.parse('$baseUrl/sites/$siteId/shelves/$shelfId/assistant/chat'),
// //     );

// //     request.headers['Authorization'] = 'Bearer $token';
// //     request.fields['message'] = message;
// //     request.fields['history'] = jsonEncode(history);

// //     if (imageBytes != null) {
// //       request.files.add(
// //         http.MultipartFile.fromBytes(
// //           'image',
// //           imageBytes,
// //           filename: imageName ?? 'photo.jpg',
// //         ),
// //       );
// //     }

// //     http.Response response;

// //     try {
// //       final streamed = await request.send().timeout(
// //         const Duration(seconds: 120),
// //       );

// //       response = await http.Response.fromStream(streamed);
// //     } on TimeoutException {
// //       throw Exception('The assistant took too long. Please try again.');
// //     }

// //     if (response.statusCode != 200) {
// //       throw Exception(_errorMessage(response));
// //     }

// //     // Decode as UTF-8 ourselves, otherwise symbols such as the micro sign
// //     // in "uS/cm" or the degree sign can come out garbled.
// //     final body = jsonDecode(utf8.decode(response.bodyBytes)) as Map;

// //     return (body['reply'] ?? '').toString();
// //   }
// // }

// import 'dart:async';
// import 'dart:convert';
// import 'dart:typed_data';

// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';

// class AssistantService {
//   static const String baseUrl = 'http://cyphyai.usm.my:6000';

//   Future<String> _getAccessToken() async {
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('access_token');

//     if (token == null || token.isEmpty) {
//       throw Exception('Access token not found. Please login again.');
//     }

//     return token;
//   }

//   String _base(int siteId, int shelfId) =>
//       '$baseUrl/sites/$siteId/shelves/$shelfId/assistant';

//   // Decode as UTF-8 ourselves, otherwise symbols such as the micro sign in
//   // "uS/cm" or the degree sign can come out garbled.
//   dynamic _decode(http.Response response) =>
//       jsonDecode(utf8.decode(response.bodyBytes));

//   // Reads the backend's error message ("detail") from a failed response.
//   String _errorMessage(http.Response response, String fallback) {
//     try {
//       final body = _decode(response);

//       if (body is Map && body['detail'] is String) {
//         return body['detail'] as String;
//       }
//     } catch (_) {
//       // Keep the fallback message.
//     }

//     return fallback;
//   }

//   // ------------------------------------------------------------
//   // Ask a question. The chat is created on the first question; later
//   // questions pass its id. Use EITHER an uploaded photo (imageBytes)
//   // OR one of the farm's own photos (layerImageId), not both.
//   //
//   // Returns: conversation_id, title, reply, model ...
//   // ------------------------------------------------------------
//   Future<Map<String, dynamic>> sendMessage({
//     required int siteId,
//     required int shelfId,
//     required String message,
//     int? conversationId,
//     int? layerImageId,
//     Uint8List? imageBytes,
//     String? imageName,
//   }) async {
//     final token = await _getAccessToken();

//     final request = http.MultipartRequest(
//       'POST',
//       Uri.parse('${_base(siteId, shelfId)}/send'),
//     );

//     request.headers['Authorization'] = 'Bearer $token';
//     request.fields['message'] = message;

//     if (conversationId != null) {
//       request.fields['conversation_id'] = '$conversationId';
//     }

//     if (layerImageId != null) {
//       request.fields['layer_image_id'] = '$layerImageId';
//     }

//     if (imageBytes != null) {
//       request.files.add(
//         http.MultipartFile.fromBytes(
//           'image',
//           imageBytes,
//           filename: imageName ?? 'photo.jpg',
//         ),
//       );
//     }

//     http.Response response;

//     try {
//       final streamed = await request.send().timeout(
//         const Duration(seconds: 130),
//       );

//       response = await http.Response.fromStream(streamed);
//     } on TimeoutException {
//       throw Exception('The assistant took too long. Please try again.');
//     }

//     if (response.statusCode != 200) {
//       throw Exception(
//         _errorMessage(response, 'The assistant could not answer right now.'),
//       );
//     }

//     return Map<String, dynamic>.from(_decode(response) as Map);
//   }

//   // ------------------------------------------------------------
//   // Saved chats
//   // ------------------------------------------------------------

//   Future<List<Map<String, dynamic>>> listConversations({
//     required int siteId,
//     required int shelfId,
//   }) async {
//     final token = await _getAccessToken();

//     final response = await http.get(
//       Uri.parse('${_base(siteId, shelfId)}/conversations'),
//       headers: {'Authorization': 'Bearer $token'},
//     );

//     if (response.statusCode != 200) {
//       throw Exception(_errorMessage(response, 'Unable to load your chats.'));
//     }

//     final data = _decode(response) as List<dynamic>;

//     return data.map((item) => Map<String, dynamic>.from(item as Map)).toList();
//   }

//   Future<Map<String, dynamic>> getConversation({
//     required int siteId,
//     required int shelfId,
//     required int conversationId,
//   }) async {
//     final token = await _getAccessToken();

//     final response = await http.get(
//       Uri.parse('${_base(siteId, shelfId)}/conversations/$conversationId'),
//       headers: {'Authorization': 'Bearer $token'},
//     );

//     if (response.statusCode != 200) {
//       throw Exception(_errorMessage(response, 'Unable to open this chat.'));
//     }

//     return Map<String, dynamic>.from(_decode(response) as Map);
//   }

//   Future<void> deleteConversation({
//     required int siteId,
//     required int shelfId,
//     required int conversationId,
//   }) async {
//     final token = await _getAccessToken();

//     final response = await http.delete(
//       Uri.parse('${_base(siteId, shelfId)}/conversations/$conversationId'),
//       headers: {'Authorization': 'Bearer $token'},
//     );

//     if (response.statusCode != 200) {
//       throw Exception(_errorMessage(response, 'Unable to delete this chat.'));
//     }
//   }

//   // The preview of a photo the user attached in an earlier question.
//   // It needs the login, so it is fetched here instead of with Image.network.
//   Future<Uint8List> getMessageImage({
//     required int siteId,
//     required int shelfId,
//     required int messageId,
//   }) async {
//     final token = await _getAccessToken();

//     final response = await http.get(
//       Uri.parse('${_base(siteId, shelfId)}/messages/$messageId/image'),
//       headers: {'Authorization': 'Bearer $token'},
//     );

//     if (response.statusCode != 200) {
//       throw Exception('Photo not available.');
//     }

//     return response.bodyBytes;
//   }
// }

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AssistantService {
  static const String baseUrl = 'http://cyphyai.usm.my:6000';

  Future<String> _getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    if (token == null || token.isEmpty) {
      throw Exception('Access token not found. Please login again.');
    }

    return token;
  }

  String _base(int siteId, int shelfId) =>
      '$baseUrl/sites/$siteId/shelves/$shelfId/assistant';

  // Decode as UTF-8 ourselves, otherwise symbols such as the micro sign in
  // "uS/cm" or the degree sign can come out garbled.
  dynamic _decode(http.Response response) =>
      jsonDecode(utf8.decode(response.bodyBytes));

  // Reads the backend's error message ("detail") from a failed response.
  String _errorMessage(http.Response response, String fallback) {
    try {
      final body = _decode(response);

      if (body is Map && body['detail'] is String) {
        return body['detail'] as String;
      }
    } catch (_) {
      // Keep the fallback message.
    }

    return fallback;
  }

  // ------------------------------------------------------------
  // Ask a question. The chat is created on the first question; later
  // questions pass its id. Use EITHER an uploaded photo (imageBytes)
  // OR one of the farm's own photos (layerImageId), not both.
  //
  // Returns: conversation_id, title, reply, model ...
  // ------------------------------------------------------------
  Future<Map<String, dynamic>> sendMessage({
    required int siteId,
    required int shelfId,
    required String message,
    int? conversationId,
    int? layerImageId,
    Uint8List? imageBytes,
    String? imageName,
  }) async {
    final token = await _getAccessToken();

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${_base(siteId, shelfId)}/send'),
    );

    request.headers['Authorization'] = 'Bearer $token';
    request.fields['message'] = message;

    if (conversationId != null) {
      request.fields['conversation_id'] = '$conversationId';
    }

    if (layerImageId != null) {
      request.fields['layer_image_id'] = '$layerImageId';
    }

    if (imageBytes != null) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          imageBytes,
          filename: imageName ?? 'photo.jpg',
        ),
      );
    }

    http.Response response;

    try {
      final streamed = await request.send().timeout(
        const Duration(seconds: 130),
      );

      response = await http.Response.fromStream(streamed);
    } on TimeoutException {
      throw Exception('The assistant took too long. Please try again.');
    }

    if (response.statusCode != 200) {
      throw Exception(
        _errorMessage(response, 'The assistant could not answer right now.'),
      );
    }

    return Map<String, dynamic>.from(_decode(response) as Map);
  }

  // ------------------------------------------------------------
  // The same question, but the answer streams in piece by piece.
  //
  // Yields events (maps), one per line sent by the server:
  //   {event: delta, text: ...}      a piece of the answer
  //   {event: done, conversation_id, title, ...}   the answer is complete and saved
  //   {event: title, title: ...}     a better title, a moment after "done"
  //   {event: error, detail: ...}    something failed
  //
  // Problems with the request itself (empty question, unknown chat ...)
  // are thrown as an Exception before any event arrives.
  // ------------------------------------------------------------
  Stream<Map<String, dynamic>> sendMessageStream({
    required int siteId,
    required int shelfId,
    required String message,
    int? conversationId,
    int? layerImageId,
    Uint8List? imageBytes,
    String? imageName,
  }) async* {
    final token = await _getAccessToken();

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${_base(siteId, shelfId)}/send-stream'),
    );

    request.headers['Authorization'] = 'Bearer $token';
    request.fields['message'] = message;

    if (conversationId != null) {
      request.fields['conversation_id'] = '$conversationId';
    }

    if (layerImageId != null) {
      request.fields['layer_image_id'] = '$layerImageId';
    }

    if (imageBytes != null) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          imageBytes,
          filename: imageName ?? 'photo.jpg',
        ),
      );
    }

    final client = http.Client();

    try {
      http.StreamedResponse response;

      try {
        // This waits for the first reply from the server, not for the whole answer
        response = await client
            .send(request)
            .timeout(const Duration(seconds: 130));
      } on TimeoutException {
        throw Exception('The assistant took too long. Please try again.');
      }

      if (response.statusCode != 200) {
        final body = await http.Response.fromStream(response);

        throw Exception(
          _errorMessage(body, 'The assistant could not answer right now.'),
        );
      }

      final lines = response.stream
          .transform(utf8.decoder)
          .transform(const LineSplitter());

      await for (final line in lines) {
        if (line.trim().isEmpty) continue;

        final event = jsonDecode(line);

        if (event is Map) {
          yield Map<String, dynamic>.from(event);
        }
      }
    } finally {
      client.close();
    }
  }

  // ------------------------------------------------------------
  // Saved chats
  // ------------------------------------------------------------

  Future<List<Map<String, dynamic>>> listConversations({
    required int siteId,
    required int shelfId,
  }) async {
    final token = await _getAccessToken();

    final response = await http.get(
      Uri.parse('${_base(siteId, shelfId)}/conversations'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception(_errorMessage(response, 'Unable to load your chats.'));
    }

    final data = _decode(response) as List<dynamic>;

    return data.map((item) => Map<String, dynamic>.from(item as Map)).toList();
  }

  Future<Map<String, dynamic>> getConversation({
    required int siteId,
    required int shelfId,
    required int conversationId,
  }) async {
    final token = await _getAccessToken();

    final response = await http.get(
      Uri.parse('${_base(siteId, shelfId)}/conversations/$conversationId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception(_errorMessage(response, 'Unable to open this chat.'));
    }

    return Map<String, dynamic>.from(_decode(response) as Map);
  }

  Future<void> deleteConversation({
    required int siteId,
    required int shelfId,
    required int conversationId,
  }) async {
    final token = await _getAccessToken();

    final response = await http.delete(
      Uri.parse('${_base(siteId, shelfId)}/conversations/$conversationId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception(_errorMessage(response, 'Unable to delete this chat.'));
    }
  }

  // The preview of a photo the user attached in an earlier question.
  // It needs the login, so it is fetched here instead of with Image.network.
  Future<Uint8List> getMessageImage({
    required int siteId,
    required int shelfId,
    required int messageId,
  }) async {
    final token = await _getAccessToken();

    final response = await http.get(
      Uri.parse('${_base(siteId, shelfId)}/messages/$messageId/image'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception('Photo not available.');
    }

    return response.bodyBytes;
  }
}
