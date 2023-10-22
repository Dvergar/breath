import 'package:breath/breath.dart';
import 'package:breath/breath_server.dart';
import 'package:oxygen/oxygen.dart';

extension NetworkWorld on World {
  Entity createNetworkEntity() {
    final entity = createEntity();
    BreathOxygenServer.instance.createEntity(entity);

    return entity;
  }

  Entity createNetworkPremadeEntity(PremadeEntity premadeEntity) {
    final entity = createNetworkEntity();
    premadeEntity.make(entity);

    return entity;
  }
}
