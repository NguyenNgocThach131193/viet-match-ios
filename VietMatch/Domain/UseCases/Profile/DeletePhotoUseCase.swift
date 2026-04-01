import Foundation

protocol DeletePhotoUseCaseProtocol {
    func execute(userId: String, photoURL: String) async throws
}

final class DeletePhotoUseCase: DeletePhotoUseCaseProtocol {
    private let profileRepository: ProfileRepositoryProtocol

    init(profileRepository: ProfileRepositoryProtocol) {
        self.profileRepository = profileRepository
    }

    func execute(userId: String, photoURL: String) async throws {
        try await profileRepository.deletePhoto(userId: userId, photoURL: photoURL)
    }
}
