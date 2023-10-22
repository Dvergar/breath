import 'package:breath/breath.dart';
import 'package:breath/breath_client.dart';
import 'package:breath/src/breath_oxygen/breath_oxygen_base.dart';

class BreathOxygenClient extends BreathOxygenBase {
  final _client = Client();

  Future<void> connect() async {
    print('Breath: client engine started');
    final messager = Messager();

    _client.onOpen.listen((event) {
      print('Breath: connected');
    });

    _client.onMessage.listen((message) {
      messager.fromBytes(
        buffer: message,
        onCreateEntity: () {
          print('Breath: create entity');

          final entity = world.createEntity();
          entities[entity.id!] = entity;
        },
        onAddComponent: (
          int entityId,
          int componentTypeId,
          ByteBufferReader buffer,
        ) {
          print('Breath: add component $componentTypeId');

          final entity = entities[entityId]!;
          final builder = mappings[componentTypeId]!;
          builder.add(entity);
          final component = builder.get(entity);

          component.readBytes(buffer);
        },
        onUpdateComponent: (
          int entityId,
          int componentTypeId,
          ByteBufferReader buffer,
        ) {
          // TODO: Put behind a debug flag
          // print('Breath: update component');

          final entity = entities[entityId]!;
          final builder = mappings[componentTypeId]!;
          final component = builder.get(entity);

          component.readBytes(buffer);
        },
      );
    });

    _client.connect();
  }

  void send(ByteData buffer) {
    _client.send(buffer.buffer);
  }
}
