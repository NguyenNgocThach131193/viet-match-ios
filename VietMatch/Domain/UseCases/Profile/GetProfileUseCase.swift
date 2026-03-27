import Foundation

protocol GetProfileUseCaseProtocol {
    func execute(userId: String) async throws -> Profile
}

final class GetProfileUseCase: GetProfileUseCaseProtocol {
    private let profileRepository: ProfileRepositoryProtocol

    init(profileRepository: ProfileRepositoryProtocol) {
        self.profileRepository = profileRepository
    }

    func execute(userId: String) async throws -> Profile {
        try await profileRepository.getProfile(userId: userId)
    }
}
