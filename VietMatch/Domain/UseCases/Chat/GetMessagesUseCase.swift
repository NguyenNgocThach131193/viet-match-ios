import Foundation
import Combine

protocol GetMessagesUseCaseProtocol {
    func execute(matchId: String, limit: Int, before: Date?) async throws -> [Message]
    func observe(matchId: String) -> AnyPublisher<[Message], Error>
}

final class GetMessagesUseCase: GetMessagesUseCaseProtocol {
    private let chatRepository: ChatRepositoryProtocol

    init(chatRepository: ChatRepositoryProtocol) {
        self.chatRepository = chatRepository
    }

    func execute(matchId: String, limit: Int = 50, before: Date? = nil) async throws -> [Message] {
        try await chatRepository.getMessages(matchId: matchId, limit: limit, before: before)
    }

    func observe(matchId: String) -> AnyPublisher<[Message], Error> {
        chatRepository.observeMessages(matchId: matchId)
    }
}
