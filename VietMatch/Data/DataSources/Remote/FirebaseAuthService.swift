import Foundation
import Combine
import FirebaseAuth
import GoogleSignIn
import UIKit

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
        let rootViewController = try await MainActor.run {
            guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let rootVC = scene.keyWindow?.rootViewController else {
                throw AuthError.unknown("Không tìm được rootViewController")
            }
            return rootVC
        }

        let signInResult: GIDSignInResult
        do {
            signInResult = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
        } catch let error as NSError where error.domain == kGIDSignInErrorDomain
                    && GIDSignInError.Code(rawValue: error.code) == .canceled {
            throw AuthError.cancelled
        }

        guard let idToken = signInResult.user.idToken?.tokenString else {
            throw AuthError.unknown("Google idToken không hợp lệ")
        }
        let accessToken = signInResult.user.accessToken.tokenString

        let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
        let result = try await auth.signIn(with: credential)
        return result.user
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
