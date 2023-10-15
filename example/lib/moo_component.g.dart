part of 'moo_component.dart';

extension MooComponentExtension on MooComponent {
  void writeBytes(ByteBufferWriter buffer) {
    buffer.writeInt16(x);
    buffer.writeInt16(y);
    buffer.writeBooleans(pressed);
    buffer.writeInt8(typeId);
  }

  void readBytes(ByteBufferReader buffer) {
    x = buffer.readInt16();
    y = buffer.readInt16();
    pressed = buffer.readBooleans().$1;
    typeId = buffer.readInt8();
  }
}
