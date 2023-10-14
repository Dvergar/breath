import 'package:breath/breath.dart';
import 'package:oxygen/oxygen.dart';

abstract class SerializableComponent<T> extends Component<T> {
  /// Component type id which should match [NetBuilder.typeId].
  late final int typeId;
  void fromBytes(ByteBufferReader buffer);
  void toBytes(ByteBufferWriter buffer);
}
