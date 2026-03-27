import Foundation

protocol UserDefaultsServiceProtocol {
    func set<T: Codable>(_ value: T, forKey key: String)
    func get<T: Codable>(forKey key: String) -> T?
    func remove(forKey key: String)
    func getBool(forKey key: String) -> Bool
    func setBool(_ value: Bool, forKey key: String)
}

final class UserDefaultsService: UserDefaultsServiceProtocol {
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func set<T: Codable>(_ value: T, forKey key: String) {
        if let data = try? JSONEncoder().encode(value) {
            defaults.set(data, forKey: key)
        }
    }

    func get<T: Codable>(forKey key: String) -> T? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }

    func remove(forKey key: String) {
        defaults.removeObject(forKey: key)
    }

    func getBool(forKey key: String) -> Bool {
        defaults.bool(forKey: key)
    }

    func setBool(_ value: Bool, forKey key: String) {
        defaults.set(value, forKey: key)
    }
}

enum UserDefaultsKey {
    static let hasCompletedOnboarding = "has_completed_onboarding"
    static let currentUserId = "current_user_id"
    static let fcmToken = "fcm_token"
    static let lastDiscoverRefresh = "last_discover_refresh"
}
