import Foundation

protocol RegisterUseCaseProtocol {
    func execute(email: String, password: String, displayName: String) async throws -> User
}

final class RegisterUseCase: RegisterUseCaseProtocol {
    private let authRepository: AuthRepositoryProtocol

    init(authRepository: AuthRepositoryProtocol) {
        self.authRepository = authRepository
    }

    func execute(email: String, password: String, displayName: String) async throws -> User {
        guard !email.isEmpty else { throw AuthError.invalidCredentials }
        guard password.count >= 6 else { throw AuthError.weakPassword }
        guard !displayName.isEmpty else { throw AuthError.invalidCredentials }

        return try await authRepository.register(
            email: email,
            password: password,
            displayName: displayName
        )
    }
}
