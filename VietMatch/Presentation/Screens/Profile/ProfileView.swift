import SwiftUI
import Kingfisher

struct ProfileView: View {
    @ObservedObject var viewModel: ProfileViewModel
    var coordinator: ProfileCoordinator

    var body: some View {
        ScrollView {
            VStack(spacing: VietMatchSpacing.xl) {
                // Profile photo
                profilePhotoSection

                // Info
                if let profile = viewModel.profile {
                    profileInfoSection(profile)
                }

                // Actions
                actionsSection
            }
            .padding(.horizontal, VietMatchSpacing.xl)
            .padding(.top, VietMatchSpacing.lg)
        }
        .background(VietMatchColors.background.ignoresSafeArea())
        .navigationTitle("Hồ sơ")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    coordinator.showSettings()
                } label: {
                    Image(systemName: "gearshape.fill")
                        .foregroundColor(VietMatchColors.textSecondary)
                }
            }
        }
        .task {
            await viewModel.loadProfile(userId: "current_user_id")
        }
    }

    private var profilePhotoSection: some View {
        ZStack(alignment: .bottomTrailing) {
            if let photoURL = viewModel.profile?.photos.first,
               let url = URL(string: photoURL) {
                KFImage(url)
                    .resizable()
                    .scaledToFill()
                    .frame(width: VietMatchSpacing.avatarLarge, height: VietMatchSpacing.avatarLarge)
                    .clipShape(Circle())
            } else {
                Circle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: VietMatchSpacing.avatarLarge, height: VietMatchSpacing.avatarLarge)
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.gray)
                    )
            }

            Button {
                coordinator.showEditProfile()
            } label: {
                Image(systemName: "pencil.circle.fill")
                    .font(.title2)
                    .foregroundColor(VietMatchColors.primary)
                    .background(Circle().fill(Color.white))
            }
        }
    }

    private func profileInfoSection(_ profile: Profile) -> some View {
        VStack(spacing: VietMatchSpacing.md) {
            Text("\(profile.name), \(profile.age)")
                .font(VietMatchTypography.title2)
                .foregroundColor(VietMatchColors.textPrimary)

            if let jobTitle = profile.jobTitle {
                Label(jobTitle, systemImage: "briefcase.fill")
                    .font(VietMatchTypography.body)
                    .foregroundColor(VietMatchColors.textSecondary)
            }

            if let city = profile.location?.city {
                Label(city, systemImage: "mappin.and.ellipse")
                    .font(VietMatchTypography.body)
                    .foregroundColor(VietMatchColors.textSecondary)
            }

            if !profile.bio.isEmpty {
                Text(profile.bio)
                    .font(VietMatchTypography.body)
                    .foregroundColor(VietMatchColors.textPrimary)
                    .multilineTextAlignment(.center)
                    .padding(.top, VietMatchSpacing.sm)
            }

            if !profile.interests.isEmpty {
                FlowLayout(spacing: VietMatchSpacing.sm) {
                    ForEach(profile.interests, id: \.self) { interest in
                        Text(interest)
                            .font(VietMatchTypography.caption)
                            .padding(.horizontal, VietMatchSpacing.md)
                            .padding(.vertical, VietMatchSpacing.xs)
                            .background(VietMatchColors.primary.opacity(0.1))
                            .foregroundColor(VietMatchColors.primary)
                            .clipShape(Capsule())
                    }
                }
                .padding(.top, VietMatchSpacing.sm)
            }
        }
    }

    private var actionsSection: some View {
        VStack(spacing: VietMatchSpacing.md) {
            Button {
                coordinator.showEditProfile()
            } label: {
                Text("Chỉnh sửa hồ sơ")
                    .primaryButtonStyle()
            }

            Button {
                coordinator.showSettings()
            } label: {
                Text("Cài đặt")
                    .secondaryButtonStyle()
            }
        }
        .padding(.top, VietMatchSpacing.lg)
    }
}
