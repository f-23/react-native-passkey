#import <React/RCTBridgeModule.h>
#import <React/RCTConvert.h>

@interface RCT_EXTERN_MODULE(Passkey, NSObject)

RCT_EXTERN_METHOD(create:(NSString)request
                  withForcePlatformKey:(BOOL)forcePlatformKey
                  withForceSecurityKey:(BOOL)forceSecurityKey
                  withResolver:(RCTPromiseResolveBlock)resolve
                  withRejecter:(RCTPromiseRejectBlock)reject);

RCT_EXTERN_METHOD(get:(NSString)request
                  withForcePlatformKey:(BOOL)forcePlatformKey
                  withForceSecurityKey:(BOOL)forceSecurityKey
                  withResolver:(RCTPromiseResolveBlock)resolve
                  withRejecter:(RCTPromiseRejectBlock)reject);

+ (BOOL)requiresMainQueueSetup
{
  return NO;
}

@end
