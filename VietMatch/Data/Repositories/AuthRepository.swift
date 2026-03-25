import Foundation
import Combine

final class AuthRepository: AuthRepositoryProtocol {
    private let authService: FirebaseAuthServiceProtocol
    private let firestoreService: FirestoreServiceProtocol
    private let userDefaultsService: UserDefaultsServiceProtocol

    var currentUser: AnyPublisher<User?, Never> {
        authService.currentUserPublisher
            .map { firebaseUser -> User? in
                guard let firebaseUser else { return nil }
                return User(
                    id: firebaseUser.uid,
                    email: firebaseUser.email ?? "",
                    displayName: firebaseUser.displayName ?? ""
                )
            }
            .eraseToAnyPublisher()
    }

    var isAuthenticated: Bool {
        authService.currentUser != nil
    }

    init(
        authService: FirebaseAuthServiceProtocol,
        firestoreService: FirestoreServiceProtocol,
        userDefaultsService: UserDefaultsServiceProtocol
    ) {
        self.authService = authService
        self.firestoreService = firestoreService
        self.userDefaultsService = userDefaultsService
    }

    func login(email: String, password: String) async throws -> User {
        let firebaseUser = try await authService.signIn(email: email, password: password)
        let userDTO: UserDTO = try await firestoreService.getDocument(
            collection: "users",
            documentId: firebaseUser.uid
        )
        let user = userDTO.toDomain()
        userDefaultsService.set(user.id, forKey: UserDefaultsKey.currentUserId)
        return user
    }

    func register(email: String, password: String, displayName: String) async throws -> User {
        let firebaseUser = try await authService.createUser(email: email, password: password)
        let user = User(
            id: firebaseUser.uid,
            email: email,
            displayName: displayName
        )
        let userDTO = UserDTO.from(domain: user)
        try await firestoreService.setDocument(
            collection: "users",
            documentId: firebaseUser.uid,
            data: userDTO
        )
        userDefaultsService.set(user.id, forKey: UserDefaultsKey.currentUserId)
        return user
    }

    func loginWithGoogle() async throws -> User {
        let firebaseUser = try await authService.signInWithGoogle()
        return User(
            id: firebaseUser.uid,
            email: firebaseUser.email ?? "",
            displayName: firebaseUser.displayName ?? ""
        )
    }

    func loginWithApple(idToken: String, nonce: String) async throws -> User {
        let firebaseUser = try await authService.signInWithApple(idToken: idToken, nonce: nonce)
        return User(
            id: firebaseUser.uid,
            email: firebaseUser.email ?? "",
            displayName: firebaseUser.displayName ?? ""
        )
    }

    func logout() async throws {
        try authService.signOut()
        userDefaultsService.remove(forKey: UserDefaultsKey.currentUserId)
    }

    func resetPassword(email: String) async throws {
        try await authService.resetPassword(email: email)
    }

    func deleteAccount() async throws {
        if let userId = authService.currentUser?.uid {
            try await firestoreService.deleteDocument(collection: "users", documentId: userId)
        }
        try await authService.deleteAccount()
        userDefaultsService.remove(forKey: UserDefaultsKey.currentUserId)
    }
}
