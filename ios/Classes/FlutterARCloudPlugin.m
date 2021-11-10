#import "FlutterARCloudPlugin.h"
#if __has_include(<banuba_arcloud/banuba_arcloud-Swift.h>)
#import <banuba_arcloud/banuba_arcloud-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "banuba_arcloud-Swift.h"
#endif

@implementation FlutterARCloudPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [ARCloudPlugin registerWithRegistrar:registrar];
}
@end
