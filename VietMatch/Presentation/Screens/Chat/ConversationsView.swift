import SwiftUI
import Kingfisher

struct ConversationsView: View {
    @ObservedObject var viewModel: ConversationsViewModel
    var coordinator: ChatCoordinator

    var body: some View {
        List {
            ForEach(viewModel.conversations) { conversation in
                Button {
                    coordinator.showChat(matchId: conversation.id)
                } label: {
                    conversationRow(conversation)
                }
            }
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
        }
        .listStyle(.plain)
        .background(VietMatchColors.background.ignoresSafeArea())
        .navigationTitle("Tin nhắn")
        .overlay {
            if viewModel.isLoading {
                LoadingView()
            } else if viewModel.conversations.isEmpty {
                EmptyStateView(
                    icon: "message",
                    title: "Chưa có tin nhắn",
                    message: "Match với ai đó rồi bắt đầu trò chuyện!"
                )
            }
        }
        .task {
            await viewModel.loadConversations(userId: "current_user_id")
        }
    }

    private func conversationRow(_ conversation: Conversation) -> some View {
        HStack(spacing: VietMatchSpacing.md) {
            // Avatar
            if let photoURL = conversation.match.matchedProfile?.photos.first,
               let url = URL(string: photoURL) {
                KFImage(url)
                    .resizable()
                    .scaledToFill()
                    .frame(width: VietMatchSpacing.avatarMedium, height: VietMatchSpacing.avatarMedium)
                    .clipShape(Circle())
            } else {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: VietMatchSpacing.avatarMedium, height: VietMatchSpacing.avatarMedium)
                    .overlay(
                        Image(systemName: "person.fill")
                            .foregroundColor(.gray)
                    )
            }

            VStack(alignment: .leading, spacing: VietMatchSpacing.xxs) {
                Text(conversation.match.matchedProfile?.name ?? "Người dùng")
                    .font(VietMatchTypography.headline)
                    .foregroundColor(VietMatchColors.textPrimary)

                Text(conversation.lastMessage?.content ?? "Bắt đầu trò chuyện")
                    .font(VietMatchTypography.subheadline)
                    .foregroundColor(VietMatchColors.textSecondary)
                    .lineLimit(1)
            }

            Spacer()

            if conversation.unreadCount > 0 {
                Text("\(conversation.unreadCount)")
                    .font(VietMatchTypography.caption)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(VietMatchColors.primary)
                    .clipShape(Capsule())
            }
        }
        .padding(VietMatchSpacing.md)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .cardShadow()
    }
}
