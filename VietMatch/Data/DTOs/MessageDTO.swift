import Foundation

struct MessageDTO: Codable {
    let id: String
    let matchId: String
    let senderId: String
    let content: String
    let type: String
    let createdAt: Double
    let isRead: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case matchId = "match_id"
        case senderId = "sender_id"
        case content, type
        case createdAt = "created_at"
        case isRead = "is_read"
    }

    func toDomain() -> Message {
        Message(
            id: id,
            matchId: matchId,
            senderId: senderId,
            content: content,
            type: MessageType(rawValue: type) ?? .text,
            createdAt: Date(timeIntervalSince1970: createdAt),
            isRead: isRead
        )
    }

    static func from(domain: Message) -> MessageDTO {
        MessageDTO(
            id: domain.id,
            matchId: domain.matchId,
            senderId: domain.senderId,
            content: domain.content,
            type: domain.type.rawValue,
            createdAt: domain.createdAt.timeIntervalSince1970,
            isRead: domain.isRead
        )
    }
}
