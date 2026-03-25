import Foundation

struct Match: Identifiable, Codable, Equatable {
    let id: String
    let userId: String
    let matchedUserId: String
    let matchedProfile: Profile?
    let createdAt: Date
    var lastMessageAt: Date?
    var isNew: Bool

    init(
        id: String,
        userId: String,
        matchedUserId: String,
        matchedProfile: Profile? = nil,
        createdAt: Date = Date(),
        lastMessageAt: Date? = nil,
        isNew: Bool = true
    ) {
        self.id = id
        self.userId = userId
        self.matchedUserId = matchedUserId
        self.matchedProfile = matchedProfile
        self.createdAt = createdAt
        self.lastMessageAt = lastMessageAt
        self.isNew = isNew
    }
}
