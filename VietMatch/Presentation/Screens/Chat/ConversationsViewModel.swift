import Foundation
import Combine

@MainActor
final class ConversationsViewModel: ObservableObject {
    @Published var conversations: [Conversation] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    let currentUserId: String
    private let getConversationsUseCase: GetConversationsUseCaseProtocol
    private var cancellables = Set<AnyCancellable>()

    init(currentUserId: String, getConversationsUseCase: GetConversationsUseCaseProtocol) {
        self.currentUserId = currentUserId
        self.getConversationsUseCase = getConversationsUseCase
    }

    func loadConversations() async {
        isLoading = true
        do {
            conversations = try await getConversationsUseCase.execute(userId: currentUserId)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func observeConversations() {
        getConversationsUseCase.observe(userId: currentUserId)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] conversations in
                self?.conversations = conversations
            }
            .store(in: &cancellables)
    }
}
