import PhotosUI
import SwiftUI

struct ChatView: View {
    @ObservedObject var viewModel: ChatViewModel
    @State private var selectedPhotoItem: PhotosPickerItem?

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
            PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                Image(systemName: "photo")
                    .font(.title3)
                    .foregroundColor(viewModel.isSending ? .gray : VietMatchColors.primary)
            }
            .disabled(viewModel.isSending)
            .onChange(of: selectedPhotoItem) { _, newItem in
                guard let newItem else { return }
                Task {
                    if let data = try? await newItem.loadTransferable(type: Data.self) {
                        await viewModel.sendPhoto(imageData: data)
                    }
                    selectedPhotoItem = nil
                }
            }

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
