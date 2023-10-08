import 'dart:html';

class Client {
  final _socket = WebSocket('ws://localhost:8080');

  Stream<MessageEvent> get onMessage =>
      _socket.onMessage.map((event) => event.data);
  Stream<Event> get onOpen => _socket.onOpen;

  Client() {
    _socket.onOpen.listen(
      (event) {
        // ignore: avoid_print
        print('Connected to WebSocket server.');
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
    });
  }

  void send(String message) {
    _socket.send(message);
  }
}