import 'package:breath/breath.dart';
import 'package:oxygen/oxygen.dart';

abstract class SerializableComponent<T> extends Component<T> {
  late final int typeId;
  void writeBytes(ByteBufferWriter writer) {}
  void readBytes(ByteBufferReader reader) {}
}
