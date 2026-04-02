import AuthenticationServices
import SwiftUI

struct LoginView: View {
    @ObservedObject var viewModel: LoginViewModel
    var coordinator: AuthCoordinator

    var body: some View {
        ZStack {
            VietMatchColors.background
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: VietMatchSpacing.xl) {
                    // Logo
                    logoSection

                    // Form
                    formSection

                    // Login button
                    loginButton

                    // Divider
                    dividerSection

                    // Social login
                    socialLoginSection

                    // Register link
                    registerLink
                }
                .padding(.horizontal, VietMatchSpacing.xl)
                .padding(.top, VietMatchSpacing.xxxl)
            }
        }
        .alert("Lỗi", isPresented: $viewModel.showError) {
            Button("OK") {}
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .navigationBarHidden(true)
    }

    // MARK: - Sections

    private var logoSection: some View {
        VStack(spacing: VietMatchSpacing.sm) {
            Image(systemName: "flame.fill")
                .font(.system(size: 60))
                .foregroundStyle(VietMatchColors.primaryGradient)

            Text("VietMatch")
                .font(VietMatchTypography.largeTitle)
                .foregroundColor(VietMatchColors.primary)

            Text("Kết nối yêu thương")
                .font(VietMatchTypography.subheadline)
                .foregroundColor(VietMatchColors.textSecondary)
        }
    }

    private var formSection: some View {
        VStack(spacing: VietMatchSpacing.lg) {
            TextField("Email", text: $viewModel.email)
                .textFieldStyle(.plain)
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
                .autocapitalization(.none)
                .padding()
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .cardShadow()

            SecureField("Mật khẩu", text: $viewModel.password)
                .textFieldStyle(.plain)
                .textContentType(.password)
                .padding()
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .cardShadow()
        }
    }

    private var loginButton: some View {
        Button {
            Task { await viewModel.login() }
        } label: {
            Group {
                if viewModel.isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text("Đăng nhập")
                }
            }
            .primaryButtonStyle()
        }
        .disabled(viewModel.isLoading)
    }

    private var dividerSection: some View {
        HStack {
            Rectangle()
                .frame(height: 1)
                .foregroundColor(VietMatchColors.textSecondary.opacity(0.3))
            Text("hoặc")
                .font(VietMatchTypography.caption)
                .foregroundColor(VietMatchColors.textSecondary)
            Rectangle()
                .frame(height: 1)
                .foregroundColor(VietMatchColors.textSecondary.opacity(0.3))
        }
    }

    private var socialLoginSection: some View {
        VStack(spacing: VietMatchSpacing.md) {
            Button {
                Task { await viewModel.loginWithGoogle() }
            } label: {
                HStack {
                    Image(systemName: "globe")
                    Text("Tiếp tục với Google")
                }
                .secondaryButtonStyle()
            }

            SignInWithAppleButton(.signIn) { request in
                request.requestedScopes = [.fullName, .email]
                request.nonce = viewModel.prepareAppleSignIn()
            } onCompletion: { result in
                Task {
                    switch result {
                    case .success(let authorization):
                        await viewModel.loginWithApple(authorization: authorization)
                    case .failure(let error):
                        viewModel.handleAppleSignInError(error)
                    }
                }
            }
            .signInWithAppleButtonStyle(.black)
            .frame(height: VietMatchSpacing.buttonHeight)
            .clipShape(RoundedRectangle(cornerRadius: VietMatchSpacing.buttonCornerRadius))
            .disabled(viewModel.isLoading)
        }
    }

    private var registerLink: some View {
        Button {
            coordinator.showRegister()
        } label: {
            HStack(spacing: 4) {
                Text("Chưa có tài khoản?")
                    .foregroundColor(VietMatchColors.textSecondary)
                Text("Đăng ký")
                    .foregroundColor(VietMatchColors.primary)
                    .fontWeight(.semibold)
            }
            .font(VietMatchTypography.callout)
        }
        .padding(.top, VietMatchSpacing.md)
    }
}
