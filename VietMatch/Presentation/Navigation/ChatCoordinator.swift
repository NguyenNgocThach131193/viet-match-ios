import SwiftUI
import Swinject

final class ChatCoordinator: ObservableObject {
    @Published var path = NavigationPath()

    private let container: Container

    init(container: Container) {
        self.container = container
    }

    func start() -> some View {
        ChatCoordinatorView(coordinator: self)
    }

    func showChat(matchId: String) {
        path.append(ChatRoute.chat(matchId: matchId))
    }

    func pop() {
        if !path.isEmpty {
            path.removeLast()
        }
    }

    @ViewBuilder
    func destination(for route: ChatRoute) -> some View {
        switch route {
        case .conversations:
            conversationsView()
        case .chat(let matchId):
            chatView(matchId: matchId)
        }
    }

    func conversationsView() -> some View {
        let viewModel = container.resolve(ConversationsViewModel.self)!
        return ConversationsView(viewModel: viewModel, coordinator: self)
    }

    func chatView(matchId: String) -> some View {
        let viewModel = container.resolve(ChatViewModel.self, argument: matchId)!
        return ChatView(viewModel: viewModel)
    }
}

struct ChatCoordinatorView: View {
    @ObservedObject var coordinator: ChatCoordinator

    var body: some View {
        NavigationStack(path: $coordinator.path) {
            coordinator.conversationsView()
                .navigationDestination(for: ChatRoute.self) { route in
                    coordinator.destination(for: route)
                }
        }
    }
}
