# Banuba ARCloud plugin

AR Cloud is a client-server solution that helps to save space in your application. This is a product used to store AR filters i.e. masks on a server-side instead of the SDK code. After being selected by the user for the first time, the filter is going to be downloaded from the server and then saved on the phone's memory.



## Installing

To use this plugin, add `banuba_arcloud` as a dependency in your pubspec.yaml file:

```yaml
banuba_arcloud:
  git:
    url: git@bitbucket.org:BanubaLimited/arcloud-flutter.git
    ref: 0.0.1
```

Now in your `Dart` code, you can use:

```dart
import 'package:banuba_arcloud/banuba_arcloud.dart';
```



## Platform specific configuration

### Android

1. Copy Banuba credentials into your project level `build.gradle` to access Banuba SDK modules:

```groovy
allprojects {
    repositories {
        google()
        mavenCentral()

        def banubaRepoUser = "Banuba"
        def banubaRepoPassword = "\u0038\u0036\u0032\u0037\u0063\u0035\u0031\u0030\u0033\u0034\u0032\u0063\u0061\u0033\u0065\u0061\u0031\u0032\u0034\u0064\u0065\u0066\u0039\u0062\u0034\u0030\u0063\u0063\u0037\u0039\u0038\u0063\u0038\u0038\u0066\u0034\u0031\u0032\u0061\u0038"
        maven {
            name = "ARCloudPackages"
            url = uri("https://maven.pkg.github.com/Banuba/banuba-ar")
            credentials {
                username = banubaRepoUser
                password = banubaRepoPassword
            }
        }
    }
}
```

2. Copy dependencies into your app module level `build.gradle`:

```groovy
compileOnly fileTree(dir: '../libs', include: ['*.aar'])
implementation 'com.banuba.sdk:ar-cloud:1.19.0'
```

3. Copy and Paste your AR Cloud URL into appropriate section of `BanubaClientToken`:

```kotlin
internal const val BANUBA_AR_CLOUD_URL: String = <Place your url here>
```

4. The plugin uses Koin, you need to implement it to your application. Create a module where arcloud url is initialized:

```kotlin
class MainKoinModule {
    val module = module {
        single(named("arEffectsCloudUrl"), override = true) {
            BANUBA_AR_CLOUD_URL
        }
    }
}
```

5. Add `FlutterArCloudKoinModule()` with your custom modules when initializing Koin:

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

1. `AppDelegate` must implement `ARCloudPluginDelegate` to specify the arcloud url:

```xml
@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate, ARCloudPluginDelegate {
    var arCloudURL: String = <Place your url here>
```

More [information](https://docs.banuba.com/face-ar-sdk/ios/ios_overview) about Banuba iOS sdk.



## Usage

Use `BanubaArcloudPlugin` to work with the plugin:

```yaml
final _arcloudPlugin = BanubaArcloudPlugin();
```

Don't forget to call methods to initialize and close resources:

```yaml
_arcloudPlugin.init();
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
