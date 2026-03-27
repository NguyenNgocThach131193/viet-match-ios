import Foundation
import Combine

@MainActor
final class ForgotPasswordViewModel: ObservableObject {
    @Published var email = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showError = false
    @Published var showSuccess = false
    @Published var successMessage: String?

    private let resetPasswordUseCase: ResetPasswordUseCaseProtocol

    init(resetPasswordUseCase: ResetPasswordUseCaseProtocol) {
        self.resetPasswordUseCase = resetPasswordUseCase
    }

    var isEmailValid: Bool {
        email.trimmed.isValidEmail
    }

    func resetPassword() async {
        guard !email.trimmed.isEmpty else {
            showErrorMessage("Vui lòng nhập email")
            return
        }

        guard isEmailValid else {
            showErrorMessage("Email không đúng định dạng")
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            try await resetPasswordUseCase.execute(email: email.trimmed)
            successMessage = "Email đặt lại mật khẩu đã được gửi. Vui lòng kiểm tra hộp thư của bạn."
            showSuccess = true
            AppLogger.auth.info("Reset password email sent")
        } catch {
            showErrorMessage(error.localizedDescription)
            AppLogger.auth.error("Reset password failed: \(error.localizedDescription)")
        }

        isLoading = false
    }

    private func showErrorMessage(_ message: String) {
        errorMessage = message
        showError = true
    }
}
