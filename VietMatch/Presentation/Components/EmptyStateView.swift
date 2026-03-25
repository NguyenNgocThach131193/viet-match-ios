import SwiftUI

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    var actionTitle: String?
    var action: (() -> Void)?

    var body: some View {
        VStack(spacing: VietMatchSpacing.lg) {
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundStyle(VietMatchColors.primaryGradient)

            Text(title)
                .font(VietMatchTypography.title3)
                .foregroundColor(VietMatchColors.textPrimary)

            Text(message)
                .font(VietMatchTypography.body)
                .foregroundColor(VietMatchColors.textSecondary)
                .multilineTextAlignment(.center)

            if let actionTitle, let action {
                GradientButton(title: actionTitle, action: action)
                    .frame(width: 200)
            }
        }
        .padding(VietMatchSpacing.xxl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
