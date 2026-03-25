import Foundation

struct UserDTO: Codable {
    let id: String
    let email: String
    let displayName: String
    let profileCompleted: Bool
    let createdAt: Double
    let lastActiveAt: Double

    enum CodingKeys: String, CodingKey {
        case id
        case email
        case displayName = "display_name"
        case profileCompleted = "profile_completed"
        case createdAt = "created_at"
        case lastActiveAt = "last_active_at"
    }

    func toDomain() -> User {
        User(
            id: id,
            email: email,
            displayName: displayName,
            profileCompleted: profileCompleted,
            createdAt: Date(timeIntervalSince1970: createdAt),
            lastActiveAt: Date(timeIntervalSince1970: lastActiveAt)
        )
    }

    static func from(domain: User) -> UserDTO {
        UserDTO(
            id: domain.id,
            email: domain.email,
            displayName: domain.displayName,
            profileCompleted: domain.profileCompleted,
            createdAt: domain.createdAt.timeIntervalSince1970,
            lastActiveAt: domain.lastActiveAt.timeIntervalSince1970
        )
    }
}
