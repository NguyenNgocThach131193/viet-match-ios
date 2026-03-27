import SwiftUI

struct ForgotPasswordView: View {
    @ObservedObject var viewModel: ForgotPasswordViewModel
    var coordinator: AuthCoordinator

    var body: some View {
        ZStack {
            VietMatchColors.background
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: VietMatchSpacing.xl) {
                    // Header
                    headerSection

                    // Email field
                    emailField

                    // Submit button
                    submitButton

                    // Back to login
                    backToLoginLink
                }
                .padding(.horizontal, VietMatchSpacing.xl)
                .padding(.top, VietMatchSpacing.xxxl)
            }
        }
        .alert("Thành công", isPresented: $viewModel.showSuccess) {
            Button("OK") {
                coordinator.goBack()
            }
        } message: {
            Text(viewModel.successMessage ?? "")
        }
        .alert("Lỗi", isPresented: $viewModel.showError) {
            Button("OK") {}
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .navigationBarHidden(true)
    }

    // MARK: - Sections

    private var headerSection: some View {
        VStack(spacing: VietMatchSpacing.sm) {
            Image(systemName: "lock.rotation")
                .font(.system(size: 60))
                .foregroundStyle(VietMatchColors.primaryGradient)

            Text("Quên mật khẩu")
                .font(VietMatchTypography.title1)
                .foregroundColor(VietMatchColors.textPrimary)

            Text("Nhập email để nhận link đặt lại mật khẩu")
                .font(VietMatchTypography.subheadline)
                .foregroundColor(VietMatchColors.textSecondary)
                .multilineTextAlignment(.center)
        }
    }

    private var emailField: some View {
        TextField("Email", text: $viewModel.email)
            .textFieldStyle(.plain)
            .keyboardType(.emailAddress)
            .textContentType(.emailAddress)
            .autocapitalization(.none)
            .padding()
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .cardShadow()
    }

    private var submitButton: some View {
        GradientButton(
            title: "Gửi email",
            icon: "paperplane.fill",
            isLoading: viewModel.isLoading
        ) {
            Task { await viewModel.resetPassword() }
        }
    }

    private var backToLoginLink: some View {
        Button {
            coordinator.goBack()
        } label: {
            HStack(spacing: 4) {
                Image(systemName: "chevron.left")
                Text("Quay lại đăng nhập")
            }
            .font(VietMatchTypography.callout)
            .foregroundColor(VietMatchColors.primary)
        }
        .padding(.top, VietMatchSpacing.md)
    }
}
