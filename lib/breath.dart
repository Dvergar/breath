library;

import 'package:logger/logger.dart';

export 'src/breath_oxygen/premade_entity.dart';
export 'src/breath_oxygen/messager.dart';
export 'src/breath_oxygen/serializable_component.dart';
export 'src/breath_oxygen/serializable_annotation.dart';
export 'src/breath_oxygen/data_protocol.dart';
export 'src/breath_oxygen/common_extensions.dart';
export 'dart:typed_data';

var isServer = false;
var logger = Logger(
  filter: ProductionFilter(),
  printer: PrettyPrinter(
    methodCount: 0,
    noBoxingByDefault: true,
  ),
  level: Level.info,
);
