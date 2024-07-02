#import <React/RCTBridgeModule.h>
#import <React/RCTConvert.h>

@interface RCT_EXTERN_MODULE(Passkey, NSObject)

RCT_EXTERN_METHOD(register:(NSString)request
                            withPlatformKey:(BOOL) platformKey
                            withSecurityKey:(BOOL) securityKey
                            withResolver:(RCTPromiseResolveBlock)resolve
                            withRejecter:(RCTPromiseRejectBlock)reject);

RCT_EXTERN_METHOD(authenticate:(NSString)request
                  withPlatformKey:(BOOL) platformKey
                  withSecurityKey:(BOOL) securityKey
                  withResolver:(RCTPromiseResolveBlock)resolve
                  withRejecter:(RCTPromiseRejectBlock)reject);

+ (BOOL)requiresMainQueueSetup
{
  return NO;
}

@end
