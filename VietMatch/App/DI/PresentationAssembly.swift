import Foundation
import Swinject

final class PresentationAssembly: Assembly {
    func assemble(container: Container) {
        // MARK: - Coordinators

        container.register(AppCoordinator.self) { resolver in
            AppCoordinator(container: resolver as! Container)
        }.inObjectScope(.container)

        // MARK: - Auth ViewModels

        container.register(LoginViewModel.self) { resolver in
            MainActor.assumeIsolated {
                LoginViewModel(
                    loginUseCase: resolver.resolve(LoginUseCaseProtocol.self)!
                )
            }
        }

        container.register(RegisterViewModel.self) { resolver in
            MainActor.assumeIsolated {
                RegisterViewModel(
                    registerUseCase: resolver.resolve(RegisterUseCaseProtocol.self)!
                )
            }
        }

        container.register(ForgotPasswordViewModel.self) { resolver in
            MainActor.assumeIsolated {
                ForgotPasswordViewModel(
                    resetPasswordUseCase: resolver.resolve(ResetPasswordUseCaseProtocol.self)!
                )
            }
        }

        // MARK: - Onboarding ViewModels

        container.register(OnboardingViewModel.self) { resolver in
            MainActor.assumeIsolated {
                OnboardingViewModel(
                    updateProfileUseCase: resolver.resolve(UpdateProfileUseCaseProtocol.self)!,
                    uploadPhotoUseCase: resolver.resolve(UploadPhotoUseCaseProtocol.self)!
                )
            }
        }

        // MARK: - Discover ViewModels

        container.register(DiscoverViewModel.self) { resolver in
            MainActor.assumeIsolated {
                DiscoverViewModel(
                    getDiscoverProfilesUseCase: resolver.resolve(GetDiscoverProfilesUseCaseProtocol.self)!,
                    swipeUseCase: resolver.resolve(SwipeUseCaseProtocol.self)!
                )
            }
        }

        container.register(ProfileDetailViewModel.self) { (resolver, profileId: String) in
            MainActor.assumeIsolated {
                ProfileDetailViewModel(
                    profileId: profileId,
                    currentUserId: "",
                    getProfileUseCase: resolver.resolve(GetProfileUseCaseProtocol.self)!,
                    swipeUseCase: resolver.resolve(SwipeUseCaseProtocol.self)!
                )
            }
        }

        // MARK: - Matches ViewModels

        container.register(MatchesViewModel.self) { resolver in
            MainActor.assumeIsolated {
                MatchesViewModel(
                    getMatchesUseCase: resolver.resolve(GetMatchesUseCaseProtocol.self)!
                )
            }
        }

        // MARK: - Chat ViewModels

        container.register(ConversationsViewModel.self) { resolver in
            MainActor.assumeIsolated {
                ConversationsViewModel(
                    getConversationsUseCase: resolver.resolve(GetConversationsUseCaseProtocol.self)!
                )
            }
        }

        container.register(ChatViewModel.self) { (resolver, matchId: String) in
            MainActor.assumeIsolated {
                ChatViewModel(
                    matchId: matchId,
                    getMessagesUseCase: resolver.resolve(GetMessagesUseCaseProtocol.self)!,
                    sendMessageUseCase: resolver.resolve(SendMessageUseCaseProtocol.self)!
                )
            }
        }

        // MARK: - Profile ViewModels

        container.register(ProfileViewModel.self) { resolver in
            MainActor.assumeIsolated {
                ProfileViewModel(
                    getProfileUseCase: resolver.resolve(GetProfileUseCaseProtocol.self)!,
                    updateProfileUseCase: resolver.resolve(UpdateProfileUseCaseProtocol.self)!,
                    logoutUseCase: resolver.resolve(LogoutUseCaseProtocol.self)!
                )
            }
        }

        // MARK: - Settings ViewModels

        container.register(SettingsViewModel.self) { resolver in
            MainActor.assumeIsolated {
                SettingsViewModel(
                    logoutUseCase: resolver.resolve(LogoutUseCaseProtocol.self)!
                )
            }
        }
    }
}
