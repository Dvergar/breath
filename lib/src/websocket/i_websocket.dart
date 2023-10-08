import 'dart:async';

abstract class IWebSocket {
  FutureOr<void> init();
  void send(String message);

  Stream<dynamic> get onOpen;
  Stream<dynamic> get onMessage;
}
