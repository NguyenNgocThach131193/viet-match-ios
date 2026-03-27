import SwiftUI
import Swinject

final class DiscoverCoordinator: Coordinator {
    @Published var path = NavigationPath()

    private let container: Container

    init(container: Container) {
        self.container = container
    }

    func start() -> some View {
        DiscoverCoordinatorView(coordinator: self)
    }

    func showProfileDetail(profileId: String) {
        path.append(DiscoverRoute.profileDetail(profileId: profileId))
    }

    @ViewBuilder
    func destination(for route: DiscoverRoute) -> some View {
        switch route {
        case .discover:
            discoverView()
        case .profileDetail:
            Text("Profile Detail") // TODO: Implement ProfileDetailView
        }
    }

    func discoverView() -> some View {
        let viewModel = container.resolve(DiscoverViewModel.self)!
        return DiscoverView(viewModel: viewModel, coordinator: self)
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
