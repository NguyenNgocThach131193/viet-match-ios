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
                let userDefaultsService = resolver.resolve(UserDefaultsServiceProtocol.self)!
                let currentUserId: String = userDefaultsService.get(forKey: UserDefaultsKey.currentUserId) ?? ""
                return DiscoverViewModel(
                    currentUserId: currentUserId,
                    getDiscoverProfilesUseCase: resolver.resolve(GetDiscoverProfilesUseCaseProtocol.self)!,
                    swipeUseCase: resolver.resolve(SwipeUseCaseProtocol.self)!
                )
            }
        }

        container.register(ProfileDetailViewModel.self) { (resolver, profileId: String) in
            MainActor.assumeIsolated {
                let userDefaultsService = resolver.resolve(UserDefaultsServiceProtocol.self)!
                let currentUserId: String = userDefaultsService.get(forKey: UserDefaultsKey.currentUserId) ?? ""
                return ProfileDetailViewModel(
                    profileId: profileId,
                    currentUserId: currentUserId,
                    getProfileUseCase: resolver.resolve(GetProfileUseCaseProtocol.self)!,
                    swipeUseCase: resolver.resolve(SwipeUseCaseProtocol.self)!
                )
            }
        }

        // MARK: - Matches ViewModels

        container.register(MatchesViewModel.self) { resolver in
            MainActor.assumeIsolated {
                let userDefaultsService = resolver.resolve(UserDefaultsServiceProtocol.self)!
                let currentUserId: String = userDefaultsService.get(forKey: UserDefaultsKey.currentUserId) ?? ""
                return MatchesViewModel(
                    currentUserId: currentUserId,
                    getMatchesUseCase: resolver.resolve(GetMatchesUseCaseProtocol.self)!
                )
            }
        }

        // MARK: - Chat ViewModels

        container.register(ConversationsViewModel.self) { resolver in
            MainActor.assumeIsolated {
                let userDefaultsService = resolver.resolve(UserDefaultsServiceProtocol.self)!
                let currentUserId: String = userDefaultsService.get(forKey: UserDefaultsKey.currentUserId) ?? ""
                return ConversationsViewModel(
                    currentUserId: currentUserId,
                    getConversationsUseCase: resolver.resolve(GetConversationsUseCaseProtocol.self)!
                )
            }
        }

        container.register(ChatViewModel.self) { (resolver, matchId: String) in
            MainActor.assumeIsolated {
                let userDefaultsService = resolver.resolve(UserDefaultsServiceProtocol.self)!
                let currentUserId: String = userDefaultsService.get(forKey: UserDefaultsKey.currentUserId) ?? ""
                return ChatViewModel(
                    matchId: matchId,
                    currentUserId: currentUserId,
                    getMessagesUseCase: resolver.resolve(GetMessagesUseCaseProtocol.self)!,
                    sendMessageUseCase: resolver.resolve(SendMessageUseCaseProtocol.self)!
                )
            }
        }

        // MARK: - Profile ViewModels

        container.register(ProfileViewModel.self) { resolver in
            MainActor.assumeIsolated {
                let userDefaultsService = resolver.resolve(UserDefaultsServiceProtocol.self)!
                let currentUserId: String = userDefaultsService.get(forKey: UserDefaultsKey.currentUserId) ?? ""
                return ProfileViewModel(
                    currentUserId: currentUserId,
                    getProfileUseCase: resolver.resolve(GetProfileUseCaseProtocol.self)!,
                    updateProfileUseCase: resolver.resolve(UpdateProfileUseCaseProtocol.self)!,
                    logoutUseCase: resolver.resolve(LogoutUseCaseProtocol.self)!,
                    uploadPhotoUseCase: resolver.resolve(UploadPhotoUseCaseProtocol.self)!,
                    deletePhotoUseCase: resolver.resolve(DeletePhotoUseCaseProtocol.self)!
                )
            }
        }

        // MARK: - Settings ViewModels

        container.register(SettingsViewModel.self) { resolver in
            MainActor.assumeIsolated {
                let userDefaultsService = resolver.resolve(UserDefaultsServiceProtocol.self)!
                let currentUserId: String = userDefaultsService.get(forKey: UserDefaultsKey.currentUserId) ?? ""
                return SettingsViewModel(
                    currentUserId: currentUserId,
                    logoutUseCase: resolver.resolve(LogoutUseCaseProtocol.self)!,
                    deleteAccountUseCase: resolver.resolve(DeleteAccountUseCaseProtocol.self)!,
                    getProfileUseCase: resolver.resolve(GetProfileUseCaseProtocol.self)!,
                    updateProfileUseCase: resolver.resolve(UpdateProfileUseCaseProtocol.self)!,
                    fcmService: resolver.resolve(FCMServiceProtocol.self)!,
                    firestoreService: resolver.resolve(FirestoreServiceProtocol.self)!
                )
            }
        }
    }
}
