import Foundation

struct AppNotification: Identifiable, Codable, Equatable {
    let id: String
    let userId: String
    let type: NotificationType
    let title: String
    let body: String
    let data: [String: String]?
    let createdAt: Date
    var isRead: Bool

    init(
        id: String = UUID().uuidString,
        userId: String,
        type: NotificationType,
        title: String,
        body: String,
        data: [String: String]? = nil,
        createdAt: Date = Date(),
        isRead: Bool = false
    ) {
        self.id = id
        self.userId = userId
        self.type = type
        self.title = title
        self.body = body
        self.data = data
        self.createdAt = createdAt
        self.isRead = isRead
    }
}

enum NotificationType: String, Codable {
    case newMatch
    case newMessage
    case superLike
    case profileView
}
