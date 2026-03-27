import Foundation

protocol GetDiscoverProfilesUseCaseProtocol {
    func execute(userId: String, limit: Int) async throws -> [Profile]
}

final class GetDiscoverProfilesUseCase: GetDiscoverProfilesUseCaseProtocol {
    private let matchRepository: MatchRepositoryProtocol

    init(matchRepository: MatchRepositoryProtocol) {
        self.matchRepository = matchRepository
    }

    func execute(userId: String, limit: Int = 20) async throws -> [Profile] {
        try await matchRepository.getDiscoverProfiles(userId: userId, limit: limit)
    }
}
