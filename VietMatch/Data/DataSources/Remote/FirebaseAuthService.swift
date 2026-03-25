import Foundation
import Combine
import FirebaseAuth

protocol FirebaseAuthServiceProtocol {
    var currentUserPublisher: AnyPublisher<FirebaseAuth.User?, Never> { get }
    var currentUser: FirebaseAuth.User? { get }

    func signIn(email: String, password: String) async throws -> FirebaseAuth.User
    func createUser(email: String, password: String) async throws -> FirebaseAuth.User
    func signInWithGoogle() async throws -> FirebaseAuth.User
    func signInWithApple(idToken: String, nonce: String) async throws -> FirebaseAuth.User
    func signOut() throws
    func resetPassword(email: String) async throws
    func deleteAccount() async throws
}

final class FirebaseAuthService: FirebaseAuthServiceProtocol {
    private let auth = Auth.auth()
    private let userSubject = CurrentValueSubject<FirebaseAuth.User?, Never>(nil)
    private var authStateHandle: AuthStateDidChangeListenerHandle?

    var currentUserPublisher: AnyPublisher<FirebaseAuth.User?, Never> {
        userSubject.eraseToAnyPublisher()
    }

    var currentUser: FirebaseAuth.User? {
        auth.currentUser
    }

    init() {
        authStateHandle = auth.addStateDidChangeListener { [weak self] _, user in
            self?.userSubject.send(user)
        }
    }

    deinit {
        if let handle = authStateHandle {
            auth.removeStateDidChangeListener(handle)
        }
    }

    func signIn(email: String, password: String) async throws -> FirebaseAuth.User {
        let result = try await auth.signIn(withEmail: email, password: password)
        return result.user
    }

    func createUser(email: String, password: String) async throws -> FirebaseAuth.User {
        let result = try await auth.createUser(withEmail: email, password: password)
        return result.user
    }

    func signInWithGoogle() async throws -> FirebaseAuth.User {
        // TODO: Implement Google Sign-In with GoogleSignIn SDK
        throw AuthError.unknown("Google Sign-In chưa được cấu hình")
    }

    func signInWithApple(idToken: String, nonce: String) async throws -> FirebaseAuth.User {
        let credential = OAuthProvider.appleCredential(
            withIDToken: idToken,
            rawNonce: nonce,
            fullName: nil
        )
        let result = try await auth.signIn(with: credential)
        return result.user
    }

    func signOut() throws {
        try auth.signOut()
    }

    func resetPassword(email: String) async throws {
        try await auth.sendPasswordReset(withEmail: email)
    }

    func deleteAccount() async throws {
        guard let user = auth.currentUser else { throw AuthError.userNotFound }
        try await user.delete()
    }
}
