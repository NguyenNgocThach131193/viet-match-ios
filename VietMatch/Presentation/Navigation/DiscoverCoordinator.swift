import SwiftUI
import Swinject

final class DiscoverCoordinator: Coordinator {
    @Published var path = NavigationPath()

    private let container: Container
    var navigateToChat: ((String) -> Void)?

    init(container: Container) {
        self.container = container
    }

    func start() -> some View {
        DiscoverCoordinatorView(coordinator: self)
    }

    func showProfileDetail(profileId: String) {
        path.append(DiscoverRoute.profileDetail(profileId: profileId))
    }

    func showChat(matchId: String) {
        navigateToChat?(matchId)
    }

    @ViewBuilder
    func destination(for route: DiscoverRoute) -> some View {
        switch route {
        case .discover:
            discoverView()
        case .profileDetail(let profileId):
            profileDetailView(profileId: profileId)
        }
    }

    func discoverView() -> some View {
        let viewModel = container.resolve(DiscoverViewModel.self)!
        return DiscoverView(viewModel: viewModel, coordinator: self)
    }

    func profileDetailView(profileId: String) -> some View {
        let viewModel = container.resolve(ProfileDetailViewModel.self, argument: profileId)!
        return ProfileDetailView(viewModel: viewModel, coordinator: self)
    }
}

struct DiscoverCoordinatorView: View {
    @ObservedObject var coordinator: DiscoverCoordinator

    var body: some View {
        NavigationStack(path: $coordinator.path) {
            coordinator.discoverView()
                .navigationDestination(for: DiscoverRoute.self) { route in
                    coordinator.destination(for: route)
                }
        }
    }
}
