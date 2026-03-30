#if UIPREVIEW

import Foundation
import Combine

final class MockMatchRepository: MatchRepositoryProtocol {
    private var swipeCount = 0

    func swipe(swiperId: String, swipedUserId: String, direction: SwipeDirection) async throws -> Match? {
        try await Task.sleep(nanoseconds: 300_000_000)
        swipeCount += 1

        // Mỗi 3 lần like -> tạo match để test match alert UI
        if direction == .like && swipeCount % 3 == 0 {
            let matchedProfile = MockData.discoverProfiles.first { $0.id == swipedUserId }
            return Match(
                id: UUID().uuidString,
                userId: swiperId,
                matchedUserId: swipedUserId,
                matchedProfile: matchedProfile,
                isNew: true
            )
        }
        return nil
    }

    func getMatches(userId: String) async throws -> [Match] {
        try await Task.sleep(nanoseconds: 400_000_000)
        return MockData.matches
    }

    func getDiscoverProfiles(userId: String, limit: Int) async throws -> [Profile] {
        try await Task.sleep(nanoseconds: 500_000_000)
        return Array(MockData.discoverProfiles.prefix(limit))
    }

    func observeMatches(userId: String) -> AnyPublisher<[Match], Error> {
        Just(MockData.matches)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    func unmatch(matchId: String) async throws {
        try await Task.sleep(nanoseconds: 300_000_000)
    }
}

#endif
