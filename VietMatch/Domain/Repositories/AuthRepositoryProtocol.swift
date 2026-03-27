import Foundation
import Combine

protocol AuthRepositoryProtocol {
    var currentUser: AnyPublisher<User?, Never> { get }
    var isAuthenticated: Bool { get }

    func login(email: String, password: String) async throws -> User
    func register(email: String, password: String, displayName: String) async throws -> User
    func loginWithGoogle() async throws -> User
    func loginWithApple(idToken: String, nonce: String) async throws -> User
    func logout() async throws
    func resetPassword(email: String) async throws
    func deleteAccount() async throws
}
