#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(ReactNativeMatomo, NSObject)

+(BOOL)requiresMainQueueSetup {
    return YES;
}

RCT_EXTERN_METHOD(initialize:(NSString* _Nonnull)instanceId
                  withUrl:(NSString* _Nonnull)url
                  withId:(NSNumber* _Nonnull)id
                  withCachedQueue:(BOOL _Nonnull)cachedQueue
                  withResolver:(RCTPromiseResolveBlock)resolve
                  withRejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(isInitialized:(NSString* _Nonnull)instanceId
                  withResolver:(RCTPromiseResolveBlock)resolve
                  withRejecter:(RCTPromiseRejectBlock)reject);

RCT_EXTERN_METHOD(setUserId:(NSString* _Nonnull)instanceId
                  withUserID:(NSString* _Nonnull)userID
                  withResolver:(RCTPromiseResolveBlock)resolve
                  withRejecter:(RCTPromiseRejectBlock)reject);

RCT_EXTERN_METHOD(setCustomDimension:(NSString* _Nonnull)instanceId
                  withIndex:(NSNumber* _Nonnull)index
                  withValue:(NSString* _Nullable)value
                  withResolver:(RCTPromiseResolveBlock)resolve
                  withRejecter:(RCTPromiseRejectBlock)reject);

RCT_EXTERN_METHOD(trackView:(NSString* _Nonnull)instanceId
                  withPath:(NSString* _Nonnull)path
                  withTitle:(NSString* _Nullable)title
                  withResolver:(RCTPromiseResolveBlock)resolve
                  withRejecter:(RCTPromiseRejectBlock)reject);

RCT_EXTERN_METHOD(trackGoal:(NSString* _Nonnull)instanceId
                  withGoal:(NSNumber* _Nonnull)goal
                  withValues:(NSDictionary* _Nonnull)values
                  withResolver:(RCTPromiseResolveBlock)resolve
                  withRejecter:(RCTPromiseRejectBlock)reject);

RCT_EXTERN_METHOD(trackEvent:(NSString* _Nonnull)instanceId
                  withCategory:(NSString* _Nonnull)category
                  withAction:(NSString* _Nonnull)action
                  withValues:(NSDictionary* _Nonnull)values
                  withResolver:(RCTPromiseResolveBlock)resolve
                  withRejecter:(RCTPromiseRejectBlock)reject);

RCT_EXTERN_METHOD(setAppOptOut:(NSString* _Nonnull)instanceId
                  withOptOut:(BOOL _Nonnull)optOut
                  withResolver:(RCTPromiseResolveBlock)resolve
                  withRejecter:(RCTPromiseRejectBlock)reject);

RCT_EXTERN_METHOD(trackAppDownload:(NSString* _Nonnull)instanceId
                  withResolver:(RCTPromiseResolveBlock)resolve
                  withRejecter:(RCTPromiseRejectBlock)reject);

RCT_EXTERN_METHOD(dispatch:(NSString* _Nonnull)instanceId
                  withResolver:(RCTPromiseResolveBlock)resolve
                  withRejecter:(RCTPromiseRejectBlock)reject);

RCT_EXTERN_METHOD(setDispatchInterval:(NSString* _Nonnull)instanceId
                  withSeconds:(NSNumber* _Nonnull)seconds
                  withResolver:(RCTPromiseResolveBlock)resolve
                  withRejecter:(RCTPromiseRejectBlock)reject);

RCT_EXTERN_METHOD(getDispatchInterval:(NSString* _Nonnull)instanceId
                  withResolver:(RCTPromiseResolveBlock)resolve
                  withRejecter:(RCTPromiseRejectBlock)reject);

RCT_EXTERN_METHOD(trackSiteSearch:(NSString* _Nonnull)instanceId
                  withQuery:(NSString* _Nonnull)query
                  withCategory:(NSString* _Nullable)category
                  withResultCount:(NSNumber* _Nullable)resultCount
                  withResolver:(RCTPromiseResolveBlock)resolve
                  withRejecter:(RCTPromiseRejectBlock)reject);

RCT_EXTERN_METHOD(stop:(NSString* _Nonnull)instanceId
                  withDispatchRemaining:(BOOL _Nonnull)dispatchRemaining
                  withResolver:(RCTPromiseResolveBlock)resolve
                  withRejecter:(RCTPromiseRejectBlock)reject);

RCT_EXTERN_METHOD(reset:(NSString* _Nonnull)instanceId
                  withResolver:(RCTPromiseResolveBlock)resolve
                  withRejecter:(RCTPromiseRejectBlock)reject);

RCT_EXTERN_METHOD(resetCustomDimensions:(NSString* _Nonnull)instanceId
                  withResolver:(RCTPromiseResolveBlock)resolve
                  withRejecter:(RCTPromiseRejectBlock)reject);

RCT_EXTERN_METHOD(getUserId:(NSString* _Nonnull)instanceId
                  withResolver:(RCTPromiseResolveBlock)resolve
                  withRejecter:(RCTPromiseRejectBlock)reject);

RCT_EXTERN_METHOD(startNewSession:(NSString* _Nonnull)instanceId
                  withResolver:(RCTPromiseResolveBlock)resolve
                  withRejecter:(RCTPromiseRejectBlock)reject);

@end
