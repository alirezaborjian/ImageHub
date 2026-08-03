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

    try {
      String jsonStr = '${jsonEncode(requestData)}\n';
      _socket!.write(jsonStr);
      await _socket!.flush();

      Completer<Map<String, dynamic>> completer = Completer();
      List<int> buffer = [];

      var subscription = _socket!.listen(
        (data) {
          buffer.addAll(data);
          if (buffer.contains(10)) {
            String responseStr = utf8.decode(buffer).trim();
            if (!completer.isCompleted) {
              completer.complete(jsonDecode(responseStr));
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
      );

      final result = await completer.future.timeout(
        const Duration(seconds: 10),
      );
      await subscription.cancel();
      _isConnected = false;
      return result;
    } catch (e) {
      _isConnected = false;
      return {'statusCode': 500, 'message': e.toString()};
    }
  }
}
