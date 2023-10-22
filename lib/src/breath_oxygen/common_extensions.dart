import 'package:breath/breath.dart';
import 'package:breath/breath_server.dart';
import 'package:oxygen/oxygen.dart';

extension NetworkComponent on SerializableComponent {
  /// Server-only: will mark & send a component update.
  void markNetUpdate(Entity entity) {
    if (isServer) {
      BreathOxygenServer.instance.updateComponent(entity, this);
    }
  }
}
