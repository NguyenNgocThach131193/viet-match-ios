import SwiftUI

struct LoadingView: View {
    var message: String = "Đang tải..."

    var body: some View {
        VStack(spacing: VietMatchSpacing.lg) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(VietMatchColors.primary)

            Text(message)
                .font(VietMatchTypography.subheadline)
                .foregroundColor(VietMatchColors.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
