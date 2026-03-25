import SwiftUI
import Swinject

final class MainTabCoordinator: ObservableObject {
    @Published var selectedTab: Tab = .discover

    private let container: Container

    enum Tab: Int, CaseIterable {
        case discover
        case matches
        case chat
        case profile

        var title: String {
            switch self {
            case .discover: return "Khám phá"
            case .matches: return "Matches"
            case .chat: return "Chat"
            case .profile: return "Hồ sơ"
            }
        }

        var icon: String {
            switch self {
            case .discover: return "flame.fill"
            case .matches: return "heart.fill"
            case .chat: return "message.fill"
            case .profile: return "person.fill"
            }
        }
    }

    init(container: Container) {
        self.container = container
    }

    func start() -> some View {
        MainTabView(coordinator: self)
    }

    func discoverView() -> some View {
        let coordinator = DiscoverCoordinator(container: container)
        return coordinator.start()
    }

    func matchesView() -> some View {
        let viewModel = container.resolve(MatchesViewModel.self)!
        return MatchesView(viewModel: viewModel)
    }

    func chatView() -> some View {
        let coordinator = ChatCoordinator(container: container)
        return coordinator.start()
    }

    func profileView() -> some View {
        let coordinator = ProfileCoordinator(container: container)
        return coordinator.start()
    }
}

struct MainTabView: View {
    @ObservedObject var coordinator: MainTabCoordinator

    var body: some View {
        TabView(selection: $coordinator.selectedTab) {
            coordinator.discoverView()
                .tabItem {
                    Label(MainTabCoordinator.Tab.discover.title,
                          systemImage: MainTabCoordinator.Tab.discover.icon)
                }
                .tag(MainTabCoordinator.Tab.discover)

            coordinator.matchesView()
                .tabItem {
                    Label(MainTabCoordinator.Tab.matches.title,
                          systemImage: MainTabCoordinator.Tab.matches.icon)
                }
                .tag(MainTabCoordinator.Tab.matches)

            coordinator.chatView()
                .tabItem {
                    Label(MainTabCoordinator.Tab.chat.title,
                          systemImage: MainTabCoordinator.Tab.chat.icon)
                }
                .tag(MainTabCoordinator.Tab.chat)

            coordinator.profileView()
                .tabItem {
                    Label(MainTabCoordinator.Tab.profile.title,
                          systemImage: MainTabCoordinator.Tab.profile.icon)
                }
                .tag(MainTabCoordinator.Tab.profile)
        }
        .tint(VietMatchColors.primary)
    }
}
