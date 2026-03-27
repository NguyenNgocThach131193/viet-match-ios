import Foundation

protocol LoginUseCaseProtocol {
    func execute(email: String, password: String) async throws -> User
    func executeWithGoogle() async throws -> User
    func executeWithApple(idToken: String, nonce: String) async throws -> User
}

final class LoginUseCase: LoginUseCaseProtocol {
    private let authRepository: AuthRepositoryProtocol

    init(authRepository: AuthRepositoryProtocol) {
        self.authRepository = authRepository
    }

    func execute(email: String, password: String) async throws -> User {
        guard !email.isEmpty, !password.isEmpty else {
            throw AuthError.invalidCredentials
        }
        return try await authRepository.login(email: email, password: password)
    }

    func executeWithGoogle() async throws -> User {
        try await authRepository.loginWithGoogle()
    }

    func executeWithApple(idToken: String, nonce: String) async throws -> User {
        try await authRepository.loginWithApple(idToken: idToken, nonce: nonce)
    }
}

enum AuthError: LocalizedError, Equatable {
    case invalidCredentials
    case userNotFound
    case emailAlreadyInUse
    case weakPassword
    case unknown(String)

    var errorDescription: String? {
        switch self {
        case .invalidCredentials: return "Email hoặc mật khẩu không hợp lệ"
        case .userNotFound: return "Không tìm thấy tài khoản"
        case .emailAlreadyInUse: return "Email đã được sử dụng"
        case .weakPassword: return "Mật khẩu quá yếu"
        case .unknown(let message): return message
        }
    }
}
