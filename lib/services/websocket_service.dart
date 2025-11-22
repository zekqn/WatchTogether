// lib/services/websocket_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WebSocketService {
  WebSocketService._internal();
  static final WebSocketService instance = WebSocketService._internal();

  WebSocketChannel? _channel;
  StreamSubscription? _sub;

  final StreamController<Map<String, dynamic>> _broadcast =
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get stream => _broadcast.stream;

  bool get connected => _channel != null;

  // connect once
  void connect(String url) {
    if (_channel != null) return;
    try {
      _channel = WebSocketChannel.connect(Uri.parse(url));
      _sub = _channel!.stream.listen(
        (raw) {
          try {
            final parsed = jsonDecode(raw);
            if (parsed is Map<String, dynamic>) _broadcast.add(parsed);
          } catch (e) {
            // ignore parse errors
          }
        },
        onDone: () {
          _cleanup();
        },
        onError: (e) {
          _cleanup();
        },
        cancelOnError: true,
      );
    } catch (e) {
      // ignore connection error
    }
  }

  void _cleanup() {
    try {
      _sub?.cancel();
    } catch (_) {}
    _sub = null;
    try {
      _channel = null;
    } catch (_) {}
  }

  void send(Map<String, dynamic> payload) {
    try {
      if (_channel != null) _channel!.sink.add(jsonEncode(payload));
    } catch (e) {}
  }

  /// Helper to explicitly inform server that client leaves a room
  void sendLeaveRoom({required String roomId, required String username}) {
    send({'type': 'leave_room', 'roomId': roomId, 'username': username});
  }

  Future<void> saveNickname(String nick) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString('wt_nick', nick);
    // notify server optionally
    send({'type': 'nick_update', 'nickname': nick});
  }

  Future<String?> loadSavedNickname() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString('wt_nick');
  }

  void dispose() {
    try {
      _sub?.cancel();
    } catch (_) {}
    try {
      _channel?.sink.close();
    } catch (_) {}
    _cleanup();
    try {
      _broadcast.close();
    } catch (_) {}
  }
}
