import 'dart:async';

import 'package:banuba_arcloud/banuba_arcloud.dart';
import 'package:banuba_arcloud_example/effect_tile.dart';
import 'package:banuba_arcloud_example/effect_wrapper.dart';
import 'package:flutter/material.dart';

const arCloudUrl = // SET UP BANUBA AR CLOUD URL;

const _tag = 'ARCloudSample';

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
  final _plugin = BanubaARCloudPlugin();
  final _effects = <EffectWrapper>[];
  final _downloadingEffects = <String>[];
  late StreamSubscription<void> _effectsStreamSubscription;

  @override
  void initState() {
    _listenEffects();
    super.initState();
    _plugin.init(
      arCloudUrl: arCloudUrl,
    );
  }

  @override
  void dispose() {
    _effectsStreamSubscription.cancel();
    _plugin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        bottom: true,
        child: Scaffold(
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
        ));
  }

  void _listenEffects() {
    _effectsStreamSubscription = _plugin.getEffectsStream().listen(
          _onEffectsLoaded,
          onError: (e) => _showMessage(e.toString()),
        );
  }

  Future<void> _loadEffects() async {
    await _plugin.loadEffects();
  }

  void _onEffectsLoaded(List<Effect> effects) {
    setState(() {
      debugPrint("$_tag effects loaded = $_effects");
      final _wrappedEffects = effects.map(_wrapEffect).toList();
      _effects.clear();
      _effects.addAll(_wrappedEffects);
    });
  }

  EffectWrapper _wrapEffect(Effect effect) => EffectWrapper(effect, _detectEffectStatus(effect));

  ArEffectStatus _detectEffectStatus(Effect effect) {
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

  void _onEffectTap(Effect effect) {
    final isEffectDownloaded = effect.isDownloaded;
    if (isEffectDownloaded) {
      _selectEffect(effect);
    } else {
      _downloadEffect(effect);
    }
  }

  Future<void> _downloadEffect(Effect effect) async {
    try {
      setState(() {
        _downloadingEffects.add(effect.name);
        for (var effectWrapper in _effects) {
          if (_downloadingEffects.contains(effectWrapper.effect.name)) {
            effectWrapper.status = ArEffectStatus.downloading;
          }
        }
      });
      await _plugin.downloadEffect(effect.name);
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

  void _selectEffect(Effect effect) {
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
