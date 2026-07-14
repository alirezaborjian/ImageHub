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

  Future<bool> connectToServer({String host = '127.0.0.1', int port = 8080}) async {
    try {
      String targetHost = (host == '127.0.0.1' && Platform.isAndroid) ? '10.0.2.2' : '127.0.0.1';
      _socket = await Socket.connect(targetHost, port, timeout: const Duration(seconds: 5));
      _isConnected = true;
      return true;
    } catch (e) {
      _isConnected = false;
      return false;
    }
  }

  Future<Map<String, dynamic>> sendRequest(Map<String, dynamic> requestData) async {
    if (!_isConnected || _socket == null) {
      return {'status': 'error', 'message': 'Not connected to server.'};
    }

    try {
      String jsonStr = jsonEncode(requestData) + '\n';
      _socket!.write(jsonStr);
      await _socket!.flush();

      Completer<Map<String, dynamic>> completer = Completer();
      List<int> buffer = [];

      var subscription = _socket!.listen((data) {
        buffer.addAll(data);
        if (buffer.contains(10)) {
          String responseStr = utf8.decode(buffer).trim();
          completer.complete(jsonDecode(responseStr));
        }
      }, onError: (error) {
        if (!completer.isCompleted) completer.complete({'status': 'error', 'message': error.toString()});
      });

      final result = await completer.future.timeout(const Duration(seconds: 10));
      await subscription.cancel();
      return result;
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }
}