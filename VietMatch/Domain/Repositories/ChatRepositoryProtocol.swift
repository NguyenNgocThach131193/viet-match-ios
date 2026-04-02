import Foundation
import Combine

protocol ChatRepositoryProtocol {
    func sendMessage(matchId: String, senderId: String, content: String, type: MessageType) async throws -> Message
    func sendImageMessage(matchId: String, senderId: String, imageData: Data) async throws -> Message
    func getMessages(matchId: String, limit: Int, before: Date?) async throws -> [Message]
    func observeMessages(matchId: String) -> AnyPublisher<[Message], Error>
    func getConversations(userId: String) async throws -> [Conversation]
    func observeConversations(userId: String) -> AnyPublisher<[Conversation], Error>
    func markAsRead(matchId: String, userId: String) async throws
}
