import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class Server {
  final handler = webSocketHandler((WebSocketChannel webSocket) {
    webSocket.stream.listen((event) {
      print(event);
    });
  });

  init() async {
    // Create a shelf pipeline.
    final pipeline =
        const Pipeline().addMiddleware(logRequests()).addHandler(handler);

    // Create an HTTP server.
    final server = await io.serve(pipeline, 'localhost', 8080);

    print(
        'WebSocket server is listening on ${server.address.host}:${server.port}');
  }
}
