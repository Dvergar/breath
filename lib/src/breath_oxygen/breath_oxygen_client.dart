import 'package:breath/breath.dart';
import 'package:breath/breath_client.dart';
import 'package:breath/src/breath_oxygen/breath_oxygen_base.dart';

class BreathOxygenClient extends BreathOxygenBase {
  final _client = Client();

  Future<void> connect() async {
    final messager = Messager();

    _client.onOpen.listen((event) {
      logger.i('[Breath] Connected');
    });

    _client.onMessage.listen((message) {
      messager.fromBytes(
        buffer: message,
        onCreateEntity: () {
          final entity = world.createEntity();
          entities[entity.id!] = entity;

          logger.i('[Breath] Create entity: ${entity.id}');
        },
        onAddComponent: (
          int entityId,
          int componentTypeId,
          ByteBufferReader buffer,
        ) {
          final entity = entities[entityId]!;
          final builder = mappings[componentTypeId]!;
          builder.add(entity);
          final component = builder.get(entity);

          component.readBytes(buffer);

          logger.i('[Breath] Add component: ${component.runtimeType}');
        },
        onUpdateComponent: (
          int entityId,
          int componentTypeId,
          ByteBufferReader buffer,
        ) {
          final entity = entities[entityId]!;
          final builder = mappings[componentTypeId]!;
          final component = builder.get(entity);

          component.readBytes(buffer);

          logger.d('[Breath] Update component: ${component.runtimeType}');
        },
      );
    });

    logger.i('[Breath] Client engine started');

    _client.connect();
  }

  void send(ByteData buffer) {
    _client.send(buffer.buffer);
  }
}
