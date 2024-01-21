import 'dart:async';
import 'dart:convert';

import 'package:banuba_arcloud/src/effect.dart';
import 'package:banuba_arcloud/src/exceptions.dart';
import 'package:banuba_arcloud/src/network_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

part 'arcloud_plugin_mapper.dart';

class BanubaARCloudPlugin {
  static const _tag = 'ARCloudPlugin';
  static const _channelName = 'com.banuba.sdk.flutter.arcloud';

  static const _methodGetEffects = 'get_effects';
  static const _methodDownloadEffect = 'download_effect';
  static const _methodEffectsLoaded = 'effects_loaded';
  static const _methodSetArCloudUrl = 'ar_cloud_url';

  static const _paramEffectName = 'effect_name';
  static const _paramArCloudUrlName = 'arCloudUrl';

  static const _errorCodeGetEffects = 'error_get_effects';

  static final BanubaARCloudPlugin _plugin = BanubaARCloudPlugin._internal();

  final _channel = const MethodChannel(_channelName);
  final _effectsStreamController = StreamController<List<Effect>>();

  factory BanubaARCloudPlugin() => _plugin;

  BanubaARCloudPlugin._internal();

  Future<void> init({required String arCloudUrl}) async {
    debugPrint('$_tag: init = $arCloudUrl');
    _channel.setMethodCallHandler(_handlePlatformMethodCall);

    final params = {_paramArCloudUrlName: arCloudUrl};
    await _channel.invokeMethod(_methodSetArCloudUrl, params);
  }

  Future<void> dispose() async {
    _effectsStreamController.close();
  }

  Stream<List<Effect>> getEffectsStream() => _effectsStreamController.stream;

  Future<void> loadEffects() async {
    try {
      debugPrint('$_tag: load effects');
      final effectsJson = await _channel.invokeMethod(_methodGetEffects);
      debugPrint('$_tag: effects loaded = $effectsJson');
      _mapEffectsJson(effectsJson as String);
      return Future(() => null);
    } on PlatformException catch (e) {
      debugPrint('$_tag: failed to load effects = $e');
      if (e.code == _errorCodeGetEffects) {
        _effectsStreamController.addError(ARCloudLoadEffectsException('${e.message}'));
      } else {
        _effectsStreamController.addError(ARCloudUnknownException('${e.code}: ${e.message}'));
      }
    }
  }

  Future<Effect> downloadEffect(String effectName) async {
    try {
      debugPrint('$_tag: download effect = $effectName');
      final params = {
        _paramEffectName: effectName,
      };
      final effectJson = await _channel.invokeMethod(_methodDownloadEffect, params);
      return _mapEffectJson(effectJson as String);
    } on PlatformException catch (e) {
      debugPrint('$_tag: failed to download effect = $effectName, error = $e');
      if (e.code == _errorCodeDownloadEffect) {
        throw ARCloudDownloadEffectException('Effect: $effectName. ${e.message}');
      } else {
        throw ARCloudUnknownException('${e.code}: ${e.message}');
      }
    } on FormatException catch (e) {
      throw ARCloudDownloadEffectException('Parsing error. Effect: $effectName. $e');
    }
  }

  Future<dynamic> _handlePlatformMethodCall(MethodCall call) async {
    switch (call.method) {
      case _methodEffectsLoaded:
        _handleLoadedEffects(call);
        break;
      default:
        throw MissingPluginException();
    }
  }

  void _handleLoadedEffects(MethodCall call) {
    try {
      final data = call.arguments as String;
      debugPrint('$_tag: handle loaded effects = $data');
      final effects = _mapEffectsWrapperJson(data);
      _effectsStreamController.add(effects);
    } on Exception catch (e) {
      _effectsStreamController.addError(e);
    }
  }
}
