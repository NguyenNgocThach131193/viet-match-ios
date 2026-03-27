import Foundation
import Combine

protocol GetConversationsUseCaseProtocol {
    func execute(userId: String) async throws -> [Conversation]
    func observe(userId: String) -> AnyPublisher<[Conversation], Error>
}

final class GetConversationsUseCase: GetConversationsUseCaseProtocol {
    private let chatRepository: ChatRepositoryProtocol

    init(chatRepository: ChatRepositoryProtocol) {
        self.chatRepository = chatRepository
    }

    func execute(userId: String) async throws -> [Conversation] {
        try await chatRepository.getConversations(userId: userId)
    }

    func observe(userId: String) -> AnyPublisher<[Conversation], Error> {
        chatRepository.observeConversations(userId: userId)
    }
}
