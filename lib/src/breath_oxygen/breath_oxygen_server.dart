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
    components[entityId] = component;

    final bytes = messager.addComponentToBytes(entityId, component);

    server.send(bytes);
  }

  void createEntity(Entity entity) {
    entities[entity.id!] = entity;

    final bytes = messager.createEntityToBytes(entity.id!);

    server.send(bytes);
  }

  void updateComponent(Entity entity, SerializableComponent component) {
    final bytes = messager.updateComponentToBytes(entity.id!, component);

    server.send(bytes);
  }

  void sendWorldTo(WebSocketChannel channel) {
    for (final entry in entities.entries) {
      server.sendTo(
        channel,
        messager.createEntityToBytes(entry.key),
      );
    }

    for (final entry in components.entries) {
      server.sendTo(
        channel,
        messager.addComponentToBytes(entry.key, entry.value),
      );
    }
  }
}

extension NetworkEntity on Entity {
  netAdd<T extends SerializableComponent<V>, V>([V? data]) {
    add<T, V>(data);
    final component = get<T>()!;
    BreathOxygenServer.instance.addComponent(id!, component);
  }
}

extension NetworkWorld on World {
  Entity createNetworkEntity() {
    final entity = createEntity();
    BreathOxygenServer.instance.createEntity(entity);

    return entity;
  }

  Entity createNetworkPremadeEntity(PremadeEntity premadeEntity) {
    final entity = createNetworkEntity();
    premadeEntity.make(entity);

    return entity;
  }
}

extension NetworkComponent on SerializableComponent {
  /// Server-only: will mark & send a component update.
  void markNetUpdate(Entity entity) {
    print('marknetupdate');
    BreathOxygenServer.instance.updateComponent(entity, this);
  }
}
