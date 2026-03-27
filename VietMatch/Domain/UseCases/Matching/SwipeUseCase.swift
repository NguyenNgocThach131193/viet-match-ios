import Foundation

protocol SwipeUseCaseProtocol {
    func execute(swiperId: String, swipedUserId: String, direction: SwipeDirection) async throws -> Match?
}

final class SwipeUseCase: SwipeUseCaseProtocol {
    private let matchRepository: MatchRepositoryProtocol

    init(matchRepository: MatchRepositoryProtocol) {
        self.matchRepository = matchRepository
    }

    func execute(swiperId: String, swipedUserId: String, direction: SwipeDirection) async throws -> Match? {
        try await matchRepository.swipe(
            swiperId: swiperId,
            swipedUserId: swipedUserId,
            direction: direction
        )
    }
}
