import Foundation
import Combine

@MainActor
final class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showError = false

    private let loginUseCase: LoginUseCaseProtocol

    init(loginUseCase: LoginUseCaseProtocol) {
        self.loginUseCase = loginUseCase
    }

    var isFormValid: Bool {
        email.isValidEmail && password.isValidPassword
    }

    func login() async {
        guard isFormValid else {
            showErrorMessage("Vui lòng kiểm tra email và mật khẩu")
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            _ = try await loginUseCase.execute(email: email.trimmed, password: password)
            AppLogger.auth.info("Login successful")
        } catch {
            showErrorMessage(error.localizedDescription)
            AppLogger.auth.error("Login failed: \(error.localizedDescription)")
        }

        isLoading = false
    }

    func loginWithGoogle() async {
        isLoading = true
        do {
            _ = try await loginUseCase.executeWithGoogle()
        } catch {
            showErrorMessage(error.localizedDescription)
        }
        isLoading = false
    }

    private func showErrorMessage(_ message: String) {
        errorMessage = message
        showError = true
    }
}
