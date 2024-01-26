abstract class BaseARCloudException implements Exception {
  const BaseARCloudException([this._message]);

  final String? _message;

  @override
  String toString() {
    return runtimeType.toString() + (_message == null ? '' : ': $_message');
  }
}

class ARCloudLoadEffectsException extends BaseARCloudException {
  const ARCloudLoadEffectsException([String? message]) : super(message);
}

class ARCloudDownloadEffectException extends BaseARCloudException {
  const ARCloudDownloadEffectException([String? message]) : super(message);
}

class ARCloudUnknownException extends BaseARCloudException {
  const ARCloudUnknownException([String? message]) : super(message);
}
