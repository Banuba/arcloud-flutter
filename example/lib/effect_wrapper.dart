import 'package:banuba_arcloud/banuba_arcloud.dart';

class EffectWrapper {
  EffectWrapper(
    this.effect,
    this.status,
  );

  Effect effect;
  ArEffectStatus status;

  @override
  String toString() {
    return 'Effect(status: $status, value: $effect)';
  }
}

enum ArEffectStatus {
  downloaded,
  notDownloaded,
  downloading,
}
