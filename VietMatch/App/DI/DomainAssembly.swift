import Foundation
import Swinject

final class DomainAssembly: Assembly {
    func assemble(container: Container) {
        // MARK: - Auth Use Cases

        container.register(LoginUseCaseProtocol.self) { resolver in
            LoginUseCase(
                authRepository: resolver.resolve(AuthRepositoryProtocol.self)!
            )
        }

        container.register(RegisterUseCaseProtocol.self) { resolver in
            RegisterUseCase(
                authRepository: resolver.resolve(AuthRepositoryProtocol.self)!
            )
        }

        container.register(LogoutUseCaseProtocol.self) { resolver in
            LogoutUseCase(
                authRepository: resolver.resolve(AuthRepositoryProtocol.self)!
            )
        }

        container.register(ResetPasswordUseCaseProtocol.self) { resolver in
            ResetPasswordUseCase(
                authRepository: resolver.resolve(AuthRepositoryProtocol.self)!
            )
        }

        // MARK: - Profile Use Cases

        container.register(GetProfileUseCaseProtocol.self) { resolver in
            GetProfileUseCase(
                profileRepository: resolver.resolve(ProfileRepositoryProtocol.self)!
            )
        }

        container.register(UpdateProfileUseCaseProtocol.self) { resolver in
            UpdateProfileUseCase(
                profileRepository: resolver.resolve(ProfileRepositoryProtocol.self)!
            )
        }

        container.register(UploadPhotoUseCaseProtocol.self) { resolver in
            UploadPhotoUseCase(
                profileRepository: resolver.resolve(ProfileRepositoryProtocol.self)!
            )
        }

        container.register(DeletePhotoUseCaseProtocol.self) { resolver in
            DeletePhotoUseCase(
                profileRepository: resolver.resolve(ProfileRepositoryProtocol.self)!
            )
        }

        // MARK: - Matching Use Cases

        container.register(SwipeUseCaseProtocol.self) { resolver in
            SwipeUseCase(
                matchRepository: resolver.resolve(MatchRepositoryProtocol.self)!
            )
        }

        container.register(GetDiscoverProfilesUseCaseProtocol.self) { resolver in
            GetDiscoverProfilesUseCase(
                matchRepository: resolver.resolve(MatchRepositoryProtocol.self)!
            )
        }

        container.register(GetMatchesUseCaseProtocol.self) { resolver in
            GetMatchesUseCase(
                matchRepository: resolver.resolve(MatchRepositoryProtocol.self)!
            )
        }

        // MARK: - Chat Use Cases

        container.register(SendMessageUseCaseProtocol.self) { resolver in
            SendMessageUseCase(
                chatRepository: resolver.resolve(ChatRepositoryProtocol.self)!
            )
        }

        container.register(GetMessagesUseCaseProtocol.self) { resolver in
            GetMessagesUseCase(
                chatRepository: resolver.resolve(ChatRepositoryProtocol.self)!
            )
        }

        container.register(GetConversationsUseCaseProtocol.self) { resolver in
            GetConversationsUseCase(
                chatRepository: resolver.resolve(ChatRepositoryProtocol.self)!
            )
        }
    }
}
