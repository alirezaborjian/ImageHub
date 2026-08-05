import 'dart:async';
import 'dart:convert';
import 'dart:io';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  Socket? _socket;
  StreamSubscription? _subscription;
  Completer<Map<String, dynamic>>? _pendingCompleter;

  bool get isConnected => _socket != null;

  Future<bool> connectToServer({String host = '10.0.2.2', int port = 8085}) async {
    if (_socket != null) return true;
    try {
      _socket = await Socket.connect(host, port).timeout(const Duration(seconds: 5));
      _subscription = _socket!
          .cast<List<int>>()
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen(
        (data) {
          if (_pendingCompleter != null && !_pendingCompleter!.isCompleted) {
            try {
              final jsonResponse = jsonDecode(data);
              _pendingCompleter!.complete(jsonResponse);
            } catch (e) {
              _pendingCompleter!.completeError(e);
            }
          }
        },
        onError: (error) {
          _closeSocket();
        },
        onDone: () {
          _closeSocket();
        },
      );
      return true;
    } catch (e) {
      _closeSocket();
      return false;
    }
  }

  Future<Map<String, dynamic>> sendRequest(Map<String, dynamic> request) async {
    if (_socket == null) {
      bool connected = await connectToServer();
      if (!connected) {
        return {'statusCode': 500, 'message': 'Could not connect to server'};
      }
    }

    _pendingCompleter = Completer<Map<String, dynamic>>();

    try {
      String jsonString = jsonEncode(request) + '\n';
      _socket!.write(jsonString);
      await _socket!.flush();

      final response = await _pendingCompleter!.future.timeout(
        const Duration(seconds: 8),
        onTimeout: () {
          _closeSocket();
          return {'statusCode': 408, 'message': 'Request timeout'};
        },
      );

      _closeSocket();
      return response;
    } catch (e) {
      _closeSocket();
      return {'statusCode': 500, 'message': 'Error sending request: $e'};
    }
  }

  Future<Map<String, dynamic>> toggleLike({
    required String username,
    required String imageName,
  }) async {
    return await sendRequest({
      'action': 'likeImage',
      'username': username,
      'name': imageName,
      'imageName': imageName,
    });
  }

  Future<Map<String, dynamic>> addComment({
    required String username,
    required String imageName,
    required String comment,
  }) async {
    return await sendRequest({
      'action': 'addComment',
      'username': username,
      'name': imageName,
      'imageName': imageName,
      'comment': comment,
      'text': comment,
    });
  }

  Future<Map<String, dynamic>> addTag({
    required String username,
    required String imageName,
    required String tag,
  }) async {
    return await sendRequest({
      'action': 'addTag',
      'username': username,
      'name': imageName,
      'imageName': imageName,
      'tag': tag,
    });
  }

  Future<Map<String, dynamic>> moveImage({
    required String username,
    required String sourceAlbum,
    required String targetAlbum,
    required String imageName,
  }) async {
    return await sendRequest({
      'action': 'moveImage',
      'username': username,
      'sourceAlbum': sourceAlbum,
      'targetAlbum': targetAlbum,
      'imageName': imageName,
      'name': imageName,
    });
  }

  void _closeSocket() {
    _subscription?.cancel();
    _socket?.destroy();
    _subscription = null;
    _socket = null;
  }
}