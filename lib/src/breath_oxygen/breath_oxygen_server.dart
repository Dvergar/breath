import 'package:breath/breath.dart';
import 'package:breath/src/breath_oxygen/breath_oxygen_base.dart';
import 'package:breath/src/websocket/server.dart';
import 'package:oxygen/oxygen.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

// Todo: add pump
/// Adds network functionality to oxygen.
class BreathOxygenServer extends BreathOxygenBase {
  final Map<int, Component> _components = {};
  final Map<int, Entity> _entities = {};
  final server = Server();
  static late final BreathOxygenServer instance;

  @override
  Future<void> start() async {
    instance = this;
    await server.init();

    // On new connection, sends the world to client
    server.onOpen.listen((channel) {
      print('Breath: player connected');
      sendWorldTo(channel);
    });
  }

  void addComponent(int entityId, Component component) {
    _components[entityId] = component;

    final bytes = messager.addComponentToBytes(entityId);

    server.send(bytes);
  }

  void createEntity(Entity entity) {
    _entities[entity.id!] = entity;

    final bytes = messager.createEntityToBytes(entity.id!);

    server.send(bytes);
  }

  void sendWorldTo(WebSocketChannel channel) {
    for (final entry in _entities.entries) {
      server.sendTo(channel, (messager.createEntityToBytes(entry.key)));
    }

    for (final entry in _components.entries) {
      server.sendTo(channel, (messager.addComponentToBytes(entry.key)));
    }
  }
}

extension NetworkEntity on Entity {
  netAdd<T extends Component<V>, V>([V? data]) {
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
