import SwiftUI
import Kingfisher

struct ProfileDetailView: View {
    @ObservedObject var viewModel: ProfileDetailViewModel
    let coordinator: DiscoverCoordinator

    @State private var currentPhotoIndex = 0

    var body: some View {
        Group {
            if viewModel.isLoading {
                LoadingView()
            } else if let profile = viewModel.profile {
                profileContent(profile)
            } else if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundColor(VietMatchColors.error)
                    .padding()
            }
        }
        .navigationBarBackButtonHidden(false)
        .task { await viewModel.loadProfile() }
        .alert("It's a Match!", isPresented: $viewModel.showMatchAlert) {
            Button("Nhắn tin", role: .none) {
                viewModel.showMatchAlert = false
            }
            Button("Tiếp tục khám phá", role: .cancel) {
                coordinator.pop()
            }
        } message: {
            if let matched = viewModel.matchedProfile {
                Text("Bạn và \(matched.name) đã thích nhau!")
            }
        }
    }

    private func profileContent(_ profile: Profile) -> some View {
        ScrollView {
            VStack(spacing: 0) {
                photoCarousel(profile)
                infoSection(profile)
                actionButtons(profile)
                    .padding(.bottom, VietMatchSpacing.xl)
            }
        }
        .ignoresSafeArea(edges: .top)
    }

    private func photoCarousel(_ profile: Profile) -> some View {
        ZStack(alignment: .bottom) {
            if profile.photos.isEmpty {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 480)
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.gray)
                    )
            } else {
                TabView(selection: $currentPhotoIndex) {
                    ForEach(Array(profile.photos.enumerated()), id: \.offset) { index, photoURL in
                        if let url = URL(string: photoURL) {
                            KFImage(url)
                                .resizable()
                                .scaledToFill()
                                .frame(maxWidth: .infinity)
                                .clipped()
                                .tag(index)
                        } else {
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .overlay(
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 80))
                                        .foregroundColor(.gray)
                                )
                                .tag(index)
                        }
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(height: 480)
            }

            if profile.photos.count > 1 {
                HStack(spacing: 4) {
                    ForEach(0..<profile.photos.count, id: \.self) { index in
                        Capsule()
                            .fill(index == currentPhotoIndex ? Color.white : Color.white.opacity(0.5))
                            .frame(height: 3)
                    }
                }
                .padding(.horizontal, VietMatchSpacing.lg)
                .padding(.bottom, VietMatchSpacing.md)
            }
        }
    }

    private func infoSection(_ profile: Profile) -> some View {
        VStack(alignment: .leading, spacing: VietMatchSpacing.md) {
            HStack(alignment: .bottom, spacing: VietMatchSpacing.sm) {
                Text(profile.name)
                    .font(VietMatchTypography.title1)
                Text("\(profile.age)")
                    .font(VietMatchTypography.title2)
                    .foregroundColor(VietMatchColors.textSecondary)
                Spacer()
            }

            if let city = profile.location?.city {
                HStack(spacing: VietMatchSpacing.xs) {
                    Image(systemName: "mappin.and.ellipse")
                        .foregroundColor(VietMatchColors.primary)
                    Text(city)
                        .font(VietMatchTypography.subheadline)
                        .foregroundColor(VietMatchColors.textSecondary)
                }
            }

            if !profile.bio.isEmpty {
                Divider()
                Text(profile.bio)
                    .font(VietMatchTypography.body)
                    .foregroundColor(VietMatchColors.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            if profile.jobTitle != nil || profile.company != nil {
                Divider()
                VStack(alignment: .leading, spacing: VietMatchSpacing.xs) {
                    if let jobTitle = profile.jobTitle {
                        HStack(spacing: VietMatchSpacing.sm) {
                            Image(systemName: "briefcase.fill")
                                .foregroundColor(VietMatchColors.primary)
                                .frame(width: 20)
                            Text(jobTitle)
                                .font(VietMatchTypography.subheadline)
                        }
                    }
                    if let company = profile.company {
                        HStack(spacing: VietMatchSpacing.sm) {
                            Image(systemName: "building.2.fill")
                                .foregroundColor(VietMatchColors.primary)
                                .frame(width: 20)
                            Text(company)
                                .font(VietMatchTypography.subheadline)
                        }
                    }
                }
            }

            if let school = profile.school {
                if profile.jobTitle == nil && profile.company == nil {
                    Divider()
                }
                HStack(spacing: VietMatchSpacing.sm) {
                    Image(systemName: "graduationcap.fill")
                        .foregroundColor(VietMatchColors.primary)
                        .frame(width: 20)
                    Text(school)
                        .font(VietMatchTypography.subheadline)
                }
            }

            if !profile.interests.isEmpty {
                Divider()
                VStack(alignment: .leading, spacing: VietMatchSpacing.sm) {
                    Text("Sở thích")
                        .font(VietMatchTypography.headline)
                        .fontWeight(.semibold)
                    interestChips(profile.interests)
                }
            }
        }
        .padding(VietMatchSpacing.lg)
    }

    private func interestChips(_ interests: [String]) -> some View {
        LazyVGrid(
            columns: [GridItem(.adaptive(minimum: 80), spacing: VietMatchSpacing.sm)],
            alignment: .leading,
            spacing: VietMatchSpacing.sm
        ) {
            ForEach(interests, id: \.self) { interest in
                Text(interest)
                    .font(VietMatchTypography.caption)
                    .padding(.horizontal, VietMatchSpacing.sm)
                    .padding(.vertical, VietMatchSpacing.xs)
                    .background(VietMatchColors.primary.opacity(0.1))
                    .foregroundColor(VietMatchColors.primary)
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(VietMatchColors.primary.opacity(0.3), lineWidth: 1))
            }
        }
    }

    private func actionButtons(_ profile: Profile) -> some View {
        HStack(spacing: VietMatchSpacing.xl) {
            actionButton(
                icon: "xmark",
                color: VietMatchColors.dislike,
                size: 56
            ) {
                Task { await viewModel.dislike() }
            }

            actionButton(
                icon: "star.fill",
                color: VietMatchColors.superLike,
                size: 46
            ) {
                Task { await viewModel.superLike() }
            }

            actionButton(
                icon: "heart.fill",
                color: VietMatchColors.like,
                size: 56
            ) {
                Task { await viewModel.like() }
            }
        }
        .padding(.horizontal, VietMatchSpacing.xl)
        .padding(.top, VietMatchSpacing.lg)
    }

    private func actionButton(
        icon: String,
        color: Color,
        size: CGFloat,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: size * 0.42, weight: .bold))
                .foregroundColor(color)
                .frame(width: size, height: size)
                .background(Color.white)
                .clipShape(Circle())
                .shadow(color: color.opacity(0.3), radius: 8, x: 0, y: 4)
                .overlay(Circle().stroke(color.opacity(0.2), lineWidth: 2))
        }
    }
}
