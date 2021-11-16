import 'dart:async';

import 'package:banuba_arcloud/banuba_arcloud.dart';
import 'package:banuba_arcloud_example/effect_tile.dart';
import 'package:banuba_arcloud_example/effect_wrapper.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _arcloudPlugin = BanubaArcloudPlugin();
  final _effects = <EffectWrapper>[];
  final _downloadingEffects = <String>[];
  late StreamSubscription<void> _effectsStreamSubscription;

  @override
  void initState() {
    _listenEffects();
    super.initState();
    _arcloudPlugin.init();
  }

  @override
  void dispose() {
    _effectsStreamSubscription.cancel();
    _arcloudPlugin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _effects.length,
              itemBuilder: (context, index) {
                final effectWrapper = _effects[index];
                return EffectTile(
                  key: ValueKey<String>(effectWrapper.effect.name),
                  effectWrapper: effectWrapper,
                  onEffectTap: _onEffectTap,
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: _loadEffects,
            child: const Text('Load effects'),
          ),
        ],
      ),
    );
  }

  void _listenEffects() {
    _effectsStreamSubscription = _arcloudPlugin.getEffectsStream().listen(
          _onEffectsLoaded,
          onError: (e) => _showMessage(e.toString()),
        );
  }

  Future<void> _loadEffects() async {
    try {
      final effects = await _arcloudPlugin.getEffects();
      _onEffectsLoaded(effects);
    } on ArcloudEffectsLoadingException catch (e) {
      _showMessage(e.toString());
    } on ArcloudUnknownException catch (e) {
      _showMessage(e.toString());
    }
  }

  void _onEffectsLoaded(List<ArEffect> effects) {
    setState(() {
      final _wrappedEffects = effects.map(_wrapEffect).toList();
      _effects.clear();
      _effects.addAll(_wrappedEffects);
    });
  }

  EffectWrapper _wrapEffect(ArEffect effect) {
    final status = _getArEffectStatus(effect);
    return EffectWrapper(effect, status);
  }

  ArEffectStatus _getArEffectStatus(ArEffect effect) {
    final isDownloaded = effect.isDownloaded;
    final isDownloading = _downloadingEffects.contains(effect.name);
    final ArEffectStatus status;
    if (isDownloaded) {
      status = ArEffectStatus.downloaded;
    } else if (isDownloading) {
      status = ArEffectStatus.downloading;
    } else {
      status = ArEffectStatus.notDownloaded;
    }
    return status;
  }

  void _onEffectTap(ArEffect effect) {
    final isEffectDownloaded = effect.isDownloaded;
    if (isEffectDownloaded) {
      _selectEffect(effect);
    } else {
      _downloadEffect(effect);
    }
  }

  Future<void> _downloadEffect(ArEffect effect) async {
    try {
      setState(() {
        _downloadingEffects.add(effect.name);
        for (var effectWrapper in _effects) {
          if (_downloadingEffects.contains(effectWrapper.effect.name)) {
            effectWrapper.status = ArEffectStatus.downloading;
          }
        }
      });
      await _arcloudPlugin.downloadEffect(effect.name);
      _showMessage('Effect ${effect.name} loaded');
      setState(() => _downloadingEffects.remove(effect.name));
    } on Exception catch (e) {
      setState(() {
        for (var effectWrapper in _effects) {
          if (_downloadingEffects.contains(effectWrapper.effect.name)) {
            effectWrapper.status = ArEffectStatus.notDownloaded;
          }
        }
        _downloadingEffects.remove(effect.name);
      });
      _showMessage(e.toString());
    }
  }

  void _selectEffect(ArEffect effect) {
    _showMessage('${effect.name} effect selected');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }
}
