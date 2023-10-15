part of 'moo_component.dart';

extension MooComponentExtension on MooComponent {
  void writeBytes(ByteBufferWriter buffer) {
    buffer.writeInt16(x.toInt());
    buffer.writeInt16(y.toInt());
    buffer.writeInt8(rotation.toInt());
    buffer.writeBooleans(pressed);
    buffer.writeInt8(typeId);
  }

  void readBytes(ByteBufferReader buffer) {
    x = buffer.readInt16().toDouble();
    y = buffer.readInt16().toDouble();
    rotation = buffer.readInt8().toDouble();
    pressed = buffer.readBooleans().$1;
    typeId = buffer.readInt8();
  }
}
