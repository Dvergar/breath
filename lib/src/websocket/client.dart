import 'dart:async';
import 'dart:html';
import 'dart:typed_data';

import 'package:breath/src/websocket/i_websocket.dart';
import 'package:web_socket_channel/html.dart';

class Client implements IWebSocket {
  late WebSocket _socket;

  final _onMessageController = StreamController<dynamic>.broadcast();
  final _onOpenController = StreamController<Event>.broadcast();

  @override
  Stream get onMessage => _onMessageController.stream;
  @override
  Stream<Event> get onOpen => _onOpenController.stream;

  void connect() {
    _socket = WebSocket('ws://localhost:8080')
      ..binaryType = BinaryType.list.value;

    _socket.onOpen.listen(
      (event) {
        print('Client: Connected');
        _onOpenController.add(event);
      },
    );

    // Listen for messages from the server.
    _socket.onMessage.listen((MessageEvent message) {
      // TODO: Put behind a debug flag
      // print('Client: Received from server: $message');
      _onMessageController.add(message.data);
    });

    // Close the WebSocket connection when done.
    _socket.onClose.listen((_) {
      print('Client: WebSocket connection closed');
    });

    _socket.onError.listen(
      (_) {
        print('Client: Error');
      },
    );
  }

  // TODO sendTypedData
  @override
  void send(ByteBuffer buffer) {
    _socket.send(buffer);
  }
}
