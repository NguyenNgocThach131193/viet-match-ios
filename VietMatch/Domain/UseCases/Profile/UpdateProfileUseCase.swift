import Foundation

protocol UpdateProfileUseCaseProtocol {
    func execute(_ profile: Profile) async throws -> Profile
}

final class UpdateProfileUseCase: UpdateProfileUseCaseProtocol {
    private let profileRepository: ProfileRepositoryProtocol

    init(profileRepository: ProfileRepositoryProtocol) {
        self.profileRepository = profileRepository
    }

    func execute(_ profile: Profile) async throws -> Profile {
        try await profileRepository.updateProfile(profile)
    }
}
