import Foundation

struct Message: Identifiable, Codable, Equatable {
    let id: String
    let matchId: String
    let senderId: String
    let content: String
    let type: MessageType
    let createdAt: Date
    var isRead: Bool

    init(
        id: String,
        matchId: String,
        senderId: String,
        content: String,
        type: MessageType = .text,
        createdAt: Date = Date(),
        isRead: Bool = false
    ) {
        self.id = id
        self.matchId = matchId
        self.senderId = senderId
        self.content = content
        self.type = type
        self.createdAt = createdAt
        self.isRead = isRead
    }
}

enum MessageType: String, Codable {
    case text
    case image
    case gif
}

struct Conversation: Identifiable, Equatable {
    let id: String
    let match: Match
    let lastMessage: Message?
    var unreadCount: Int
}
