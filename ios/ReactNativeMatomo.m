#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(ReactNativeMatomo, NSObject)

RCT_EXTERN_METHOD(initialize:(nonnull NSString *)apiUrl
                  siteId:(nonnull NSNumber *)siteId
                  resolver:(RCTPromiseResolveBlock)resolver
                  rejecter:(RCTPromiseRejectBlock)rejecter
                  )
RCT_EXTERN_METHOD(trackView:(nonnull NSString *)route
                  title:(NSString *)value
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

RCT_EXTERN_METHOD(trackGoal: (NSNumber* _Nonnull)goal values:(NSDictionary* _Nonnull) values);
RCT_EXTERN_METHOD(trackAppDownload);
RCT_EXTERN_METHOD(setAppOptOut:(BOOL _Nonnull) optOut);


+ (BOOL)requiresMainQueueSetup
{
  return NO;
}

@end
