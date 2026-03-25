import SwiftUI
import Kingfisher

struct MatchCellView: View {
    let match: Match
    let style: Style

    enum Style {
        case compact
        case full
    }

    var body: some View {
        switch style {
        case .compact:
            compactView
        case .full:
            fullView
        }
    }

    private var compactView: some View {
        VStack(spacing: VietMatchSpacing.xs) {
            profileImage(size: 70)

            Text(match.matchedProfile?.name ?? "")
                .font(VietMatchTypography.caption)
                .foregroundColor(VietMatchColors.textPrimary)
                .lineLimit(1)
        }
        .frame(width: 80)
    }

    private var fullView: some View {
        HStack(spacing: VietMatchSpacing.md) {
            profileImage(size: VietMatchSpacing.avatarMedium)

            VStack(alignment: .leading, spacing: VietMatchSpacing.xxs) {
                Text(match.matchedProfile?.name ?? "Người dùng")
                    .font(VietMatchTypography.headline)
                    .foregroundColor(VietMatchColors.textPrimary)

                Text(timeAgo)
                    .font(VietMatchTypography.caption)
                    .foregroundColor(VietMatchColors.textSecondary)
            }

            Spacer()

            if match.isNew {
                Circle()
                    .fill(VietMatchColors.primary)
                    .frame(width: 10, height: 10)
            }
        }
        .padding(VietMatchSpacing.md)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .cardShadow()
    }

    private func profileImage(size: CGFloat) -> some View {
        Group {
            if let photoURL = match.matchedProfile?.photos.first,
               let url = URL(string: photoURL) {
                KFImage(url)
                    .resizable()
                    .scaledToFill()
            } else {
                Image(systemName: "person.fill")
                    .font(.title3)
                    .foregroundColor(.gray)
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
        .overlay(Circle().stroke(VietMatchColors.primaryGradient, lineWidth: 2))
    }

    private var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "vi_VN")
        return formatter.localizedString(for: match.createdAt, relativeTo: Date())
    }
}
