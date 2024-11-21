import Foundation

final class UserSettings {
    static let shared = UserSettings()
    
    private let defaults = UserDefaults.standard
    
    private init() {}
    
    var hasSeenOnboarding: Bool {
        get {
            return defaults.bool(forKey: "hasSeenOnboarding")
        }
        set {
            defaults.set(newValue, forKey: "hasSeenOnboarding")
        }
    }
}
