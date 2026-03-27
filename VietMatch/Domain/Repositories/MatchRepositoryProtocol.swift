import Foundation
import Combine

protocol MatchRepositoryProtocol {
    func swipe(swiperId: String, swipedUserId: String, direction: SwipeDirection) async throws -> Match?
    func getMatches(userId: String) async throws -> [Match]
    func getDiscoverProfiles(userId: String, limit: Int) async throws -> [Profile]
    func observeMatches(userId: String) -> AnyPublisher<[Match], Error>
    func unmatch(matchId: String) async throws
}
