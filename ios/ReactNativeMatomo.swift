import MatomoTracker
import Darwin

@objc(ReactNativeMatomo)
class ReactNativeMatomo: NSObject {

    /// Default instance ID for backward compatibility
    private static let DEFAULT_INSTANCE_ID = "default"
    
    /// Dictionary to store multiple tracker instances
    private static var trackers: [String: MatomoTracker] = [:]
    
    /// Dictionary to store custom dimensions per instance
    private static var customDimensions: [String: [Int: String]] = [:]
    
    /// Generate a unique cache key for an instance
    private func cacheKey(for instanceId: String, siteId: String) -> String {
        if instanceId == ReactNativeMatomo.DEFAULT_INSTANCE_ID {
            // Use legacy key format for default instance to maintain backward compatibility
            return siteId
        }
        return "\(instanceId)_\(siteId)"
    }
    
    @objc(initialize:withUrl:withSiteId:withCachedQueue:withResolver:withRejecter:)
    func initialize(
        instanceId: String,
        url: String,
        siteIdNumber: NSNumber,
        cachedQueue: Bool,
        resolve: RCTPromiseResolveBlock,
        reject: RCTPromiseRejectBlock) -> Void
    {
        let baseUrl = URL(string: url)
        let siteId = siteIdNumber.stringValue
        let cacheIdentifier = cacheKey(for: instanceId, siteId: siteId)
        
        var newTracker: MatomoTracker
        
        if cachedQueue {
            let queue = UserDefaultsCachedQueue(UserDefaults.standard, siteId: cacheIdentifier, autoSave: true)
            let dispatcher = URLSessionDispatcher(baseURL: baseUrl!)
            newTracker = MatomoTracker(siteId: siteId, queue: queue, dispatcher: dispatcher)
        } else {
            newTracker = MatomoTracker(siteId: siteId, baseURL: baseUrl!)
        }
        
        ReactNativeMatomo.trackers[instanceId] = newTracker
        ReactNativeMatomo.customDimensions[instanceId] = [:]
        
        resolve(nil)
    }
    
    @objc(isInitialized:withResolver:withRejecter:)
    func isInitialized(
        instanceId: String,
        resolve: RCTPromiseResolveBlock,
        reject: RCTPromiseRejectBlock) -> Void
    {
        resolve(ReactNativeMatomo.trackers[instanceId] != nil)
    }

    @objc(setUserId:withUserID:withResolver:withRejecter:)
    func setUserId(
        instanceId: String,
        userID: String,
        resolve: RCTPromiseResolveBlock,
        reject: RCTPromiseRejectBlock) -> Void
    {
        guard let tracker = ReactNativeMatomo.trackers[instanceId] else {
            reject("not_initialized", "Matomo instance '\(instanceId)' not initialized", nil)
            return
        }
        tracker.userId = userID
        resolve(nil)
    }

    @objc(setCustomDimension:withIndex:withValue:withResolver:withRejecter:)
    func setCustomDimension(
        instanceId: String,
        index: NSNumber,
        value: String?,
        resolve: RCTPromiseResolveBlock,
        reject: RCTPromiseRejectBlock) -> Void
    {
        guard let tracker = ReactNativeMatomo.trackers[instanceId] else {
            reject("not_initialized", "Matomo instance '\(instanceId)' not initialized", nil)
            return
        }

        if let unwrappedValue = value {
            tracker.setDimension(unwrappedValue, forIndex: index.intValue)
            if ReactNativeMatomo.customDimensions[instanceId] == nil {
                ReactNativeMatomo.customDimensions[instanceId] = [:]
            }
            ReactNativeMatomo.customDimensions[instanceId]?[index.intValue] = unwrappedValue
        } else {
            tracker.remove(dimensionAtIndex: index.intValue)
            ReactNativeMatomo.customDimensions[instanceId]?.removeValue(forKey: index.intValue)
        }
        
        resolve(nil)
    }

