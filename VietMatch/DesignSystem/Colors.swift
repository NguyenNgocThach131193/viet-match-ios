import SwiftUI

enum VietMatchColors {
    // Primary gradient (Tinder-inspired warm gradient)
    static let primary = Color(hex: "FE3C72")
    static let primaryLight = Color(hex: "FF6B6B")
    static let primaryDark = Color(hex: "E91E63")

    // Secondary
    static let secondary = Color(hex: "FF8A65")
    static let accent = Color(hex: "FFD54F")

    // Background
    static let background = Color(hex: "FAFAFA")
    static let cardBackground = Color.white
    static let darkBackground = Color(hex: "1A1A2E")

    // Text
    static let textPrimary = Color(hex: "21262E")
    static let textSecondary = Color(hex: "6C757D")
    static let textLight = Color.white

    // Status
    static let success = Color(hex: "4CAF50")
    static let warning = Color(hex: "FF9800")
    static let error = Color(hex: "F44336")
    static let info = Color(hex: "2196F3")

    // Swipe
    static let like = Color(hex: "4CAF50")
    static let dislike = Color(hex: "F44336")
    static let superLike = Color(hex: "2196F3")

    // Gradients
    static let primaryGradient = LinearGradient(
        colors: [primaryLight, primary, primaryDark],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let cardGradient = LinearGradient(
        colors: [.clear, .black.opacity(0.7)],
        startPoint: .center,
        endPoint: .bottom
    )

    static let warmGradient = LinearGradient(
        colors: [Color(hex: "FF6B6B"), Color(hex: "FE3C72"), Color(hex: "FF8A65")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
