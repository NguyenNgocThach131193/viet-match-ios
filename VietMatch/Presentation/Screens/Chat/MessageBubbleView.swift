import Kingfisher
import SwiftUI

struct MessageBubbleView: View {
    let message: Message
    let isFromCurrentUser: Bool

    var body: some View {
        HStack {
            if isFromCurrentUser { Spacer(minLength: 60) }

            VStack(alignment: isFromCurrentUser ? .trailing : .leading, spacing: VietMatchSpacing.xxs) {
                bubbleContent

                Text(formattedTime)
                    .font(VietMatchTypography.caption2)
                    .foregroundColor(VietMatchColors.textSecondary)
            }

            if !isFromCurrentUser { Spacer(minLength: 60) }
        }
    }

    @ViewBuilder
    private var bubbleContent: some View {
        if message.type == .image, let url = URL(string: message.content) {
            KFImage(url)
                .placeholder {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 200, height: 150)
                        .overlay(ProgressView())
                }
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(maxWidth: 220)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .cardShadow()
        } else {
            Text(message.content)
                .font(VietMatchTypography.body)
                .foregroundColor(isFromCurrentUser ? .white : VietMatchColors.textPrimary)
                .padding(.horizontal, VietMatchSpacing.lg)
                .padding(.vertical, VietMatchSpacing.md)
                .background(
                    isFromCurrentUser
                        ? AnyShapeStyle(VietMatchColors.primaryGradient)
                        : AnyShapeStyle(Color.white)
                )
                .clipShape(ChatBubbleShape(isFromCurrentUser: isFromCurrentUser))
                .cardShadow()
        }
    }

    private var formattedTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "vi_VN")
        return formatter.string(from: message.createdAt)
    }
}

struct ChatBubbleShape: Shape {
    let isFromCurrentUser: Bool

    func path(in rect: CGRect) -> Path {
        let radius: CGFloat = 18
        let tailSize: CGFloat = 6

        var path = Path()

        if isFromCurrentUser {
            path.addRoundedRect(
                in: CGRect(x: rect.minX, y: rect.minY, width: rect.width - tailSize, height: rect.height),
                cornerSize: CGSize(width: radius, height: radius)
            )
        } else {
            path.addRoundedRect(
                in: CGRect(x: rect.minX + tailSize, y: rect.minY, width: rect.width - tailSize, height: rect.height),
                cornerSize: CGSize(width: radius, height: radius)
            )
        }

        return path
    }
}
