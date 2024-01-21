part of 'arcloud_plugin.dart';

const _errorCodeDownloadEffect = 'error_download_effect';

List<Effect> _mapEffectsWrapperJson(String jsonString) {
  final effectsJson = json.decode(jsonString) as Map<String, dynamic>;
  final errorCode = effectsJson["errorCode"] as String?;
  if (errorCode == null) {
    final effectsListJson = effectsJson["effects"] as List<dynamic>;
    return _mapEffectsList(effectsListJson);
  } else {
    switch (errorCode) {
      case _errorCodeDownloadEffect:
        throw const ARCloudLoadEffectsException();
      default:
        throw const ARCloudUnknownException('Failed to load effects');
    }
  }
}

List<Effect> _mapEffectsJson(String jsonString) {
  final effectsJson = json.decode(jsonString) as List<dynamic>;
  return _mapEffectsList(effectsJson);
}

Effect _mapEffectJson(String jsonString) {
  final effectJson = json.decode(jsonString) as Map<String, dynamic>;
  return _mapEffect(effectJson);
}

List<Effect> _mapEffectsList(List<dynamic> effectsJson) =>
    effectsJson.cast<Map<String, dynamic>>().map<Effect>(_mapEffect).toList();

Effect _mapEffect(Map<String, dynamic> map) => Effect(
      map['default'],
      map['eTag'],
      map['id'],
      map['name'],
      map['preview'],
      map['type'] ?? map['arType'],
      map['uri'],
      map['isDownloaded'] ?? !isNetworkUri(map['uri']),
    );
