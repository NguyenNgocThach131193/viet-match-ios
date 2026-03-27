import Foundation
import FirebaseMessaging
import UserNotifications

protocol FCMServiceProtocol {
    func requestPermission() async throws -> Bool
    func getFCMToken() async throws -> String
    func subscribeTo(topic: String) async throws
    func unsubscribeFrom(topic: String) async throws
}

final class FCMService: NSObject, FCMServiceProtocol {

    func requestPermission() async throws -> Bool {
        let center = UNUserNotificationCenter.current()
        let granted = try await center.requestAuthorization(options: [.alert, .badge, .sound])
        return granted
    }

    func getFCMToken() async throws -> String {
        try await Messaging.messaging().token()
    }

    func subscribeTo(topic: String) async throws {
        try await Messaging.messaging().subscribe(toTopic: topic)
    }

    func unsubscribeFrom(topic: String) async throws {
        try await Messaging.messaging().unsubscribe(fromTopic: topic)
    }
}
