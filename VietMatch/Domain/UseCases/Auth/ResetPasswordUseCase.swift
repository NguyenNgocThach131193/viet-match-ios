import Foundation

protocol ResetPasswordUseCaseProtocol {
    func execute(email: String) async throws
}

final class ResetPasswordUseCase: ResetPasswordUseCaseProtocol {
    private let authRepository: AuthRepositoryProtocol

    init(authRepository: AuthRepositoryProtocol) {
        self.authRepository = authRepository
    }

    func execute(email: String) async throws {
        let trimmedEmail = email.trimmed
        guard !trimmedEmail.isEmpty else {
            throw AuthError.invalidCredentials
        }
        guard trimmedEmail.isValidEmail else {
            throw AuthError.invalidCredentials
        }
        try await authRepository.resetPassword(email: trimmedEmail)
    }
}
