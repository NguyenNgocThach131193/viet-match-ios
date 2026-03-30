#if UIPREVIEW

import Foundation
import Swinject

final class MockDataAssembly: Assembly {
    func assemble(container: Container) {
        // MARK: - UserDefaults (real implementation, seeded with mock user)

        container.register(UserDefaultsServiceProtocol.self) { _ in
            let service = UserDefaultsService()
            service.set(MockData.currentUserId, forKey: UserDefaultsKey.currentUserId)
            service.setBool(true, forKey: UserDefaultsKey.hasCompletedOnboarding)
            return service
        }.inObjectScope(.container)

        // MARK: - Mock Repositories

        container.register(AuthRepositoryProtocol.self) { _ in
            MockAuthRepository()
        }.inObjectScope(.container)

        container.register(ProfileRepositoryProtocol.self) { _ in
            MockProfileRepository()
        }.inObjectScope(.container)

        container.register(MatchRepositoryProtocol.self) { _ in
            MockMatchRepository()
        }.inObjectScope(.container)

        container.register(ChatRepositoryProtocol.self) { _ in
            MockChatRepository()
        }.inObjectScope(.container)
    }
}

#endif
