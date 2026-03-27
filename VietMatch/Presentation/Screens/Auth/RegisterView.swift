import SwiftUI

struct RegisterView: View {
    @ObservedObject var viewModel: RegisterViewModel
    var coordinator: AuthCoordinator

    var body: some View {
        ZStack {
            VietMatchColors.background
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: VietMatchSpacing.xl) {
                    Text("Tạo tài khoản")
                        .font(VietMatchTypography.title1)
                        .foregroundColor(VietMatchColors.textPrimary)

                    Text("Bắt đầu tìm kiếm nửa kia của bạn")
                        .font(VietMatchTypography.subheadline)
                        .foregroundColor(VietMatchColors.textSecondary)

                    VStack(spacing: VietMatchSpacing.lg) {
                        TextField("Tên hiển thị", text: $viewModel.displayName)
                            .textContentType(.name)
                            .textFieldModifier()

                        TextField("Email", text: $viewModel.email)
                            .keyboardType(.emailAddress)
                            .textContentType(.emailAddress)
                            .autocapitalization(.none)
                            .textFieldModifier()

                        SecureField("Mật khẩu (ít nhất 6 ký tự)", text: $viewModel.password)
                            .textContentType(.newPassword)
                            .textFieldModifier()

                        SecureField("Xác nhận mật khẩu", text: $viewModel.confirmPassword)
                            .textContentType(.newPassword)
                            .textFieldModifier()

                        if viewModel.passwordMismatch {
                            Text("Mật khẩu không khớp")
                                .font(VietMatchTypography.caption)
                                .foregroundColor(VietMatchColors.error)
                        }
                    }

                    Button {
                        Task { await viewModel.register() }
                    } label: {
                        Group {
                            if viewModel.isLoading {
                                ProgressView().tint(.white)
                            } else {
                                Text("Đăng ký")
                            }
                        }
                        .primaryButtonStyle()
                    }
                    .disabled(!viewModel.isFormValid || viewModel.isLoading)
                    .opacity(viewModel.isFormValid ? 1 : 0.6)

                    Button {
                        coordinator.pop()
                    } label: {
                        HStack(spacing: 4) {
                            Text("Đã có tài khoản?")
                                .foregroundColor(VietMatchColors.textSecondary)
                            Text("Đăng nhập")
                                .foregroundColor(VietMatchColors.primary)
                                .fontWeight(.semibold)
                        }
                        .font(VietMatchTypography.callout)
                    }
                }
                .padding(.horizontal, VietMatchSpacing.xl)
                .padding(.top, VietMatchSpacing.xxl)
            }
        }
        .alert("Lỗi", isPresented: $viewModel.showError) {
            Button("OK") {}
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { coordinator.pop() } label: {
                    Image(systemName: "chevron.left")
                        .foregroundColor(VietMatchColors.textPrimary)
                }
            }
        }
    }
}

private extension View {
    func textFieldModifier() -> some View {
        self
            .textFieldStyle(.plain)
            .padding()
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .cardShadow()
    }
}
