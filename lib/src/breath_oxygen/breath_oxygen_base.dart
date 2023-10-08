import 'package:breath/breath.dart';
import 'package:oxygen/oxygen.dart';

abstract class BreathOxygenBase {
  final world = World();
  final messager = Messager();

  Future<void> start();
}
