import Foundation
import Combine

final class ChatRepository: ChatRepositoryProtocol {
    private let firestoreService: FirestoreServiceProtocol

    init(firestoreService: FirestoreServiceProtocol) {
        self.firestoreService = firestoreService
    }

    func sendMessage(matchId: String, senderId: String, content: String, type: MessageType) async throws -> Message {
        let message = Message(
            id: UUID().uuidString,
            matchId: matchId,
            senderId: senderId,
            content: content,
            type: type
        )
        let dto = MessageDTO.from(domain: message)
        try await firestoreService.setDocument(
            collection: "matches/\(matchId)/messages",
            documentId: message.id,
            data: dto
        )
        try await firestoreService.updateDocument(
            collection: "matches",
            documentId: matchId,
            fields: ["last_message_at": message.createdAt.timeIntervalSince1970]
        )
        return message
    }

    func getMessages(matchId: String, limit: Int, before: Date?) async throws -> [Message] {
        var filters: [FirestoreFilter] = []
        if let before {
            filters.append(
                FirestoreFilter(field: "created_at", op: .isLessThan, value: before.timeIntervalSince1970)
            )
        }
        let dtos: [MessageDTO] = try await firestoreService.getDocuments(
            collection: "matches/\(matchId)/messages",
            filters: filters,
            limit: limit
        )
        return dtos.map { $0.toDomain() }.sorted { $0.createdAt < $1.createdAt }
    }

    func observeMessages(matchId: String) -> AnyPublisher<[Message], Error> {
        firestoreService.observeCollection(
            collection: "matches/\(matchId)/messages",
            filters: []
        )
        .map { (dtos: [MessageDTO]) in
            dtos.map { $0.toDomain() }.sorted { $0.createdAt < $1.createdAt }
        }
        .eraseToAnyPublisher()
    }

    func getConversations(userId: String) async throws -> [Conversation] {
        let matchDTOs: [MatchDTO] = try await firestoreService.getDocuments(
            collection: "matches",
            filters: [
                FirestoreFilter(field: "user_id", op: .isEqualTo, value: userId)
            ],
            limit: nil
        )

        var conversations: [Conversation] = []
        for dto in matchDTOs {
            let match = dto.toDomain()
            let messages: [MessageDTO] = try await firestoreService.getDocuments(
                collection: "matches/\(match.id)/messages",
                filters: [],
                limit: 1
            )
            let lastMessage = messages.first?.toDomain()
            conversations.append(
                Conversation(
                    id: match.id,
                    match: match,
                    lastMessage: lastMessage,
                    unreadCount: 0
                )
            )
        }

        return conversations.sorted {
            ($0.lastMessage?.createdAt ?? $0.match.createdAt) > ($1.lastMessage?.createdAt ?? $1.match.createdAt)
        }
    }

    func observeConversations(userId: String) -> AnyPublisher<[Conversation], Error> {
        firestoreService.observeCollection(
            collection: "matches",
            filters: [
                FirestoreFilter(field: "user_id", op: .isEqualTo, value: userId)
            ]
        )
        .map { (dtos: [MatchDTO]) in
            dtos.map { dto in
                Conversation(
                    id: dto.id,
                    match: dto.toDomain(),
                    lastMessage: nil,
                    unreadCount: 0
                )
            }
        }
        .eraseToAnyPublisher()
    }

    func markAsRead(matchId: String, userId: String) async throws {
        // Mark all unread messages in this match as read
        let messages: [MessageDTO] = try await firestoreService.getDocuments(
            collection: "matches/\(matchId)/messages",
            filters: [
                FirestoreFilter(field: "is_read", op: .isEqualTo, value: false)
            ],
            limit: nil
        )

        for message in messages where message.senderId != userId {
            try await firestoreService.updateDocument(
                collection: "matches/\(matchId)/messages",
                documentId: message.id,
                fields: ["is_read": true]
            )
        }
    }
}
