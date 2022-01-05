# Banuba ARCloud plugin

AR Cloud is a client-server solution that helps to save space in your application. This is a product used to store AR filters i.e. masks on a server-side instead of the SDK code. After being selected by the user for the first time, the filter is going to be downloaded from the server and then saved on the phone's memory.



## Installing

To use this plugin, add `banuba_arcloud` as a dependency in your pubspec.yaml file:

```yaml
banuba_arcloud:
  git:
    url: git@bitbucket.org:BanubaLimited/arcloud-flutter.git
    ref: 0.0.3
```

Now in your `Dart` code, you can use:

```dart
import 'package:banuba_arcloud/banuba_arcloud.dart';
```



## Platform specific configuration

### Android

1. Copy dependencies into your app module level `build.gradle`:

```groovy
implementation 'com.banuba.sdk:ar-cloud:1.19.0'
```

2. Add `FlutterArCloudKoinModule()` with your custom modules when initializing Koin:

```kotlin
class App : Application() {

    override fun onCreate() {
        super.onCreate()

        startKoin {
            androidContext(this@App)
            modules(
                FlutterArCloudKoinModule().modules.plus(MainKoinModule().module),
            )
        }
    }
}
```

More [information](https://docs.banuba.com/face-ar-sdk/android/android_overview) about Banuba android sdk.



### iOS

No special setup needed.

More [information](https://docs.banuba.com/face-ar-sdk/ios/ios_overview) about Banuba iOS sdk.



## Usage

Use `BanubaArcloudPlugin` to work with the plugin:

```yaml
final _arcloudPlugin = BanubaArcloudPlugin();
```

Before you start using plugin you should provide your `arCloudUrl` to `init()` function:

```
_arcloudPlugin.init(arCloudUrl: 'https://example.com');
```
Don't forget to dispose plugin:

```
_arcloudPlugin.dispose();
```

Loading a list of effects.  `ArcloudEffectsLoadingException` is thrown when an error occurs while loading effects. `ArcloudUnknownException` is thrown when something went wrong.

```yaml
final effects = await _arcloudPlugin.getEffects();
```

Downloading the effect. `ArcloudEffectDownloadingException` thrown when on error while downloading an effect. `ArcloudUnknownException` is thrown when something went wrong.

```yaml
await _arcloudPlugin.downloadEffect(effect.name);
```

You can also listen to stream effects. The data in it is emitted after downloading the effect. Don't forget to catch exceptions. `ArcloudEffectsLoadingException` and `ArcloudUnknownException` are thrown here.

```yaml
_effectsStreamSubscription = _arcloudPlugin.getEffectsStream().listen(
	_onEffectsLoaded,
	onError: (e) => _showMessage(e.toString()),
);
```

See the sample for more information on using the plugin.

Enjoy!
