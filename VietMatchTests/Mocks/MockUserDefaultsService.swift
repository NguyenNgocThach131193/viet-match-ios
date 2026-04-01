import Foundation
@testable import VietMatch

final class MockUserDefaultsService: UserDefaultsServiceProtocol {
    var storage: [String: Any] = [:]
    var setCallCount = 0
    var lastSetKey: String?
    var lastSetValue: Any?
    var removeCallCount = 0
    var lastRemoveKey: String?

    func set<T: Codable>(_ value: T, forKey key: String) {
        setCallCount += 1
        lastSetKey = key
        lastSetValue = value
        storage[key] = value
    }

    func get<T: Codable>(forKey key: String) -> T? {
        storage[key] as? T
    }

    func remove(forKey key: String) {
        removeCallCount += 1
        lastRemoveKey = key
        storage.removeValue(forKey: key)
    }

    func getBool(forKey key: String) -> Bool {
        storage[key] as? Bool ?? false
    }

    func setBool(_ value: Bool, forKey key: String) {
        storage[key] = value
    }
}
