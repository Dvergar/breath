import 'package:breath/breath.dart';
import 'package:breath/breath_client.dart';
import 'package:breath/src/breath_oxygen/breath_oxygen_base.dart';

class BreathOxygenClient extends BreathOxygenBase {
  @override
  Future<void> start() async {
    final messager = Messager();

    final client = Client();
    client.init();
    client.onOpen.listen((event) {});

    client.onMessage.listen((message) {
      messager.fromBytes(
        buffer: message,
        onCreateEntity: () {
          print('Breath: create entity');
        },
      );
    });
  }
}
