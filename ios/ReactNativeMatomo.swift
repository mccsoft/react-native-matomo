import MatomoTracker

@objc(ReactNativeMatomo)
class ReactNativeMatomo: NSObject {

    var tracker: MatomoTracker!

    @objc public func initTracker(_ url:String, id:NSNumber, dimension:String) {
        let baseUrl = URL(string:url)
        let siteId = id.stringValue
        tracker = MatomoTracker(siteId: siteId, baseURL: baseUrl!)
        if (dimension != nil) {
            tracker.setDimension(dimension, forIndex:1)
        }
    }

    @objc public func setUserId(_ userID:String) {
        if (tracker != nil) {
            tracker.userId = userID
        }
    }

    @objc public func setCustomDimension(_ index:NSNumber, value:String) {
        if (tracker != nil) {
            if(value == nil){
                tracker.remove(dimensionAtIndex: index.intValue)
            } else {
                tracker.setDimension(value,forIndex:index.intValue)
            }
        }
    }

    @objc public func trackScreen(_ path:String, title:String) {
        if (tracker != nil) {
            let views = path.components(separatedBy: "/")
            tracker.track(view: views)
        }
    }

    @objc public func trackGoal(_ goal:NSNumber, values:NSDictionary) {
        if (tracker != nil) {
            let revenue = values.object(forKey: "revenue") as? Float
            tracker.trackGoal(id: goal.intValue, revenue: revenue)
        }
    }

    @objc public func trackEvent(_ category:String, action:String, values:NSDictionary) {
        if (tracker != nil) {
            let name = values.object(forKey: "name") as? String
            let value = values.object(forKey: "value") as? NSNumber
            let url = values.object(forKey: "url") as? String
            let nsUrl = url != nil ? URL.init(string: url!) : nil
            tracker.track(eventWithCategory: category, action: action, name: name, number: value, url: nsUrl)
        }
    }

    @objc public func trackContentImpression(_ name:String, values: NSDictionary) {
        if (tracker != nil) {
            let piece = values.object(forKey: "piece") as? String
            let target = values.object(forKey: "target") as? String
            tracker.trackContentImpression(name: name, piece: piece, target: target)
        }
    }

    @objc public func trackContentInteraction(_ name:String, values:NSDictionary) {
        if (tracker != nil) {
            let interaction = values.object(forKey: "interaction") as? String
            let piece = values.object(forKey: "piece") as? String
            let target = values.object(forKey: "target") as? String
            tracker.trackContentInteraction(name: name, interaction: interaction!, piece: piece, target: target)
        }
    }

    @objc public func trackSearch(_ query:String, values:NSDictionary) {
        if (tracker != nil) {
            let category = values.object(forKey: "category") as? String
            let resultCount = values.object(forKey: "resultCount") as? NSNumber
            let url = values.object(forKey: "url") as? String

            let intResultCount:Int = resultCount != nil ? resultCount!.intValue : 0;
            let nsUrl:URL? = url != nil ? URL.init(string: url!) : nil;
            tracker.trackSearch(query: query, category: category, resultCount: intResultCount, url: nsUrl)
        }
    }

    @objc public func trackAppDownload() {
        // TODO: not implemented yet
    }
    
    @objc public func isInitialized() {
        // TODO: not implemented yet
    }

    @objc public func setAppOptOut(_ optOut:Bool) {
        tracker.isOptedOut = optOut;
    }

}
