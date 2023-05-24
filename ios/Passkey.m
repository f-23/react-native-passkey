#import <React/RCTBridgeModule.h>
#import <React/RCTConvert.h>

@interface RCT_EXTERN_MODULE(Passkey, NSObject)

RCT_EXTERN_METHOD(register:(NSString)identifier
                  withChallenge:(NSString)challenge
                  withDisplayName:(NSString) displayName
                  withUserId:(NSString) userId
                  withSecurityKey: (BOOL) securityKey
                  withResolver:(RCTPromiseResolveBlock)resolve
                  withRejecter:(RCTPromiseRejectBlock)reject);

RCT_EXTERN_METHOD(authenticate:(NSString)identifier
                  withChallenge:(NSString)challenge
                  withSecurityKey:(BOOL) securityKey
                  withResolver:(RCTPromiseResolveBlock)resolve
                  withRejecter:(RCTPromiseRejectBlock)reject);

+ (BOOL)requiresMainQueueSetup
{
  return NO;
}

@end
