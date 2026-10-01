import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class GlobalAlertService {
  static const String websocketUrl = 'ws://98.88.222.75:8000/ws/alerts';

  WebSocketChannel? _channel;
  StreamSubscription? _subscription;

  final StreamController<Map<String, dynamic>> _alertController =
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get alerts => _alertController.stream;

  Future<void> connect() async {
    if (_channel != null) {
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();

      final token = prefs.getString('access_token');

      if (token == null || token.isEmpty) {
        return;
      }

      final channel = WebSocketChannel.connect(Uri.parse(websocketUrl));

      _channel = channel;

      _subscription = channel.stream.listen(
        (message) {
          try {
            final data = jsonDecode(message.toString());

            if (data is Map<String, dynamic> && data['type'] == 'NEW_ALERT') {
              _alertController.add(data);
            }
          } catch (e) {
            print('Invalid global alert WebSocket message: $e');
          }
        },
        onError: (error) {
          print('Global alert WebSocket error: $error');
          _cleanup();
        },
        onDone: () {
          print('Global alert WebSocket disconnected.');
          _cleanup();
        },
      );
    } catch (e) {
      print('Failed to connect global alert WebSocket: $e');
      _cleanup();
    }
  }

  void disconnect() {
    _cleanup();
  }

  void _cleanup() {
    _subscription?.cancel();
    _subscription = null;

    _channel?.sink.close();
    _channel = null;
  }

  void dispose() {
    disconnect();
    _alertController.close();
  }
}
