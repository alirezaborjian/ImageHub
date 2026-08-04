import 'dart:convert';
import 'dart:io';
import 'dart:async';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  Socket? _socket;
  bool _isConnected = false;

  bool get isConnected => _isConnected;

  Future<bool> connectToServer({
    String host = '10.0.2.2',
    int port = 8085,
  }) async {
    try {
      String targetHost = (host == '127.0.0.1' && Platform.isAndroid)
          ? '10.0.2.2'
          : host;
      _socket = await Socket.connect(
        targetHost,
        port,
        timeout: const Duration(seconds: 5),
      );
      _isConnected = true;
      return true;
    } catch (e) {
      _isConnected = false;
      return false;
    }
  }

  Future<Map<String, dynamic>> sendRequest(
    Map<String, dynamic> requestData,
  ) async {
    if (!_isConnected || _socket == null) {
      bool reconnected = await connectToServer();
      if (!reconnected) {
        return {'statusCode': 500, 'message': 'Not connected to server.'};
      }
    }

    Completer<Map<String, dynamic>> completer = Completer();
    StreamSubscription? subscription;

    try {
      String jsonStr = '${jsonEncode(requestData)}\n';
      _socket!.write(jsonStr);
      await _socket!.flush();

      subscription = _socket!
          .cast<List<int>>()
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen(
        (line) {
          if (!completer.isCompleted && line.trim().isNotEmpty) {
            try {
              completer.complete(jsonDecode(line) as Map<String, dynamic>);
            } catch (e) {
              completer.complete({
                'statusCode': 500,
                'message': 'Invalid JSON response from server',
              });
            }
          }
        },
        onError: (error) {
          if (!completer.isCompleted) {
            completer.complete({
              'statusCode': 500,
              'message': error.toString(),
            });
          }
        },
        onDone: () {
          _isConnected = false;
          if (!completer.isCompleted) {
            completer.complete({
              'statusCode': 500,
              'message': 'Connection closed by server.',
            });
          }
        },
      );

      final result = await completer.future.timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          return {'statusCode': 408, 'message': 'Request timed out'};
        },
      );

      await subscription.cancel();
      return result;
    } catch (e) {
      await subscription?.cancel();
      _isConnected = false;
      return {'statusCode': 500, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> moveImage({
    required String username,
    required String sourceAlbum,
    required String targetAlbum,
    required String imageName,
  }) async {
    final request = {
      'action': 'moveImage',
      'username': username,
      'sourceAlbum': sourceAlbum,
      'targetAlbum': targetAlbum,
      'imageName': imageName,
    };

    return await sendRequest(request);
  }

  void disconnect() {
    _socket?.destroy();
    _socket = null;
    _isConnected = false;
  }
}