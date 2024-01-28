# Banuba ARCloud plugin

AR Cloud is a client-server solution that helps to save space in your application. This is a product used to store AR filters i.e. masks on a server-side instead of the SDK code. After being selected by the user for the first time, the filter is going to be downloaded from the server and then saved on the phone's memory.

## Requirements
### Android
- `minSdkVersion 23`
- `Kotlin 1.7.20`

## Installing

Add `banuba_arcloud` in your ```pubspec.yaml``` file.

```yaml
dependencies:
  flutter:
    sdk: flutter
    banuba_arcloud: ^1.0.2
```

Import in Dart code to access plugin functionalities.
```dart
import 'package:banuba_arcloud/banuba_arcloud.dart';
```

## Usage

```BanubaARCloudPlugin``` is the main class responsible for all interactions with AR Cloud.

First, create new instance.
```dart
final plugin = BanubaARCloudPlugin();
```

Listen to any effects changes using ```getEffectsStream()``` method. List of effects 
contains local(stored in the local database) and remote(stored on AR Cloud) effects. 
The callback is called when
- effects are loaded from local database
- effects are loaded from AR Cloud
- effect is downloaded

```dart
final effectsStreamSubscription = plugin.getEffectsStream().listen(
_onEffectsLoaded,
onError: (e) => ...,
);
```

Set your AR Cloud url. Normally this url is provided by Banuba representatives.
```dart
 final arCloudUrl = '';
 plugin.init(arCloudUrl: arCloudUrl);
```

Load effects from AR Cloud. New list of effects will be pushed when effects are loaded from AR Cloud successfully.
```dart
Future<void> _loadEffects() async {
  await plugin.loadEffects();
}
```

Download effect. New list of effects will be pushed to the stream when the effect is downloaded.
```dart
try {
await plugin.downloadEffect(effect.name);
} on Exception catch (e) {
// handle exception
}
```

Dispose plugin when you complete interaction with AR Cloud.

```dart
 @override
  void dispose() {
    _effectsStreamSubscription.cancel();
    _plugin.dispose();
    super.dispose();
  }
```

