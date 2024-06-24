#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(ReactNativeMatomo, NSObject)

+(BOOL)requiresMainQueueSetup {
    return YES;
}

RCT_EXTERN_METHOD(initialize:(NSString*)url withId:(NSNumber* _Nonnull)id
                  withCachedQueue:(BOOL _Nonnull)cachedQueue
                  withResolver:(RCTPromiseResolveBlock)resolve
                  withRejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(setUserId:(NSString* _Nonnull)userID
                  withResolver:(RCTPromiseResolveBlock)resolve
                  withRejecter:(RCTPromiseRejectBlock)reject);

RCT_EXTERN_METHOD(setCustomDimension: (NSNumber* _Nonnull)index withValue:(NSString* _Nullable)value
                  withResolver:(RCTPromiseResolveBlock)resolve
                  withRejecter:(RCTPromiseRejectBlock)reject);

RCT_EXTERN_METHOD(trackView: (NSString* _Nonnull)path withTitle:(NSString* _Nullable)title
                  withResolver:(RCTPromiseResolveBlock)resolve
                  withRejecter:(RCTPromiseRejectBlock)reject);

RCT_EXTERN_METHOD(trackGoal: (NSNumber* _Nonnull)goal withValues:(NSDictionary* _Nonnull)values
                  withResolver:(RCTPromiseResolveBlock)resolve
                  withRejecter:(RCTPromiseRejectBlock)reject);

RCT_EXTERN_METHOD(trackEvent:(NSString* _Nonnull)category withAction:(NSString* _Nonnull)action withValues:(NSDictionary* _Nonnull)values
                  withResolver:(RCTPromiseResolveBlock)resolve
                  withRejecter:(RCTPromiseRejectBlock)reject);

RCT_EXTERN_METHOD(setAppOptOut:(BOOL _Nonnull) optOut
                  withResolver:(RCTPromiseResolveBlock)resolve
                  withRejecter:(RCTPromiseRejectBlock)reject);

RCT_EXTERN_METHOD(trackAppDownload:(RCTPromiseResolveBlock)resolve withRejecter:(RCTPromiseRejectBlock)reject);

RCT_EXTERN_METHOD(isInitialized:(RCTPromiseResolveBlock)resolve withRejecter:(RCTPromiseRejectBlock)reject);

RCT_EXTERN_METHOD(dispatch:(RCTPromiseResolveBlock)resolve withRejecter:(RCTPromiseRejectBlock)reject);

RCT_EXTERN_METHOD(setDispatchInterval: (NSNumber* _Nonnull)seconds
                  withResolver:(RCTPromiseResolveBlock)resolve
                  withRejecter:(RCTPromiseRejectBlock)reject);

RCT_EXTERN_METHOD(getDispatchInterval:(RCTPromiseResolveBlock)resolve withRejecter:(RCTPromiseRejectBlock)reject);

RCT_EXTERN_METHOD(trackSiteSearch:(NSString* _Nonnull)query withCategory:(NSString* _Nullable)category withResultCount:(NSNumber* _Nullable)resultCount
                  withResolver:(RCTPromiseResolveBlock)resolve
                  withRejecter:(RCTPromiseRejectBlock)reject);

@end
