import 'dart:async';
import 'dart:typed_data';

import 'package:breath/src/websocket/i_websocket.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class Server implements IWebSocket {
  final _onOpenController = StreamController<WebSocketChannel>.broadcast();
  final _onMessageController =
      StreamController<(WebSocketChannel, dynamic)>.broadcast();

  @override
  Stream<WebSocketChannel> get onOpen => _onOpenController.stream;

  @override
  Stream<(WebSocketChannel, dynamic)> get onMessage =>
      _onMessageController.stream;

  final _channels = <WebSocketChannel>[];

  Future<void> serve() async {
    final handler = webSocketHandler((WebSocketChannel webSocket) {
      print('New connection');
      _onOpenController.add(webSocket);

      _channels.add(webSocket);

      webSocket.stream.listen(
        (message) => _onMessageController.add((webSocket, message)),
        onDone: () {
          print('Disconnection');

          _channels.remove(webSocket);
        },
      );
    });

    // Create a shelf pipeline.
    final pipeline =
        const Pipeline().addMiddleware(logRequests()).addHandler(handler);

    // Create an HTTP server.
    final server = await io.serve(pipeline, 'localhost', 8080);

    print(
        'WebSocket server is listening on ${server.address.host}:${server.port}');
  }

  @override
  void send(ByteBuffer buffer) {
    for (var channel in _channels) {
      channel.sink.add(buffer.asInt8List());
    }
  }

  void sendTo(WebSocketChannel channel, ByteBuffer buffer) => channel.sink.add(
        buffer.asInt8List(),
      );
}