    @objc(trackView:withPath:withTitle:withResolver:withRejecter:)
    func trackView(
        instanceId: String,
        path: String,
        title: String?,
        resolve: RCTPromiseResolveBlock,
        reject: RCTPromiseRejectBlock) -> Void
    {
        guard let tracker = ReactNativeMatomo.trackers[instanceId] else {
            reject("not_initialized", "Matomo instance '\(instanceId)' not initialized. TrackView failed", nil)
            return
        }

        let action = (title ?? path).components(separatedBy: "/")
        let url = tracker.contentBase?.appendingPathComponent(path)
        
        guard let finalURL = url else {
            reject("invalid_url", "Failed to generate a valid URL.", nil)
            return
        }
        
        tracker.track(view: action, url: finalURL)
        resolve(nil)
    }

    @objc(trackGoal:withGoal:withValues:withResolver:withRejecter:)
    func trackGoal(
        instanceId: String,
        goal: NSNumber,
        values: NSDictionary,
        resolve: RCTPromiseResolveBlock,
        reject: RCTPromiseRejectBlock) -> Void
    {
        guard let tracker = ReactNativeMatomo.trackers[instanceId] else {
            reject("not_initialized", "Matomo instance '\(instanceId)' not initialized", nil)
            return
        }
        let revenue = values.object(forKey: "revenue") as? Float
        tracker.trackGoal(id: goal.intValue, revenue: revenue)
        resolve(nil)
    }

    @objc(trackEvent:withCategory:withAction:withValues:withResolver:withRejecter:)
    func trackEvent(
        instanceId: String,
        category: String,
        action: String,
        values: NSDictionary,
        resolve: RCTPromiseResolveBlock,
        reject: RCTPromiseRejectBlock) -> Void
    {
        guard let tracker = ReactNativeMatomo.trackers[instanceId] else {
            reject("not_initialized", "Matomo instance '\(instanceId)' not initialized", nil)
            return
        }
        let name = values.object(forKey: "name") as? String
        let value = values.object(forKey: "value") as? NSNumber
        let url = values.object(forKey: "url") as? String
        let nsUrl = url != nil ? URL.init(string: url!) : nil
        tracker.track(eventWithCategory: category, action: action, name: name, number: value, url: nsUrl)
        resolve(nil)
    }

    @objc(trackAppDownload:withResolver:withRejecter:)
    func trackAppDownload(
        instanceId: String,
        resolve: RCTPromiseResolveBlock,
        reject: RCTPromiseRejectBlock) -> Void
    {
        // TODO: not implemented yet
        resolve(nil)
    }

    @objc(setAppOptOut:withOptOut:withResolver:withRejecter:)
    func setAppOptOut(
        instanceId: String,
        optOut: Bool,
        resolve: RCTPromiseResolveBlock,
        reject: RCTPromiseRejectBlock) -> Void
    {
        guard let tracker = ReactNativeMatomo.trackers[instanceId] else {
            reject("not_initialized", "Matomo instance '\(instanceId)' not initialized", nil)
            return
        }
        tracker.isOptedOut = optOut
        resolve(nil)
    }

    @objc(dispatch:withResolver:withRejecter:)
    func dispatch(
        instanceId: String,
        resolve: RCTPromiseResolveBlock,
        reject: RCTPromiseRejectBlock) -> Void
    {
        guard let tracker = ReactNativeMatomo.trackers[instanceId] else {
            reject("not_initialized", "Matomo instance '\(instanceId)' not initialized", nil)
            return
        }
        tracker.dispatch()
        resolve(nil)
    }

    @objc(setDispatchInterval:withSeconds:withResolver:withRejecter:)
    func setDispatchInterval(
        instanceId: String,
        seconds: NSNumber,
        resolve: RCTPromiseResolveBlock,
        reject: RCTPromiseRejectBlock) -> Void
    {
        guard let tracker = ReactNativeMatomo.trackers[instanceId] else {
            reject("not_initialized", "Matomo instance '\(instanceId)' not initialized", nil)
            return
        }
        tracker.dispatchInterval = seconds.doubleValue
        resolve(nil)
    }

