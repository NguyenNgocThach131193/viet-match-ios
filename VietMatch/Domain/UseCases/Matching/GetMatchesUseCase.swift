import Foundation

protocol GetMatchesUseCaseProtocol {
    func execute(userId: String) async throws -> [Match]
}

final class GetMatchesUseCase: GetMatchesUseCaseProtocol {
    private let matchRepository: MatchRepositoryProtocol

    init(matchRepository: MatchRepositoryProtocol) {
        self.matchRepository = matchRepository
    }

    func execute(userId: String) async throws -> [Match] {
        try await matchRepository.getMatches(userId: userId)
    }
}
