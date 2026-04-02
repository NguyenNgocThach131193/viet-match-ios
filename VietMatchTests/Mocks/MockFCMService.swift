import Foundation
@testable import VietMatch

final class MockFCMService: FCMServiceProtocol {
    var requestPermissionResult: Result<Bool, Error> = .success(true)
    var requestPermissionCallCount = 0

    var getFCMTokenResult: Result<String, Error> = .success("mock-fcm-token-123")
    var getFCMTokenCallCount = 0

    func requestPermission() async throws -> Bool {
        requestPermissionCallCount += 1
        return try requestPermissionResult.get()
    }

    func getFCMToken() async throws -> String {
        getFCMTokenCallCount += 1
        return try getFCMTokenResult.get()
    }

    func subscribeTo(topic: String) async throws {}
    func unsubscribeFrom(topic: String) async throws {}
}
