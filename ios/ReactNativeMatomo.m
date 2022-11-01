#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(ReactNativeMatomo, NSObject)

RCT_EXTERN_METHOD(multiply:(float)a withB:(float)b
                 withResolver:(RCTPromiseResolveBlock)resolve
                 withRejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(initialize:(nonnull NSString *)apiUrl
                  siteId:(nonnull NSNumber *)siteId
                  resolver:(RCTPromiseResolveBlock)resolver
                  rejecter:(RCTPromiseRejectBlock)rejecter
                  )
RCT_EXTERN_METHOD(trackView:(nonnull NSString *)route
                  resolver:(RCTPromiseResolveBlock)resolver
                  rejecter:(RCTPromiseRejectBlock)rejecter
                  )
RCT_EXTERN_METHOD(trackEvent:(nonnull NSString *) category
                  action:(nonnull NSString *)action
                  optionalParameters:(NSDictionary *)optionalParameters
                  resolver:(RCTPromiseResolveBlock)resolver
                  rejecter:(RCTPromiseRejectBlock)rejecter
                  )
RCT_EXTERN_METHOD(setUserId:(NSString *) userId
                  resolver:(RCTPromiseResolveBlock)resolver
                  rejecter:(RCTPromiseRejectBlock)rejecter
                  )
RCT_EXTERN_METHOD(setCustomDimension:(nonnull NSNumber *)dimensionId
                  value:(NSString *)value
                  resolver:(RCTPromiseResolveBlock)resolver
                  rejecter:(RCTPromiseRejectBlock)rejecter
                  )

+ (BOOL)requiresMainQueueSetup
{
  return NO;
}

@end
