import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel

    var body: some View {
        List {
            // Discovery preferences
            Section("Khám phá") {
                VStack(alignment: .leading) {
                    HStack {
                        Text("Khoảng cách tối đa")
                        Spacer()
                        Text("\(Int(viewModel.distancePreference)) km")
                            .foregroundColor(VietMatchColors.textSecondary)
                    }
                    Slider(value: $viewModel.distancePreference, in: 1...Double(Constants.App.maxDistance))
                        .tint(VietMatchColors.primary)
                }

                VStack(alignment: .leading) {
                    HStack {
                        Text("Độ tuổi")
                        Spacer()
                        Text("\(Int(viewModel.ageRangeMin)) - \(Int(viewModel.ageRangeMax))")
                            .foregroundColor(VietMatchColors.textSecondary)
                    }
                    HStack {
                        Slider(value: $viewModel.ageRangeMin, in: 18...99)
                            .tint(VietMatchColors.primary)
                        Slider(value: $viewModel.ageRangeMax, in: 18...100)
                            .tint(VietMatchColors.primary)
                    }
                }
            }

            // Notifications
            Section("Thông báo") {
                Toggle("Bật thông báo", isOn: Binding(
                    get: { viewModel.notificationsEnabled },
                    set: { newValue in Task { await viewModel.toggleNotifications(enabled: newValue) } }
                ))
            }
            .tint(VietMatchColors.primary)

            // Account
            Section("Tài khoản") {
                Button(role: .destructive) {
                    viewModel.showLogoutConfirmation = true
                } label: {
                    Label("Đăng xuất", systemImage: "arrow.right.square")
                }

                Button(role: .destructive) {
                    viewModel.showDeleteConfirmation = true
                } label: {
                    Label("Xóa tài khoản", systemImage: "trash")
                }
            }

            // App info
            Section("Thông tin") {
                HStack {
                    Text("Phiên bản")
                    Spacer()
                    Text("1.0.0")
                        .foregroundColor(VietMatchColors.textSecondary)
                }
            }
        }
        .navigationTitle("Cài đặt")
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.loadPreferences() }
        .alert("Đăng xuất", isPresented: $viewModel.showLogoutConfirmation) {
            Button("Hủy", role: .cancel) {}
            Button("Đăng xuất", role: .destructive) {
                Task { await viewModel.logout() }
            }
        } message: {
            Text("Bạn có chắc muốn đăng xuất?")
        }
        .alert("Xóa tài khoản", isPresented: $viewModel.showDeleteConfirmation) {
            Button("Hủy", role: .cancel) {}
            Button("Xóa tài khoản", role: .destructive) {
                Task { await viewModel.deleteAccount() }
            }
        } message: {
            Text("Hành động này không thể hoàn tác. Tất cả dữ liệu của bạn sẽ bị xóa vĩnh viễn.")
        }
        .alert("Lỗi", isPresented: .init(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }
}
