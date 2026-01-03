import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SocketService {

  static String get _baseUrl => dotenv.env['SERVER_IP'] ?? 'http://localhost:3000';

  late IO.Socket _socket;
  final _statusController = StreamController<bool>.broadcast();

  SocketService() {
    _init();
  }

  void _init() {
    _socket = IO.io(_baseUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
      'reconnection': true,
    });

    _socket.onConnect((_) {
      debugPrint('[SOCKET] Connected. ID: ${_socket.id}');
      _statusController.add(true);
    });

    _socket.onDisconnect((_) {
      debugPrint('[SOCKET] Disconnected');
      _statusController.add(false);
    });
  }

  Stream<bool> get connectionStatusStream async* {
    yield _socket.connected;
    yield* _statusController.stream;
  }

  IO.Socket get socket => _socket;

  String? get socketId => _socket.connected ? _socket.id : null;

  bool get isConnected => _socket.connected;

  void dispose() {
    _socket.dispose();
    _statusController.close();
  }
}