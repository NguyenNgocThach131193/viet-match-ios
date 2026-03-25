import Foundation
import Combine

final class MatchRepository: MatchRepositoryProtocol {
    private let firestoreService: FirestoreServiceProtocol

    init(firestoreService: FirestoreServiceProtocol) {
        self.firestoreService = firestoreService
    }

    func swipe(swiperId: String, swipedUserId: String, direction: SwipeDirection) async throws -> Match? {
        let swipe = Swipe(swiperId: swiperId, swipedUserId: swipedUserId, direction: direction)
        try await firestoreService.setDocument(
            collection: "swipes",
            documentId: swipe.id,
            data: swipe
        )

        if direction == .like || direction == .superLike {
            let reverseSwipes: [Swipe] = try await firestoreService.getDocuments(
                collection: "swipes",
                filters: [
                    FirestoreFilter(field: "swiperId", op: .isEqualTo, value: swipedUserId),
                    FirestoreFilter(field: "swipedUserId", op: .isEqualTo, value: swiperId)
                ],
                limit: 1
            )

            if let reverseSwipe = reverseSwipes.first,
               reverseSwipe.direction == .like || reverseSwipe.direction == .superLike {
                let match = Match(
                    id: UUID().uuidString,
                    userId: swiperId,
                    matchedUserId: swipedUserId
                )
                let dto = MatchDTO.from(domain: match)
                try await firestoreService.setDocument(
                    collection: "matches",
                    documentId: match.id,
                    data: dto
                )
                return match
            }
        }

        return nil
    }

    func getMatches(userId: String) async throws -> [Match] {
        let dtos: [MatchDTO] = try await firestoreService.getDocuments(
            collection: "matches",
            filters: [
                FirestoreFilter(field: "user_id", op: .isEqualTo, value: userId)
            ],
            limit: nil
        )
        return dtos.map { $0.toDomain() }
    }

    func getDiscoverProfiles(userId: String, limit: Int) async throws -> [Profile] {
        let dtos: [ProfileDTO] = try await firestoreService.getDocuments(
            collection: "profiles",
            filters: [],
            limit: limit
        )
        return dtos.map { $0.toDomain() }.filter { $0.id != userId }
    }

    func observeMatches(userId: String) -> AnyPublisher<[Match], Error> {
        firestoreService.observeCollection(
            collection: "matches",
            filters: [
                FirestoreFilter(field: "user_id", op: .isEqualTo, value: userId)
            ]
        )
        .map { (dtos: [MatchDTO]) in dtos.map { $0.toDomain() } }
        .eraseToAnyPublisher()
    }

    func unmatch(matchId: String) async throws {
        try await firestoreService.deleteDocument(collection: "matches", documentId: matchId)
    }
}
