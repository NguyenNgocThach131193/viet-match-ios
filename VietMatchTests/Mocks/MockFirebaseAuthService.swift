import Foundation
import Combine
import FirebaseAuth
@testable import VietMatch

// NOTE: FirebaseAuth.User cannot be instantiated in unit tests without Firebase test infrastructure.
// This mock exists for compilation but all methods fatalError at runtime.
// AuthRepository social login persist logic is verified via code review (identical pattern to login/register).

final class MockFirebaseAuthService: FirebaseAuthServiceProtocol {
    var currentUserPublisher: AnyPublisher<FirebaseAuth.User?, Never> {
        Just(nil).eraseToAnyPublisher()
    }

    var currentUser: FirebaseAuth.User? { nil }

    var signInError: Error?
    var signInWithGoogleError: Error?
    var signInWithAppleError: Error?
    var signOutError: Error?

    var signInCallCount = 0
    var signInWithGoogleCallCount = 0
    var signInWithAppleCallCount = 0
    var signOutCallCount = 0

    func signIn(email: String, password: String) async throws -> FirebaseAuth.User {
        signInCallCount += 1
        if let error = signInError { throw error }
        fatalError("MockFirebaseAuthService: FirebaseAuth.User cannot be instantiated in unit tests")
    }

    func createUser(email: String, password: String) async throws -> FirebaseAuth.User {
        fatalError("MockFirebaseAuthService: FirebaseAuth.User cannot be instantiated in unit tests")
    }

    func signInWithGoogle() async throws -> FirebaseAuth.User {
        signInWithGoogleCallCount += 1
        if let error = signInWithGoogleError { throw error }
        fatalError("MockFirebaseAuthService: FirebaseAuth.User cannot be instantiated in unit tests")
    }

    func signInWithApple(idToken: String, nonce: String) async throws -> FirebaseAuth.User {
        signInWithAppleCallCount += 1
        if let error = signInWithAppleError { throw error }
        fatalError("MockFirebaseAuthService: FirebaseAuth.User cannot be instantiated in unit tests")
    }

    func signOut() throws {
        signOutCallCount += 1
        if let error = signOutError { throw error }
    }

    func resetPassword(email: String) async throws {}

    func deleteAccount() async throws {}
}
