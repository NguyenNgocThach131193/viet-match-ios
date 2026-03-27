import SwiftUI
import Combine
import Swinject

final class AppCoordinator: ObservableObject {
    @Published var isAuthenticated = false
    @Published var hasCompletedOnboarding = false

    private let container: Container
    private var cancellables = Set<AnyCancellable>()
    private lazy var authCoordinator = AuthCoordinator(container: container)

    init(container: Container) {
        self.container = container
        observeAuthState()
    }

    private func observeAuthState() {
        guard let authRepo = container.resolve(AuthRepositoryProtocol.self) else { return }
        authRepo.currentUser
            .receive(on: DispatchQueue.main)
            .sink { [weak self] user in
                self?.isAuthenticated = user != nil
                if let user {
                    self?.hasCompletedOnboarding = user.profileCompleted
                }
            }
            .store(in: &cancellables)
    }

    @ViewBuilder
    func start() -> some View {
        if isAuthenticated {
            if hasCompletedOnboarding {
                mainTabView()
            } else {
                onboardingView()
            }
        } else {
            authView()
        }
    }

    func authView() -> some View {
        AuthCoordinatorView(coordinator: authCoordinator)
    }

    func onboardingView() -> some View {
        let viewModel = container.resolve(OnboardingViewModel.self)!
        return OnboardingView(viewModel: viewModel) { [weak self] in
            self?.hasCompletedOnboarding = true
        }
    }

    func mainTabView() -> some View {
        MainTabCoordinator(container: container).start()
    }
}

struct AppCoordinatorView: View {
    @ObservedObject var coordinator: AppCoordinator

    var body: some View {
        coordinator.start()
            .animation(.easeInOut, value: coordinator.isAuthenticated)
    }
}
