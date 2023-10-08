import 'package:oxygen/oxygen.dart';

abstract class PremadeEntity {
  late final String name;

  PremadeEntity make(Entity entity);
}
