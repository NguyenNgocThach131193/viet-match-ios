import SwiftUI

extension View {
    func cardShadow() -> some View {
        shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 4)
    }

    func primaryButtonStyle() -> some View {
        self
            .font(VietMatchTypography.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: VietMatchSpacing.buttonHeight)
            .background(VietMatchColors.primaryGradient)
            .clipShape(RoundedRectangle(cornerRadius: VietMatchSpacing.buttonCornerRadius))
    }

    func secondaryButtonStyle() -> some View {
        self
            .font(VietMatchTypography.headline)
            .foregroundColor(VietMatchColors.primary)
            .frame(maxWidth: .infinity)
            .frame(height: VietMatchSpacing.buttonHeight)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: VietMatchSpacing.buttonCornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: VietMatchSpacing.buttonCornerRadius)
                    .stroke(VietMatchColors.primary, lineWidth: 2)
            )
    }

    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
