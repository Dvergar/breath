import 'dart:async';
import 'dart:typed_data';

abstract class IWebSocket {
  void send(ByteBuffer message);

  Stream<dynamic> get onOpen;
  Stream<dynamic> get onMessage;
}
