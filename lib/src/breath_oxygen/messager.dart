import 'dart:typed_data';

import 'package:oxygen/oxygen.dart';

enum MessageType {
  createEntity,
  addComponent,
  updateComponent,
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
    writer.writeInt32(component.typeId);
    component.toBytes(writer);

    return byteBuffer.buffer;
  }

  ByteBuffer updateComponentToBytes(
      int entityId, SerializableComponent component) {
    clear();

    final writer = ByteBufferWriter(byteBuffer);

    writer.writeInt8(MessageType.updateComponent.index);
    writer.writeInt32(entityId);
    writer.writeInt32(component.typeId);
    component.toBytes(writer);

    return byteBuffer.buffer;
  }

  void fromBytes({
    required ByteBuffer buffer,
    required Function onCreateEntity,
    required OnAddComponentCallback onAddComponent,
    required OnUpdateComponentCallback onUpdateComponent,
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

      if (messageType == MessageType.updateComponent.index) {
        final entityId = reader.readInt32();
        final componentTypeId = reader.readInt32();
        onUpdateComponent(entityId, componentTypeId, reader);
      }
    }
  }
}

typedef OnAddComponentCallback = Function(
  int entityId,
  int componentTypeId,
  ByteBufferReader buffer,
);

typedef OnUpdateComponentCallback = Function(
  int entityId,
  int componentTypeId,
  ByteBufferReader buffer,
);

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

  void writeBooleans(
    bool bool1, [
    bool bool2 = false,
    bool bool3 = false,
    bool bool4 = false,
    bool bool5 = false,
    bool bool6 = false,
    bool bool7 = false,
    bool bool8 = false,
  ]) {
    final packedValue = (bool1 ? 1 : 0) << 7 |
        (bool2 ? 1 : 0) << 6 |
        (bool3 ? 1 : 0) << 5 |
        (bool4 ? 1 : 0) << 4 |
        (bool5 ? 1 : 0) << 3 |
        (bool6 ? 1 : 0) << 2 |
        (bool7 ? 1 : 0) << 1 |
        (bool8 ? 1 : 0);

    writeInt8(packedValue);
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

  (bool, bool, bool, bool, bool, bool, bool, bool) getBooleans() {
    final packedValue = readInt8();
    return (
      (packedValue & (1 << 7)) != 0,
      (packedValue & (1 << 6)) != 0,
      (packedValue & (1 << 5)) != 0,
      (packedValue & (1 << 4)) != 0,
      (packedValue & (1 << 3)) != 0,
      (packedValue & (1 << 2)) != 0,
      (packedValue & (1 << 1)) != 0,
      (packedValue & (1 << 0)) != 0,
    );
  }

  bool get hasBytesToRead => _elementOffset < _byteData.elementSizeInBytes;
}

abstract class SerializableComponent<T> extends Component<T> {
  /// Component type id which should match [NetBuilder.typeId].
  late final int typeId;
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

extension IdWorld on World {
  // Todo: find a way to handle ids easily (without using codegen)
  void netRegisterComponent<T extends Component<V>, V>(
    ComponentBuilder<T> builder,
    NetBuilder netBuilder,
  ) {
    registerComponent(builder);

    mappings.add(netBuilder.typeId, netBuilder);
  }
}

// final mappings = TwoWayMap<int, NetBuilder Function(Entity)>();
final mappings = TwoWayMap<int, NetBuilder>();

class NetBuilder<T> {
  /// Component type id which should match [SerializableComponent.typeId].
  final int typeId;
  final void Function(Entity) add;
  final T Function(Entity) get;

  const NetBuilder({
    required this.typeId,
    required this.add,
    required this.get,
  });
}
