import Foundation

struct MatchDTO: Codable {
    let id: String
    let userId: String
    let matchedUserId: String
    let createdAt: Double
    let lastMessageAt: Double?
    let isNew: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case matchedUserId = "matched_user_id"
        case createdAt = "created_at"
        case lastMessageAt = "last_message_at"
        case isNew = "is_new"
    }

    func toDomain(matchedProfile: Profile? = nil) -> Match {
        Match(
            id: id,
            userId: userId,
            matchedUserId: matchedUserId,
            matchedProfile: matchedProfile,
            createdAt: Date(timeIntervalSince1970: createdAt),
            lastMessageAt: lastMessageAt.map { Date(timeIntervalSince1970: $0) },
            isNew: isNew
        )
    }

    static func from(domain: Match) -> MatchDTO {
        MatchDTO(
            id: domain.id,
            userId: domain.userId,
            matchedUserId: domain.matchedUserId,
            createdAt: domain.createdAt.timeIntervalSince1970,
            lastMessageAt: domain.lastMessageAt?.timeIntervalSince1970,
            isNew: domain.isNew
        )
    }
}
