import Foundation

protocol DeleteAccountUseCaseProtocol {
    func execute(userId: String) async throws
}

final class DeleteAccountUseCase: DeleteAccountUseCaseProtocol {
    private let authRepository: AuthRepositoryProtocol
    private let profileRepository: ProfileRepositoryProtocol

    init(authRepository: AuthRepositoryProtocol, profileRepository: ProfileRepositoryProtocol) {
        self.authRepository = authRepository
        self.profileRepository = profileRepository
    }

    /// Xóa tài khoản theo đúng thứ tự:
    /// 1. Xóa ảnh trong Storage (photos/{userId}/)
    /// 2. Xóa document profiles/{userId}
    /// 3. Xóa document users/{userId} + Firebase Auth (qua authRepository.deleteAccount)
    func execute(userId: String) async throws {
        // Bước 1+2: Lấy profile để tìm photo URLs, rồi xóa từng ảnh và profile document
        do {
            let profile = try await profileRepository.getProfile(userId: userId)
            for photoURL in profile.photos {
                try? await profileRepository.deletePhoto(userId: userId, photoURL: photoURL)
            }
            try await profileRepository.deleteProfile(userId: userId)
        } catch {
            // Nếu profile không tồn tại, tiếp tục xóa Auth
            AppLogger.general.warning("deleteAccount: profile cleanup failed — \(error.localizedDescription)")
        }

        // Bước 3: Xóa users/{userId} + Firebase Auth record
        try await authRepository.deleteAccount()
    }
}
