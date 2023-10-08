import 'dart:html';
import 'dart:typed_data';

import 'package:breath/src/websocket/i_websocket.dart';
import 'package:web_socket_channel/html.dart';

class Client implements IWebSocket {
  final _socket = WebSocket('ws://localhost:8080')
    ..binaryType = BinaryType.list.value;

  @override
  Stream get onMessage => _socket.onMessage.map((event) => event.data);
  @override
  Stream<Event> get onOpen => _socket.onOpen;

  @override
  void init() async {
    _socket.onOpen.listen(
      (event) {
        // ignore: avoid_print
        print('Connected to WebSocket server.');
      },
    );

    // Listen for messages from the server.
    _socket.onMessage.listen((message) {
      // ignore: avoid_print
      print('Debug: Received from server: $message');
    });

    // Close the WebSocket connection when done.
    _socket.onClose.listen((_) {
      // ignore: avoid_print
      print('WebSocket connection closed.');
    });
  }

  @override
  void send(ByteBuffer buffer) {
    _socket.send(buffer);
  }
}
