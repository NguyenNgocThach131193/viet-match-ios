import Foundation

@MainActor
final class RegisterViewModel: ObservableObject {
    @Published var displayName = ""
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showError = false

    private let registerUseCase: RegisterUseCaseProtocol

    init(registerUseCase: RegisterUseCaseProtocol) {
        self.registerUseCase = registerUseCase
    }

    var isFormValid: Bool {
        !displayName.trimmed.isEmpty &&
        email.isValidEmail &&
        password.isValidPassword &&
        password == confirmPassword
    }

    var passwordMismatch: Bool {
        !confirmPassword.isEmpty && password != confirmPassword
    }

    func register() async {
        guard isFormValid else {
            showErrorMessage("Vui lòng điền đầy đủ thông tin")
            return
        }

        isLoading = true
        do {
            _ = try await registerUseCase.execute(
                email: email.trimmed,
                password: password,
                displayName: displayName.trimmed
            )
            AppLogger.auth.info("Registration successful")
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
