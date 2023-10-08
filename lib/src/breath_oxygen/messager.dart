import 'dart:typed_data';

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

  ByteBuffer addComponentToBytes(int entityId) {
    clear();

    final writer = ByteBufferWriter(byteBuffer);

    writer.writeInt8(MessageType.addComponent.index);
    writer.writeInt32(entityId);

    return byteBuffer.buffer;
  }

  fromBytes({
    required ByteBuffer buffer,
    required Function onCreateEntity,
  }) {
    final reader = ByteBufferReader(buffer.asByteData());

    while (reader.hasBytesToRead) {
      final messageType = reader.readInt8();

      if (messageType == MessageType.createEntity.index) {
        onCreateEntity();
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
