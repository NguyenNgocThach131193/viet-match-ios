import SwiftUI
import Swinject

final class MainTabCoordinator: ObservableObject {
    @Published var selectedTab: Tab = .discover

    private let container: Container
    private lazy var discoverCoordinator: DiscoverCoordinator = {
        let coordinator = DiscoverCoordinator(container: container)
        coordinator.navigateToChat = { [weak self] matchId in
            self?.navigateToChat(matchId: matchId)
        }
        return coordinator
    }()
    private lazy var chatCoordinator = ChatCoordinator(container: container)
    private lazy var profileCoordinator = ProfileCoordinator(container: container)

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

    func navigateToChat(matchId: String) {
        selectedTab = .chat
        chatCoordinator.showChat(matchId: matchId)
    }

    func discoverView() -> some View {
        discoverCoordinator.start()
    }

    func matchesView() -> some View {
        let viewModel = container.resolve(MatchesViewModel.self)!
        return MatchesView(viewModel: viewModel, onMatchTap: { [weak self] matchId in
            self?.navigateToChat(matchId: matchId)
        })
    }

    func chatView() -> some View {
        chatCoordinator.start()
    }

    func profileView() -> some View {
        profileCoordinator.start()
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
