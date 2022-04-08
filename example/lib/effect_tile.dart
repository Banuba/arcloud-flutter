import 'dart:io';

import 'package:banuba_arcloud/banuba_arcloud.dart';
import 'package:banuba_arcloud_example/effect_wrapper.dart';
import 'package:flutter/material.dart';

class EffectTile extends StatelessWidget {
  const EffectTile({
    Key? key,
    required this.effectWrapper,
    required this.onEffectTap,
  }) : super(key: key);

  final EffectWrapper effectWrapper;
  final ValueChanged<ArEffect> onEffectTap;

  ArEffect get effect => effectWrapper.effect;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.all(8),
      leading: GestureDetector(
        onTap: () => onEffectTap(effect),
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: 60,
          height: 60,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: effect.isDownloaded
                    ? Image.file(File(effect.preview ?? ''))
                    : Image.network(effect.preview ?? ''),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: _EffectStatusIndicator(
                  status: effectWrapper.status,
                ),
              ),
            ],
          ),
        ),
      ),
      trailing: GestureDetector(
        onTap: () => _showEffectDialog(context),
        behavior: HitTestBehavior.opaque,
        child: const SizedBox(
          width: 40,
          height: 40,
          child: Icon(Icons.info),
        ),
      ),
      title: Text(effect.name),
    );
  }

  void _showEffectDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Effect'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('default: ${effect.isDefault}'),
              const SizedBox(height: 10),
              Text('eTag: ${effect.eTag}'),
              const SizedBox(height: 10),
              Text('id: ${effect.id}'),
              const SizedBox(height: 10),
              Text('name: ${effect.name}'),
              const SizedBox(height: 10),
              Text('preview: ${effect.preview}'),
              const SizedBox(height: 10),
              Text('type: ${effect.type}'),
              const SizedBox(height: 10),
              Text('uri: ${effect.uri}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}

class _EffectStatusIndicator extends StatelessWidget {
  const _EffectStatusIndicator({
    Key? key,
    required this.status,
  }) : super(key: key);

  final ArEffectStatus status;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
      height: 20,
      child: status == ArEffectStatus.downloading
          ? CircularProgressIndicator(color: Colors.black.withOpacity(0.6))
          : status == ArEffectStatus.notDownloaded
              ? Image.asset('assets/effect/download.png')
              : const SizedBox.shrink(),
    );
  }
}
