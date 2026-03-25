import Foundation
import Swinject

final class DataAssembly: Assembly {
    func assemble(container: Container) {
        // MARK: - Data Sources

        container.register(FirebaseAuthServiceProtocol.self) { _ in
            FirebaseAuthService()
        }.inObjectScope(.container)

        container.register(FirestoreServiceProtocol.self) { _ in
            FirestoreService()
        }.inObjectScope(.container)

        container.register(FirebaseStorageServiceProtocol.self) { _ in
            FirebaseStorageService()
        }.inObjectScope(.container)

        container.register(FCMServiceProtocol.self) { _ in
            FCMService()
        }.inObjectScope(.container)

        container.register(UserDefaultsServiceProtocol.self) { _ in
            UserDefaultsService()
        }.inObjectScope(.container)

        // MARK: - Repositories

        container.register(AuthRepositoryProtocol.self) { resolver in
            AuthRepository(
                authService: resolver.resolve(FirebaseAuthServiceProtocol.self)!,
                firestoreService: resolver.resolve(FirestoreServiceProtocol.self)!,
                userDefaultsService: resolver.resolve(UserDefaultsServiceProtocol.self)!
            )
        }.inObjectScope(.container)

        container.register(ProfileRepositoryProtocol.self) { resolver in
            ProfileRepository(
                firestoreService: resolver.resolve(FirestoreServiceProtocol.self)!,
                storageService: resolver.resolve(FirebaseStorageServiceProtocol.self)!
            )
        }.inObjectScope(.container)

        container.register(MatchRepositoryProtocol.self) { resolver in
            MatchRepository(
                firestoreService: resolver.resolve(FirestoreServiceProtocol.self)!
            )
        }.inObjectScope(.container)

        container.register(ChatRepositoryProtocol.self) { resolver in
            ChatRepository(
                firestoreService: resolver.resolve(FirestoreServiceProtocol.self)!
            )
        }.inObjectScope(.container)
    }
}
