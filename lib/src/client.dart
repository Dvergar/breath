// ignore: avoid_web_libraries_in_flutter
import 'dart:html';

// TODO CREATE nettwork ecs
class Client {
  final _socket = WebSocket('ws://localhost:8080');
  var connected = false;

  Stream<Object> get onMessage => _socket.onMessage.map((event) => event.data);

  Client() {
    print('hello');
    _socket.onOpen.listen(
      (event) {
        // ignore: avoid_print
        print('Connected to WebSocket server.');
        connected = true;
      },
    );

    // Listen for messages from the server.
    _socket.onMessage.listen((message) {
      // ignore: avoid_print
      print('Received from server: $message');
    });

    // Close the WebSocket connection when done.
    _socket.onClose.listen((_) {
      // ignore: avoid_print
      print('WebSocket connection closed.');
      connected = false;
    });
  }

  void send(String message) {
    if (!connected) {
      throw 'Socket is not ready';
    }
  }
}
