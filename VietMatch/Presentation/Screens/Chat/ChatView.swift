import SwiftUI

struct ChatView: View {
    @ObservedObject var viewModel: ChatViewModel

    var body: some View {
        VStack(spacing: 0) {
            // Messages
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: VietMatchSpacing.sm) {
                        ForEach(viewModel.messages) { message in
                            MessageBubbleView(
                                message: message,
                                isFromCurrentUser: viewModel.isFromCurrentUser(message)
                            )
                            .id(message.id)
                        }
                    }
                    .padding(.horizontal, VietMatchSpacing.lg)
                    .padding(.vertical, VietMatchSpacing.md)
                }
                .onChange(of: viewModel.messages.count) { _, _ in
                    if let lastId = viewModel.messages.last?.id {
                        withAnimation {
                            proxy.scrollTo(lastId, anchor: .bottom)
                        }
                    }
                }
            }

            Divider()

            // Input bar
            messageInputBar
        }
        .background(VietMatchColors.background.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.loadMessages()
            viewModel.observeMessages()
        }
    }

    private var messageInputBar: some View {
        HStack(spacing: VietMatchSpacing.md) {
            TextField("Nhập tin nhắn...", text: $viewModel.messageText, axis: .vertical)
                .textFieldStyle(.plain)
                .lineLimit(1...4)
                .padding(.horizontal, VietMatchSpacing.lg)
                .padding(.vertical, VietMatchSpacing.sm)
                .background(Color.gray.opacity(0.1))
                .clipShape(Capsule())

            Button {
                Task { await viewModel.sendMessage() }
            } label: {
                Image(systemName: "paperplane.fill")
                    .font(.title3)
                    .foregroundColor(viewModel.messageText.trimmed.isEmpty ? .gray : VietMatchColors.primary)
                    .rotationEffect(.degrees(45))
            }
            .disabled(viewModel.messageText.trimmed.isEmpty || viewModel.isSending)
        }
        .padding(.horizontal, VietMatchSpacing.lg)
        .padding(.vertical, VietMatchSpacing.md)
        .background(Color.white)
    }
}
