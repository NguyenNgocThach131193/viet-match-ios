import Foundation

protocol UploadPhotoUseCaseProtocol {
    func execute(userId: String, imageData: Data) async throws -> String
}

final class UploadPhotoUseCase: UploadPhotoUseCaseProtocol {
    private let profileRepository: ProfileRepositoryProtocol

    init(profileRepository: ProfileRepositoryProtocol) {
        self.profileRepository = profileRepository
    }

    func execute(userId: String, imageData: Data) async throws -> String {
        try await profileRepository.uploadPhoto(userId: userId, imageData: imageData)
    }
}
