import 'dart:async';
import 'dart:convert';

import 'package:banuba_arcloud/src/ar_effect.dart';
import 'package:banuba_arcloud/src/exceptions.dart';
import 'package:banuba_arcloud/src/network_utils.dart';
import 'package:flutter/services.dart';

part 'arcloud_plugin_mapper.dart';

class BanubaArcloudPlugin {
  static const _channelName = 'com.banuba.sdk.flutter.arcloud';

  static const _methodGetEffects = 'get_effects';
  static const _methodDownloadEffect = 'download_effect';
  static const _methodEffectsLoaded = 'effects_loaded';

  static const _paramEffectName = 'effect_name';

  static const _errorCodeGetEffects = 'error_get_effects';

  static final BanubaArcloudPlugin _plugin = BanubaArcloudPlugin._internal();

  final _channel = const MethodChannel(_channelName);
  final _effectsStreamController = StreamController<List<ArEffect>>();

  factory BanubaArcloudPlugin() => _plugin;

  BanubaArcloudPlugin._internal();

  Future<void> init() async {
    _channel.setMethodCallHandler(_handleMethod);
  }

  Future<void> dispose() async {
    _effectsStreamController.close();
  }

  Stream<List<ArEffect>> getEffectsStream() => _effectsStreamController.stream;

  Future<List<ArEffect>> getEffects() async {
    try {
      final effectsJson = await _channel.invokeMethod(_methodGetEffects);
      final effects = _mapArEffectsJson(effectsJson as String);
      return effects;
    } on PlatformException catch (e) {
      if (e.code == _errorCodeGetEffects) {
        throw ArcloudEffectsLoadingException('${e.message}');
      } else {
        throw ArcloudUnknownException('${e.code}: ${e.message}');
      }
    }
  }

  Future<ArEffect> downloadEffect(String effectName) async {
    try {
      final params = {
        _paramEffectName: effectName,
      };
      final effectJson = await _channel.invokeMethod(_methodDownloadEffect, params);
      final effect = _mapArEffectJson(effectJson as String);
      return effect;
    } on PlatformException catch (e) {
      if (e.code == _errorCodeDownloadEffect) {
        throw ArcloudEffectDownloadingException('Effect: $effectName. ${e.message}');
      } else {
        throw ArcloudUnknownException('${e.code}: ${e.message}');
      }
    } on FormatException catch (e) {
      throw ArcloudEffectDownloadingException('Parsing error. Effect: $effectName. $e');
    }
  }

  Future<dynamic> _handleMethod(MethodCall call) async {
    switch (call.method) {
      case _methodEffectsLoaded:
        _handleEffectsLoadedMethod(call);
        break;
      default:
        throw MissingPluginException();
    }
  }

  void _handleEffectsLoadedMethod(MethodCall call) {
    try {
      final effects = _mapArEffectsWrapperJson(call.arguments as String);
      _effectsStreamController.add(effects);
    } on Exception catch (e) {
      _effectsStreamController.addError(e);
    }
  }
}
