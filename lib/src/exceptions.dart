abstract class BaseArcloudException implements Exception {
  const BaseArcloudException([this._message]);

  final String? _message;

  @override
  String toString() {
    return runtimeType.toString() + (_message == null ? '' : ': $_message');
  }
}

class ArcloudEffectsLoadingException extends BaseArcloudException {
  const ArcloudEffectsLoadingException([String? message]) : super(message);
}

class ArcloudEffectDownloadingException extends BaseArcloudException {
  const ArcloudEffectDownloadingException([String? message]) : super(message);
}

class ArcloudUnknownException extends BaseArcloudException {
  const ArcloudUnknownException([String? message]) : super(message);
}
