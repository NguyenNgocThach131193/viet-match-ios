import SwiftUI
import Swinject

final class ProfileCoordinator: ObservableObject {
    @Published var path = NavigationPath()

    private let container: Container

    init(container: Container) {
        self.container = container
    }

    func start() -> some View {
        ProfileCoordinatorView(coordinator: self)
    }

    func showEditProfile() {
        path.append(ProfileRoute.editProfile)
    }

    func showSettings() {
        path.append(ProfileRoute.settings)
    }

    func pop() {
        if !path.isEmpty {
            path.removeLast()
        }
    }

    @ViewBuilder
    func destination(for route: ProfileRoute) -> some View {
        switch route {
        case .profile:
            profileView()
        case .editProfile:
            editProfileView()
        case .settings:
            settingsView()
        }
    }

    func profileView() -> some View {
        let viewModel = container.resolve(ProfileViewModel.self)!
        return ProfileView(viewModel: viewModel, coordinator: self)
    }

    func editProfileView() -> some View {
        let viewModel = container.resolve(ProfileViewModel.self)!
        return EditProfileView(viewModel: viewModel)
    }

    func settingsView() -> some View {
        let viewModel = container.resolve(SettingsViewModel.self)!
        return SettingsView(viewModel: viewModel)
    }
}

struct ProfileCoordinatorView: View {
    @ObservedObject var coordinator: ProfileCoordinator

    var body: some View {
        NavigationStack(path: $coordinator.path) {
            coordinator.profileView()
                .navigationDestination(for: ProfileRoute.self) { route in
                    coordinator.destination(for: route)
                }
        }
    }
}
