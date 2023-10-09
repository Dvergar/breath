import 'dart:typed_data';

import 'package:oxygen/oxygen.dart';

enum MessageType {
  createEntity,
  addComponent,
}

class Messager {
  var byteBuffer = ByteData(1024);

  void clear() {
    byteBuffer = ByteData(1024);
  }

  ByteBuffer createEntityToBytes(int id) {
    clear();

    final writer = ByteBufferWriter(byteBuffer);

    writer.writeInt8(MessageType.createEntity.index);
    writer.writeInt32(id);

    return byteBuffer.buffer;
  }

  ByteBuffer addComponentToBytes(
    int entityId,
    SerializableComponent component,
  ) {
    clear();

    final writer = ByteBufferWriter(byteBuffer);

    writer.writeInt8(MessageType.addComponent.index);
    writer.writeInt32(entityId);
    writer.writeInt32(component.uid);
    component.toBytes(writer);

    return byteBuffer.buffer;
  }

  void fromBytes({
    required ByteBuffer buffer,
    required Function onCreateEntity,
    required Function(
      int entityId,
      int componentTypeId,
      ByteBufferReader buffer,
    ) onAddComponent,
  }) {
    final reader = ByteBufferReader(buffer.asByteData());

    while (reader.hasBytesToRead) {
      final messageType = reader.readInt8();

      if (messageType == MessageType.createEntity.index) {
        onCreateEntity();
      }

      if (messageType == MessageType.addComponent.index) {
        final entityId = reader.readInt32();
        final componentTypeId = reader.readInt32();
        onAddComponent(entityId, componentTypeId, reader);
      }
    }
  }
}

class ByteBufferWriter {
  final ByteData _byteData;
  int _offset = 0;

  ByteBufferWriter(ByteData byteData) : _byteData = byteData;

  void writeInt8(int value) {
    _byteData.setInt8(_offset, value);
    _offset += 1;
  }

  void writeInt16(int value) {
    _byteData.setInt16(_offset, value);
    _offset += 2;
  }

  void writeInt32(int value) {
    _byteData.setInt32(_offset, value);
    _offset += 4;
  }
}

class ByteBufferReader {
  final ByteData _byteData;
  int _bytesOffset = 0;
  int _elementOffset = 0;

  ByteBufferReader(ByteData byteData) : _byteData = byteData;

  int readInt8() {
    final value = _byteData.getInt8(_bytesOffset);
    _bytesOffset += 1;
    _elementOffset += 1;
    return value;
  }

  int readInt16() {
    final value = _byteData.getInt16(_bytesOffset);
    _bytesOffset += 2;
    _elementOffset += 1;
    return value;
  }

  int readInt32() {
    final value = _byteData.getInt32(_bytesOffset);
    _bytesOffset += 4;
    _elementOffset += 1;
    return value;
  }

  bool get hasBytesToRead => _elementOffset < _byteData.elementSizeInBytes;
}

abstract class SerializableComponent<T> extends Component<T> {
  int get uid;

  void addBuilder(Entity entity);
  void fromBytes(ByteBufferReader buffer);
  void toBytes(ByteBufferWriter buffer);
}

class TwoWayMap<K, V> {
  final Map<K, V> keyToValue = {};
  final Map<V, K> valueToKey = {};

  void add(K key, V value) {
    keyToValue[key] = value;
    valueToKey[value] = key;
  }

  K getKey(V value) {
    return valueToKey[value]!;
  }

  V getValue(K key) {
    return keyToValue[key]!;
  }
}

typedef NetBuilder = SerializableComponent Function(Entity);

extension IdWorld on World {
  // Todo: find a way to handle ids easily (without using codegen)
  void netRegisterComponent<T extends Component<V>, V>(
    ComponentBuilder<T> builder,
    int id,
    NetBuilder Function(Entity) netBuilder,
  ) {
    registerComponent(builder);

    mappings.add(id, netBuilder);
  }
}

final mappings = TwoWayMap<int, NetBuilder Function(Entity)>();
