import Foundation
import Combine

@MainActor
final class ConversationsViewModel: ObservableObject {
    @Published var conversations: [Conversation] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let getConversationsUseCase: GetConversationsUseCaseProtocol
    private var cancellables = Set<AnyCancellable>()

    init(getConversationsUseCase: GetConversationsUseCaseProtocol) {
        self.getConversationsUseCase = getConversationsUseCase
    }

    func loadConversations(userId: String) async {
        isLoading = true
        do {
            conversations = try await getConversationsUseCase.execute(userId: userId)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func observeConversations(userId: String) {
        getConversationsUseCase.observe(userId: userId)
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
