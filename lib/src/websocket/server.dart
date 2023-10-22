import 'dart:async';

import 'package:breath/breath.dart';
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
      logger.i('[Server] New connection > ${webSocket.hashCode}');

      _onOpenController.add(webSocket);

      _channels.add(webSocket);

      webSocket.stream.listen(
        (message) {
          logger.d('[Server] Received from client: $message');

          _onMessageController.add((webSocket, message));
        },
        onDone: () {
          logger.i('[Server] Disconnection > ${webSocket.hashCode}');

          _channels.remove(webSocket);
        },
      );
    });

    // Create a shelf pipeline.
    final pipeline =
        const Pipeline().addMiddleware(logRequests()).addHandler(handler);

    // Create an HTTP server.
    final server = await io.serve(pipeline, 'localhost', 8080);

    logger.i('[Server] Listening on ${server.address.host}:${server.port}');
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