    @objc(getDispatchInterval:withResolver:withRejecter:)
    func getDispatchInterval(
        instanceId: String,
        resolve: RCTPromiseResolveBlock,
        reject: RCTPromiseRejectBlock) -> Void
    {
        guard let tracker = ReactNativeMatomo.trackers[instanceId] else {
            reject("not_initialized", "Matomo instance '\(instanceId)' not initialized", nil)
            return
        }
        resolve(tracker.dispatchInterval)
    }
    
    @objc(trackSiteSearch:withQuery:withCategory:withResultCount:withResolver:withRejecter:)
    func trackSiteSearch(
        instanceId: String,
        query: String,
        category: String?,
        resultCount: NSNumber?,
        resolve: RCTPromiseResolveBlock,
        reject: RCTPromiseRejectBlock)
    {
        guard let tracker = ReactNativeMatomo.trackers[instanceId] else {
            reject("not_initialized", "Matomo instance '\(instanceId)' not initialized", nil)
            return
        }
        tracker.trackSearch(query: query, category: category, resultCount: resultCount?.intValue)
        resolve(nil)
    }
    
    @objc(stop:withDispatchRemaining:withResolver:withRejecter:)
    func stop(
        instanceId: String,
        dispatchRemaining: Bool,
        resolve: RCTPromiseResolveBlock,
        reject: RCTPromiseRejectBlock) -> Void
    {
        guard let tracker = ReactNativeMatomo.trackers[instanceId] else {
            reject("not_initialized", "Matomo instance '\(instanceId)' not initialized", nil)
            return
        }
        
        if dispatchRemaining {
            tracker.dispatch()
        }
        
        // Opt out to prevent any further event processing
        tracker.isOptedOut = true
        
        // Set dispatch interval to 0 to prevent new dispatch timers from starting
        tracker.dispatchInterval = 0
        
        // Only remove this specific instance from our dictionaries
        ReactNativeMatomo.trackers.removeValue(forKey: instanceId)
        ReactNativeMatomo.customDimensions.removeValue(forKey: instanceId)
        
        resolve(nil)
    }
    
    @objc(reset:withResolver:withRejecter:)
    func reset(
        instanceId: String,
        resolve: RCTPromiseResolveBlock,
        reject: RCTPromiseRejectBlock) -> Void
    {
        guard let tracker = ReactNativeMatomo.trackers[instanceId] else {
            reject("not_initialized", "Matomo instance '\(instanceId)' not initialized", nil)
            return
        }
        
        tracker.reset()
        
        resolve(nil)
    }
    
    @objc(resetCustomDimensions:withResolver:withRejecter:)
    func resetCustomDimensions(
        instanceId: String,
        resolve: RCTPromiseResolveBlock,
        reject: RCTPromiseRejectBlock) -> Void
    {
        guard let tracker = ReactNativeMatomo.trackers[instanceId] else {
            reject("not_initialized", "Matomo instance '\(instanceId)' not initialized", nil)
            return
        }
        
        // Remove all custom dimensions
        if let dimensions = ReactNativeMatomo.customDimensions[instanceId] {
            for index in dimensions.keys {
                tracker.remove(dimensionAtIndex: index)
            }
        }
        ReactNativeMatomo.customDimensions[instanceId] = [:]
        
        resolve(nil)
    }
    
    @objc(getUserId:withResolver:withRejecter:)
    func getUserId(
        instanceId: String,
        resolve: RCTPromiseResolveBlock,
        reject: RCTPromiseRejectBlock) -> Void
    {
        guard let tracker = ReactNativeMatomo.trackers[instanceId] else {
            reject("not_initialized", "Matomo instance '\(instanceId)' not initialized", nil)
            return
        }
        resolve(tracker.userId)
    }
    
    @objc(startNewSession:withResolver:withRejecter:)
    func startNewSession(
        instanceId: String,
        resolve: RCTPromiseResolveBlock,
        reject: RCTPromiseRejectBlock) -> Void
    {
        guard let tracker = ReactNativeMatomo.trackers[instanceId] else {
            reject("not_initialized", "Matomo instance '\(instanceId)' not initialized", nil)
            return
        }
        tracker.startNewSession()
        resolve(nil)
    }
}
