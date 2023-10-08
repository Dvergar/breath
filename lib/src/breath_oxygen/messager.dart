import 'dart:typed_data';

enum MessageType {
  createEntity,
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

  fromBytes({
    required ByteBuffer buffer,
    required Function onCreateEntity,
  }) {
    final reader = ByteBufferReader(byteBuffer);
    final messageType = reader.readInt8();

    if (messageType == MessageType.createEntity.index) {
      onCreateEntity();
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

  int get position => _offset;
}

class ByteBufferReader {
  final ByteData _byteData;
  int _offset = 0;

  ByteBufferReader(ByteData byteData) : _byteData = byteData;

  int readInt8() {
    final value = _byteData.getInt8(_offset);
    _offset += 1;
    return value;
  }

  int readInt16() {
    final value = _byteData.getInt16(_offset);
    _offset += 2;
    return value;
  }

  int readInt32() {
    final value = _byteData.getInt32(_offset);
    _offset += 4;
    return value;
  }

  int get position => _offset;
}
