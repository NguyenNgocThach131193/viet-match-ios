import Foundation
import Combine
@testable import VietMatch

final class MockAuthRepository: AuthRepositoryProtocol {
    var currentUserSubject = CurrentValueSubject<User?, Never>(nil)
    var currentUser: AnyPublisher<User?, Never> {
        currentUserSubject.eraseToAnyPublisher()
    }

    var isAuthenticated: Bool {
        currentUserSubject.value != nil
    }

    var loginResult: Result<User, Error> = .success(User(id: "1", email: "test@test.com", displayName: "Test"))
    var registerResult: Result<User, Error> = .success(User(id: "1", email: "test@test.com", displayName: "Test"))
    var logoutError: Error?
    var resetPasswordError: Error?
    var loginCallCount = 0
    var registerCallCount = 0
    var logoutCallCount = 0
    var resetPasswordCallCount = 0

    func login(email: String, password: String) async throws -> User {
        loginCallCount += 1
        return try loginResult.get()
    }

    func register(email: String, password: String, displayName: String) async throws -> User {
        registerCallCount += 1
        return try registerResult.get()
    }

    func loginWithGoogle() async throws -> User {
        try loginResult.get()
    }

    func loginWithApple(idToken: String, nonce: String) async throws -> User {
        try loginResult.get()
    }

    func logout() async throws {
        logoutCallCount += 1
        if let error = logoutError { throw error }
        currentUserSubject.send(nil)
    }

    func resetPassword(email: String) async throws {
        resetPasswordCallCount += 1
        if let error = resetPasswordError { throw error }
    }

    func deleteAccount() async throws {}
}
