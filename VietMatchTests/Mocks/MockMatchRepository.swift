import Foundation
import Combine
@testable import VietMatch

final class MockMatchRepository: MatchRepositoryProtocol {
    var swipeResult: Result<Match?, Error> = .success(nil)
    var getMatchesResult: Result<[Match], Error> = .success([])
    var getDiscoverProfilesResult: Result<[Profile], Error> = .success([])

    var swipeCallCount = 0
    var getMatchesCallCount = 0
    var lastGetMatchesUserId: String?
    var lastGetDiscoverProfilesUserId: String?

    func swipe(swiperId: String, swipedUserId: String, direction: SwipeDirection) async throws -> Match? {
        swipeCallCount += 1
        return try swipeResult.get()
    }

    func getMatches(userId: String) async throws -> [Match] {
        getMatchesCallCount += 1
        lastGetMatchesUserId = userId
        return try getMatchesResult.get()
    }

    func getDiscoverProfiles(userId: String, limit: Int) async throws -> [Profile] {
        lastGetDiscoverProfilesUserId = userId
        return try getDiscoverProfilesResult.get()
    }

    func observeMatches(userId: String) -> AnyPublisher<[Match], Error> {
        Just([]).setFailureType(to: Error.self).eraseToAnyPublisher()
    }

    func unmatch(matchId: String) async throws {}
}
