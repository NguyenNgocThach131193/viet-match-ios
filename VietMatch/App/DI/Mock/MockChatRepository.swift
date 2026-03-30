#if UIPREVIEW

import Foundation
import Combine

final class MockChatRepository: ChatRepositoryProtocol {
    func sendMessage(matchId: String, senderId: String, content: String, type: MessageType) async throws -> Message {
        try await Task.sleep(nanoseconds: 200_000_000)
        return Message(
            id: UUID().uuidString,
            matchId: matchId,
            senderId: senderId,
            content: content,
            type: type,
            createdAt: Date()
        )
    }

    func getMessages(matchId: String, limit: Int, before: Date?) async throws -> [Message] {
        try await Task.sleep(nanoseconds: 300_000_000)
        return MockData.messages.filter { $0.matchId == matchId }
    }

    func observeMessages(matchId: String) -> AnyPublisher<[Message], Error> {
        Just(MockData.messages.filter { $0.matchId == matchId })
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    func getConversations(userId: String) async throws -> [Conversation] {
        try await Task.sleep(nanoseconds: 400_000_000)
        return MockData.conversations
    }

    func observeConversations(userId: String) -> AnyPublisher<[Conversation], Error> {
        Just(MockData.conversations)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    func markAsRead(matchId: String, userId: String) async throws {
        // No-op
    }
}

#endif
