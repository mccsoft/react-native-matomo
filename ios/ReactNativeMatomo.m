#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(ReactNativeMatomo, NSObject)

+(BOOL)requiresMainQueueSetup {
    return YES;
}

RCT_EXTERN_METHOD(initialize:(NSString*)url id:(NSNumber* _Nonnull) id dimension:(NSString* _Nullable) dimension);
RCT_EXTERN_METHOD(setUserId:(NSString* _Nonnull)userID);
RCT_EXTERN_METHOD(setCustomDimension: (NSNumber* _Nonnull)index value: (NSString* _Nullable)value);
RCT_EXTERN_METHOD(trackView: (NSString* _Nonnull)path title: (NSString* _Nullable)title);
RCT_EXTERN_METHOD(trackGoal: (NSNumber* _Nonnull)goal values:(NSDictionary* _Nonnull) values);
RCT_EXTERN_METHOD(trackEvent:(NSString* _Nonnull)category action:(NSString* _Nonnull) action values:(NSDictionary* _Nonnull) values);
RCT_EXTERN_METHOD(trackAppDownload);
RCT_EXTERN_METHOD(setAppOptOut:(BOOL _Nonnull) optOut);
RCT_EXTERN_METHOD(isInitialized);

@end
Footer
