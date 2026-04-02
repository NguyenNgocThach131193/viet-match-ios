import AuthenticationServices
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

    // Stored between onRequest and onCompletion callbacks of SignInWithAppleButton.
    private var currentAppleNonce: String?

    init(loginUseCase: LoginUseCaseProtocol) {
        self.loginUseCase = loginUseCase
    }

    var isFormValid: Bool {
        email.isValidEmail && password.isValidPassword
    }

    func login() async {
        guard !isLoading else { return }
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
        guard !isLoading else { return }
        isLoading = true
        do {
            _ = try await loginUseCase.executeWithGoogle()
        } catch AuthError.cancelled {
            // User dismissed the sign-in sheet — no error shown
        } catch {
            showErrorMessage(error.localizedDescription)
        }
        isLoading = false
    }

    /// Called from SignInWithAppleButton's `onRequest` closure.
    /// Generates a fresh nonce, stores the raw value, and returns the SHA-256 hash
    /// to be set on the ASAuthorizationAppleIDRequest.
    func prepareAppleSignIn() -> String {
        let nonce = AppleSignInHelper.randomNonce()
        currentAppleNonce = nonce
        return AppleSignInHelper.sha256(nonce)
    }

    /// Called from SignInWithAppleButton's `onCompletion` closure on success.
    func loginWithApple(authorization: ASAuthorization) async {
        guard !isLoading else { return }
        guard
            let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
            let tokenData = credential.identityToken,
            let idToken = String(data: tokenData, encoding: .utf8),
            let nonce = currentAppleNonce
        else {
            showErrorMessage("Apple Sign-In thất bại: thông tin xác thực không hợp lệ")
            return
        }

        isLoading = true
        do {
            _ = try await loginUseCase.executeWithApple(idToken: idToken, nonce: nonce)
        } catch {
            showErrorMessage(error.localizedDescription)
        }
        currentAppleNonce = nil
        isLoading = false
    }

    /// Called from SignInWithAppleButton's `onCompletion` closure on failure.
    func handleAppleSignInError(_ error: Error) {
        let nsError = error as NSError
        guard !(nsError.domain == ASAuthorizationError.errorDomain
                && nsError.code == ASAuthorizationError.canceled.rawValue) else {
            // User cancelled — no error shown
            return
        }
        showErrorMessage(error.localizedDescription)
    }

    private func showErrorMessage(_ message: String) {
        errorMessage = message
        showError = true
    }
}
