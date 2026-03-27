import SwiftUI

struct ProfileSetupView: View {
    @ObservedObject var viewModel: OnboardingViewModel

    var body: some View {
        VStack(spacing: VietMatchSpacing.xl) {
            Text("Thông tin cơ bản")
                .font(VietMatchTypography.title2)

            VStack(spacing: VietMatchSpacing.lg) {
                TextField("Tên của bạn", text: $viewModel.name)
                    .textFieldStyle(.plain)
                    .padding()
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .cardShadow()

                VStack(alignment: .leading, spacing: VietMatchSpacing.sm) {
                    Text("Tuổi: \(viewModel.age)")
                        .font(VietMatchTypography.body)
                    Slider(value: Binding(
                        get: { Double(viewModel.age) },
                        set: { viewModel.age = Int($0) }
                    ), in: 18...100, step: 1)
                    .tint(VietMatchColors.primary)
                }
                .padding()
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .cardShadow()

                VStack(alignment: .leading, spacing: VietMatchSpacing.xs) {
                    Text("Giới thiệu bản thân")
                        .font(VietMatchTypography.footnote)
                        .foregroundColor(VietMatchColors.textSecondary)
                    TextEditor(text: $viewModel.bio)
                        .frame(height: 100)
                        .scrollContentBackground(.hidden)
                }
                .padding()
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .cardShadow()
            }

            Spacer()
        }
        .padding(.horizontal, VietMatchSpacing.xl)
        .padding(.top, VietMatchSpacing.xxl)
    }
}
