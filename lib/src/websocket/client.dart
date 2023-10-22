import 'dart:async';
import 'dart:html';

import 'package:breath/breath.dart';
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
        logger.i('[Client] Connected');

        _onOpenController.add(event);
      },
    );

    // Listen for messages from the server.
    _socket.onMessage.listen((MessageEvent message) {
      logger.d('[Client] Received from server: $message');

      _onMessageController.add(message.data);
    });

    // Close the WebSocket connection when done.
    _socket.onClose.listen((_) {
      logger.i('[Client] Disconnected');
    });

    _socket.onError.listen(
      (_) {
        logger.e('[Client] Error');
      },
    );
  }

  // TODO sendTypedData
  @override
  void send(ByteBuffer buffer) {
    _socket.send(buffer);
  }
}
