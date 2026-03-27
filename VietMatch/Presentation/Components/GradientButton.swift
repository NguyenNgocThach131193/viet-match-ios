import SwiftUI

struct GradientButton: View {
    let title: String
    let icon: String?
    let isLoading: Bool
    let action: () -> Void

    init(title: String, icon: String? = nil, isLoading: Bool = false, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.isLoading = isLoading
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: VietMatchSpacing.sm) {
                if isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    if let icon {
                        Image(systemName: icon)
                    }
                    Text(title)
                }
            }
            .font(VietMatchTypography.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: VietMatchSpacing.buttonHeight)
            .background(VietMatchColors.primaryGradient)
            .clipShape(RoundedRectangle(cornerRadius: VietMatchSpacing.buttonCornerRadius))
            .cardShadow()
        }
        .disabled(isLoading)
    }
}
