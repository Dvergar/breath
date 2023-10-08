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

    server.onOpen.listen((channel) {
      print('Breath: player connected');
      for (final entry in _entities.entries) {
        server.send(messager.createEntityToBytes(entry.key));
      }
    });
  }

  void addComponent(int entityId, Component component) {
    _components[entityId] = component;
  }

  void createEntity(Entity entity) {
    _entities[entity.id!] = entity;

    final bytes = messager.createEntityToBytes(entity.id!);

    server.send(bytes);
  }

  void sendWorldTo(WebSocketChannel channel) {
    // TODO
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
