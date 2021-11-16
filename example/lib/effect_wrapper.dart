import 'package:banuba_arcloud/banuba_arcloud.dart';

class EffectWrapper {
  EffectWrapper(
    this.effect,
    this.status,
  );

  ArEffect effect;
  ArEffectStatus status;
}

enum ArEffectStatus {
  downloaded,
  notDownloaded,
  downloading,
}
