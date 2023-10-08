import 'dart:async';
import 'dart:typed_data';

abstract class IWebSocket {
  FutureOr<void> init();
  void send(ByteBuffer message);

  Stream<dynamic> get onOpen;
  Stream<dynamic> get onMessage;
}
