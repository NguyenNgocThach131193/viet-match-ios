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

    var swipeDelay: UInt64 = 0
    var getDiscoverProfilesDelay: UInt64 = 0

    func swipe(swiperId: String, swipedUserId: String, direction: SwipeDirection) async throws -> Match? {
        swipeCallCount += 1
        if swipeDelay > 0 {
            try? await Task.sleep(nanoseconds: swipeDelay)
        }
        return try swipeResult.get()
    }

    func getMatches(userId: String) async throws -> [Match] {
        getMatchesCallCount += 1
        lastGetMatchesUserId = userId
        return try getMatchesResult.get()
    }

    func getDiscoverProfiles(userId: String, limit: Int) async throws -> [Profile] {
        lastGetDiscoverProfilesUserId = userId
        if getDiscoverProfilesDelay > 0 {
            try? await Task.sleep(nanoseconds: getDiscoverProfilesDelay)
        }
        return try getDiscoverProfilesResult.get()
    }

    func observeMatches(userId: String) -> AnyPublisher<[Match], Error> {
        Just([]).setFailureType(to: Error.self).eraseToAnyPublisher()
    }

    func unmatch(matchId: String) async throws {}
}
