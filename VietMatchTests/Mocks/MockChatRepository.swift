import Foundation
import Combine
@testable import VietMatch

final class TestMockChatRepository: ChatRepositoryProtocol {
    var getConversationsResult: Result<[Conversation], Error> = .success([])
    var lastGetConversationsUserId: String?
    var getConversationsCallCount = 0

    func sendMessage(matchId: String, senderId: String, content: String, type: MessageType) async throws -> Message {
        Message(id: "msg-1", matchId: matchId, senderId: senderId, content: content, type: type, createdAt: Date())
    }

    func getMessages(matchId: String, limit: Int, before: Date?) async throws -> [Message] { [] }

    func observeMessages(matchId: String) -> AnyPublisher<[Message], Error> {
        Empty().eraseToAnyPublisher()
    }

    func getConversations(userId: String) async throws -> [Conversation] {
        getConversationsCallCount += 1
        lastGetConversationsUserId = userId
        return try getConversationsResult.get()
    }

    func observeConversations(userId: String) -> AnyPublisher<[Conversation], Error> {
        Just([]).setFailureType(to: Error.self).eraseToAnyPublisher()
    }

    func markAsRead(matchId: String, userId: String) async throws {}
}
