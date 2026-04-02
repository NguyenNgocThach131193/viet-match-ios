import SwiftUI

struct DiscoverView: View {
    @ObservedObject var viewModel: DiscoverViewModel
    var coordinator: DiscoverCoordinator

    var body: some View {
        VStack(spacing: 0) {
            // Header
            header

            // Card stack
            ZStack {
                if viewModel.isLoading {
                    LoadingView()
                } else if !viewModel.hasMoreProfiles {
                    EmptyStateView(
                        icon: "heart.slash",
                        title: "Hết hồ sơ rồi!",
                        message: "Hãy quay lại sau để khám phá thêm",
                        actionTitle: "Làm mới danh sách",
                        action: { Task { await viewModel.loadProfiles() } }
                    )
                } else {
                    cardStack
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Action buttons
            if viewModel.hasMoreProfiles {
                actionButtons
            }
        }
        .background(VietMatchColors.background.ignoresSafeArea())
        .task {
            await viewModel.loadProfiles()
        }
        .alert("It's a Match! 🎉", isPresented: $viewModel.showMatchAlert) {
            Button("Nhắn tin ngay") {
                if let matchId = viewModel.currentMatchId {
                    coordinator.showChat(matchId: matchId)
                }
            }
            Button("Để sau", role: .cancel) {}
        } message: {
            if let profile = viewModel.matchedProfile {
                Text("Bạn và \(profile.name) đã thích nhau!")
            }
        }
    }

    private var header: some View {
        HStack {
            Image(systemName: "flame.fill")
                .font(.title2)
                .foregroundStyle(VietMatchColors.primaryGradient)
            Text("Khám phá")
                .font(VietMatchTypography.title3)
                .foregroundColor(VietMatchColors.textPrimary)
            Spacer()
        }
        .padding(.horizontal, VietMatchSpacing.xl)
        .padding(.vertical, VietMatchSpacing.md)
    }

    private var cardStack: some View {
        ZStack {
            ForEach(Array(viewModel.profiles.enumerated().reversed()), id: \.element.id) { index, profile in
                if index >= viewModel.currentIndex && index < viewModel.currentIndex + 3 {
                    CardView(
                        profile: profile,
                        onSwipeLeft: { Task { await viewModel.dislike() } },
                        onSwipeRight: { Task { await viewModel.like() } }
                    )
                    .scaleEffect(index == viewModel.currentIndex ? 1 : 0.95)
                    .offset(y: CGFloat(index - viewModel.currentIndex) * 8)
                    .allowsHitTesting(index == viewModel.currentIndex)
                }
            }
        }
        .padding(.horizontal, VietMatchSpacing.lg)
        .allowsHitTesting(!viewModel.isSwiping)
    }

    private var actionButtons: some View {
        HStack(spacing: VietMatchSpacing.xxl) {
            // Dislike
            Button {
                Task { await viewModel.dislike() }
            } label: {
                Image(systemName: "xmark")
                    .font(.title2.bold())
                    .foregroundColor(VietMatchColors.dislike)
                    .frame(width: 60, height: 60)
                    .background(Circle().fill(Color.white).cardShadow())
            }

            // Super Like
            Button {
                Task { await viewModel.superLike() }
            } label: {
                Image(systemName: "star.fill")
                    .font(.title3)
                    .foregroundColor(VietMatchColors.superLike)
                    .frame(width: 48, height: 48)
                    .background(Circle().fill(Color.white).cardShadow())
            }

            // Like
            Button {
                Task { await viewModel.like() }
            } label: {
                Image(systemName: "heart.fill")
                    .font(.title2.bold())
                    .foregroundColor(VietMatchColors.like)
                    .frame(width: 60, height: 60)
                    .background(Circle().fill(Color.white).cardShadow())
            }
        }
        .padding(.vertical, VietMatchSpacing.xl)
        .disabled(viewModel.isSwiping)
    }
}
