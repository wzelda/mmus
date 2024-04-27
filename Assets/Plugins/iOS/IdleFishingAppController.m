#import "UnityAppController.h"
#import <TapBootstrapSDK/TapBootstrapSDK.h>

@interface IdleFishingAppController : UnityAppController
{
    
}

@end

@implementation IdleFishingAppController

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

// UIApplicationOpenURLOptionsKey was added only in ios10 sdk, while we still support ios9 sdk
//- (BOOL)application:(UIApplication*)app openURL:(NSURL*)url options:(NSDictionary<NSString*, id>*)options
//{
//    if (url != nil && [url.scheme isEqualToString:@"lpidlefishing"])
//    {
//        NSURLComponents* urlComponents = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:NO];
//
//        for (NSURLQueryItem* item in urlComponents.queryItems) {
//            if ([item.name isEqualToString:@"LaunchMode"])
//            {
//                [[NSUserDefaults standardUserDefaults] setObject:item.value forKey:item.name];
//            }
//        }
//    }
//
//    return [super application:app openURL:url options:options];
//}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
  return [TDSHandleUrl handleOpenURL:url];
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
  return [TDSHandleUrl handleOpenURL:url];
}

@end

IMPL_APP_CONTROLLER_SUBCLASS(IdleFishingAppController)
