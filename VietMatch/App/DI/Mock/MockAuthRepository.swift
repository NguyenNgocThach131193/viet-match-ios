#if UIPREVIEW

import Foundation
import Combine

final class MockAuthRepository: AuthRepositoryProtocol {
    private let currentUserSubject = CurrentValueSubject<User?, Never>(MockData.currentUser)

    var currentUser: AnyPublisher<User?, Never> {
        currentUserSubject.eraseToAnyPublisher()
    }

    var isAuthenticated: Bool { currentUserSubject.value != nil }

    func login(email: String, password: String) async throws -> User {
        try await Task.sleep(nanoseconds: 500_000_000)
        let user = MockData.currentUser
        currentUserSubject.send(user)
        return user
    }

    func register(email: String, password: String, displayName: String) async throws -> User {
        try await Task.sleep(nanoseconds: 500_000_000)
        let user = MockData.currentUser
        currentUserSubject.send(user)
        return user
    }

    func loginWithGoogle() async throws -> User {
        try await Task.sleep(nanoseconds: 500_000_000)
        let user = MockData.currentUser
        currentUserSubject.send(user)
        return user
    }

    func loginWithApple(idToken: String, nonce: String) async throws -> User {
        try await Task.sleep(nanoseconds: 500_000_000)
        let user = MockData.currentUser
        currentUserSubject.send(user)
        return user
    }

    func logout() async throws {
        currentUserSubject.send(nil)
    }

    func resetPassword(email: String) async throws {
        try await Task.sleep(nanoseconds: 300_000_000)
    }

    func deleteAccount() async throws {
        currentUserSubject.send(nil)
    }
}

#endif
