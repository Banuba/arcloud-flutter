part of 'arcloud_plugin.dart';

const _errorCodeDownloadEffect = 'error_download_effect';

List<ArEffect> _mapArEffectsWrapperJson(String jsonString) {
  final effectsJson = json.decode(jsonString) as Map<String, dynamic>;
  final errorCode = effectsJson["errorCode"] as String?;
  if (errorCode == null) {
    final effectsListJson = effectsJson["effects"] as List<dynamic>;
    return _mapArEffectsList(effectsListJson);
  } else {
    switch (errorCode) {
      case _errorCodeDownloadEffect:
        throw const ArcloudEffectsLoadingException();
      default:
        throw const ArcloudUnknownException('Failed to load effects');
    }
  }
}

List<ArEffect> _mapArEffectsJson(String jsonString) {
  final effectsJson = json.decode(jsonString) as List<dynamic>;
  return _mapArEffectsList(effectsJson);
}

ArEffect _mapArEffectJson(String jsonString) {
  final effectJson = json.decode(jsonString) as Map<String, dynamic>;
  final effect = _mapArEffect(effectJson);
  return effect;
}

List<ArEffect> _mapArEffectsList(List<dynamic> effectsJson) {
  final effects = effectsJson.cast<Map<String, dynamic>>().map<ArEffect>(_mapArEffect).toList();
  return effects;
}

ArEffect _mapArEffect(Map<String, dynamic> map) {
  return ArEffect(
    map['default'],
    map['eTag'],
    map['id'],
    map['name'],
    map['preview'],
    map['typeId'],
    map['uri'],
    !isNetworkUri(map['uri']),
  );
}
