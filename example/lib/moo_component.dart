@CodeGen(runAfter: [CodeGen.addPartOfDirective])

import 'package:super_annotations/super_annotations.dart';
import 'package:breath/breath.dart';

part 'moo_component.g.dart';

@SerializableAnnotation()
class _MooComponent<String> extends SerializableComponent<int> {
  @DataProtocol(DataType.int16)
  double x = 0.0;
  @DataProtocol(DataType.int16)
  double y = 0.0;
  @DataProtocol(DataType.int8)
  double rotation = 0.5;
  @DataProtocol(DataType.bool)
  bool pressed = false;
  @DataProtocol(DataType.int8)
  int typeId = 0;

  @override
  void init([int? data]) {}

  @override
  void reset() {}
}
