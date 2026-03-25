import Foundation

struct Swipe: Codable, Equatable {
    let id: String
    let swiperId: String
    let swipedUserId: String
    let direction: SwipeDirection
    let createdAt: Date

    init(
        id: String = UUID().uuidString,
        swiperId: String,
        swipedUserId: String,
        direction: SwipeDirection,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.swiperId = swiperId
        self.swipedUserId = swipedUserId
        self.direction = direction
        self.createdAt = createdAt
    }
}

enum SwipeDirection: String, Codable {
    case like
    case dislike
    case superLike
}
