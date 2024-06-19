import Foundation
import MatomoTracker

public final class UserDefaultsCachedQueue: NSObject, Queue {
    private var items: [Event] {
        didSet {
            if autoSave {
                try? UserDefaultsCachedQueue.write(items, to: userDefaults)
            }
        }
    }
    private let userDefaults: UserDefaults
    private let autoSave: Bool
    
    init(_ userDefaults: UserDefaults, autoSave: Bool = false) {
        self.userDefaults = userDefaults
        self.autoSave = autoSave
        self.items = (try? UserDefaultsCachedQueue.readEvents(from: userDefaults)) ?? []
        super.init()
    }
    
    public var eventCount: Int {
        return items.count
    }
    
    public func enqueue(events: [Event], completion: (()->())?) {
        items.append(contentsOf: events)
        completion?()
    }
    
    public func first(limit: Int, completion: (_ items: [Event])->()) {
        let amount = [limit,eventCount].min()!
        let dequeuedItems = Array(items[0..<amount])
        completion(dequeuedItems)
    }
    
    public func remove(events: [Event], completion: ()->()) {
        items = items.filter({ event in !events.contains(where: { eventToRemove in eventToRemove.uuid == event.uuid })})
        completion()
    }
    
    public func save() throws {
        try UserDefaultsCachedQueue.write(items, to: userDefaults)
    }
}

extension UserDefaultsCachedQueue {
    
    private static let userDefaultsKey: String = {
        let bundleIdentifier = Bundle.main.bundleIdentifier ?? "default"
        return "\(bundleIdentifier).UserDefaultsQueue.items"
    }()
    
    private static func readEvents(from userDefaults: UserDefaults) throws -> [Event] {
        guard let data = userDefaults.data(forKey: userDefaultsKey) else { return [] }
        let decoder = JSONDecoder()
        return try decoder.decode([Event].self, from: data)
    }
    
    private static func write(_ events: [Event], to userDefaults: UserDefaults) throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(events)
        userDefaults.set(data, forKey: userDefaultsKey)
    }
    
}
