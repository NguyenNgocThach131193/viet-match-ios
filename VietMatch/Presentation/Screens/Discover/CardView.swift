import SwiftUI
import Kingfisher

struct CardView: View {
    let profile: Profile
    var onSwipeLeft: () -> Void
    var onSwipeRight: () -> Void

    @State private var offset: CGSize = .zero
    @State private var currentPhotoIndex = 0

    private let swipeThreshold: CGFloat = 100

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                // Photo
                photoView(size: geometry.size)

                // Gradient overlay
                VietMatchColors.cardGradient

                // Info overlay
                infoOverlay

                // Swipe indicators
                swipeIndicators
            }
            .clipShape(RoundedRectangle(cornerRadius: VietMatchSpacing.cardCornerRadius))
            .cardShadow()
            .offset(x: offset.width, y: offset.height * 0.4)
            .rotationEffect(.degrees(Double(offset.width / 40)))
            .gesture(dragGesture)
        }
    }

    private func photoView(size: CGSize) -> some View {
        ZStack {
            if let photoURL = profile.photos[safe: currentPhotoIndex],
               let url = URL(string: photoURL) {
                KFImage(url)
                    .resizable()
                    .scaledToFill()
                    .frame(width: size.width, height: size.height)
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                    )
            }

            // Photo navigation
            HStack(spacing: 0) {
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture { previousPhoto() }
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture { nextPhoto() }
            }

            // Photo indicators
            if profile.photos.count > 1 {
                VStack {
                    HStack(spacing: 4) {
                        ForEach(0..<profile.photos.count, id: \.self) { index in
                            Capsule()
                                .fill(index == currentPhotoIndex ? Color.white : Color.white.opacity(0.5))
                                .frame(height: 3)
                        }
                    }
                    .padding(.horizontal, VietMatchSpacing.lg)
                    .padding(.top, VietMatchSpacing.sm)
                    Spacer()
                }
            }
        }
    }

    private var infoOverlay: some View {
        VStack(alignment: .leading, spacing: VietMatchSpacing.xs) {
            HStack(alignment: .bottom, spacing: VietMatchSpacing.sm) {
                Text(profile.name)
                    .font(VietMatchTypography.cardName)
                Text("\(profile.age)")
                    .font(VietMatchTypography.cardAge)
            }
            .foregroundColor(.white)

            if let jobTitle = profile.jobTitle {
                HStack(spacing: VietMatchSpacing.xs) {
                    Image(systemName: "briefcase.fill")
                    Text(jobTitle)
                }
                .font(VietMatchTypography.cardInfo)
                .foregroundColor(.white.opacity(0.9))
            }

            if let city = profile.location?.city {
                HStack(spacing: VietMatchSpacing.xs) {
                    Image(systemName: "mappin.and.ellipse")
                    Text(city)
                }
                .font(VietMatchTypography.cardInfo)
                .foregroundColor(.white.opacity(0.9))
            }

            if !profile.bio.isEmpty {
                Text(profile.bio)
                    .font(VietMatchTypography.subheadline)
                    .foregroundColor(.white.opacity(0.85))
                    .lineLimit(2)
            }
        }
        .padding(VietMatchSpacing.cardPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var swipeIndicators: some View {
        ZStack {
            // Like indicator
            Text("LIKE")
                .font(.system(size: 40, weight: .bold))
                .foregroundColor(VietMatchColors.like)
                .padding(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(VietMatchColors.like, lineWidth: 4)
                )
                .rotationEffect(.degrees(-15))
                .opacity(Double(max(0, offset.width / swipeThreshold)))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .padding(30)

            // Nope indicator
            Text("NOPE")
                .font(.system(size: 40, weight: .bold))
                .foregroundColor(VietMatchColors.dislike)
                .padding(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(VietMatchColors.dislike, lineWidth: 4)
                )
                .rotationEffect(.degrees(15))
                .opacity(Double(max(0, -offset.width / swipeThreshold)))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                .padding(30)
        }
    }

    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                offset = value.translation
            }
            .onEnded { value in
                withAnimation(.spring()) {
                    if value.translation.width > swipeThreshold {
                        offset = CGSize(width: 500, height: 0)
                        onSwipeRight()
                    } else if value.translation.width < -swipeThreshold {
                        offset = CGSize(width: -500, height: 0)
                        onSwipeLeft()
                    } else {
                        offset = .zero
                    }
                }
            }
    }

    private func nextPhoto() {
        if currentPhotoIndex < profile.photos.count - 1 {
            currentPhotoIndex += 1
        }
    }

    private func previousPhoto() {
        if currentPhotoIndex > 0 {
            currentPhotoIndex -= 1
        }
    }
}

extension Array {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
