import 'package:breath/breath.dart';
import 'package:breath/src/breath_oxygen/breath_oxygen_base.dart';
import 'package:breath/src/websocket/server.dart';
import 'package:oxygen/oxygen.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

// Todo: add pump
/// Adds network functionality to oxygen.
class BreathOxygenServer extends BreathOxygenBase {
  final server = Server();
  static late final BreathOxygenServer instance;

  BreathOxygenServer() {
    isServer = true;
  }

  Future<void> serve() async {
    instance = this;
    await server.serve();

    // On new connection, sends the world to client
    server.onOpen.listen((channel) {
      print('Breath: player connected');
      sendWorldTo(channel);
    });
  }

  void addComponent(int entityId, SerializableComponent component) {
    components[entityId]!.add(component);

    final bytes = messager.addComponentToBytes(entityId, component);

    server.send(bytes);
  }

  void createEntity(Entity entity) {
    entities[entity.id!] = entity;
    components[entity.id!] = [];

    final bytes = messager.createEntityToBytes(entity.id!);

    server.send(bytes);
  }

  void updateComponent(Entity entity, SerializableComponent component) {
    final bytes = messager.updateComponentToBytes(entity.id!, component);

    server.send(bytes);
  }

  void sendWorldTo(WebSocketChannel channel) {
    // TODO reconsider data structures
    // for (final entry in entities.entries) {
    //   server.sendTo(
    //     channel,
    //     messager.createEntityToBytes(entry.key),
    //   );
    // }

    for (final entry in components.entries) {
      final entityId = entry.key;

      print('send world add entity');
      server.sendTo(
        channel,
        messager.createEntityToBytes(entityId),
      );

      final components = entry.value;

      for (final component in components) {
        print('send world add component ${component.typeId}');

        server.sendTo(
          channel,
          messager.addComponentToBytes(entityId, component),
        );
      }
    }
  }
}

extension NetworkEntity on Entity {
  void netAdd<T extends SerializableComponent<V>, V>([V? data]) {
    add<T, V>(data);
    final component = get<T>()!;
    print('netadd $T');
    BreathOxygenServer.instance.addComponent(id!, component);
  }
}
