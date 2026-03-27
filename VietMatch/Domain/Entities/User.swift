import Foundation

struct User: Identifiable, Codable, Equatable {
    let id: String
    var email: String
    var displayName: String
    var profileCompleted: Bool
    var createdAt: Date
    var lastActiveAt: Date

    init(
        id: String,
        email: String,
        displayName: String = "",
        profileCompleted: Bool = false,
        createdAt: Date = Date(),
        lastActiveAt: Date = Date()
    ) {
        self.id = id
        self.email = email
        self.displayName = displayName
        self.profileCompleted = profileCompleted
        self.createdAt = createdAt
        self.lastActiveAt = lastActiveAt
    }
}
