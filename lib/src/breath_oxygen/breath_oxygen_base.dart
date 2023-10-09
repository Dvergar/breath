import 'package:breath/breath.dart';
import 'package:oxygen/oxygen.dart';

abstract class BreathOxygenBase {
  final world = World();
  final messager = Messager();
  final Map<int, SerializableComponent> components = {};
  final Map<int, Entity> entities = {};

  Future<void> start();
}
