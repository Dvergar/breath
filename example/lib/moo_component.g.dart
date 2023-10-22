part of 'moo_component.dart';

class MooComponent extends _MooComponent {
  static NetBuilder<MooComponent> builder = NetBuilder<MooComponent>(
    typeId: -1,
    add: (entity) => entity.add<MooComponent, int>(),
    get: (entity) => entity.get<MooComponent>()!,
  );

  @override
  int get typeId => -1;

  @override
  void writeBytes(ByteBufferWriter writer) {
    writer.writeInt16(x.toInt());
    writer.writeInt16(y.toInt());
    writer.writeInt8(rotation.toInt());
    writer.writeBooleans(pressed);
    writer.writeInt8(typeId);
  }

  @override
  void readBytes(ByteBufferReader reader) {
    x = reader.readInt16().toDouble();
    y = reader.readInt16().toDouble();
    rotation = reader.readInt8().toDouble();
    pressed = reader.readBooleans().$1;
    typeId = reader.readInt8();
  }
}
