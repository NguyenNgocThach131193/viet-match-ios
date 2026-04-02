import Foundation
import Combine

@MainActor
final class ChatViewModel: ObservableObject {
    @Published var messages: [Message] = []
    @Published var messageText = ""
    @Published var isLoading = false
    @Published var isSending = false
    @Published var errorMessage: String?

    let matchId: String
    private let getMessagesUseCase: GetMessagesUseCaseProtocol
    private let sendMessageUseCase: SendMessageUseCaseProtocol
    private var cancellables = Set<AnyCancellable>()
    let currentUserId: String

    init(
        matchId: String,
        currentUserId: String,
        getMessagesUseCase: GetMessagesUseCaseProtocol,
        sendMessageUseCase: SendMessageUseCaseProtocol
    ) {
        self.matchId = matchId
        self.currentUserId = currentUserId
        self.getMessagesUseCase = getMessagesUseCase
        self.sendMessageUseCase = sendMessageUseCase
    }

    func loadMessages() async {
        isLoading = true
        do {
            messages = try await getMessagesUseCase.execute(matchId: matchId, limit: 50, before: nil)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func observeMessages() {
        getMessagesUseCase.observe(matchId: matchId)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] messages in
                self?.messages = messages
            }
            .store(in: &cancellables)
    }

    func sendMessage() async {
        let text = messageText.trimmed
        guard !text.isEmpty else { return }

        messageText = ""
        isSending = true

        do {
            let message = try await sendMessageUseCase.execute(
                matchId: matchId,
                senderId: currentUserId,
                content: text,
                type: .text
            )
            messages.append(message)
        } catch {
            errorMessage = error.localizedDescription
            messageText = text
        }
        isSending = false
    }

    func isFromCurrentUser(_ message: Message) -> Bool {
        message.senderId == currentUserId
    }

    func sendPhoto(imageData: Data) async {
        guard !isSending else { return }
        isSending = true
        do {
            let message = try await sendMessageUseCase.executeWithImage(
                matchId: matchId,
                senderId: currentUserId,
                imageData: imageData
            )
            messages.append(message)
        } catch {
            errorMessage = error.localizedDescription
        }
        isSending = false
    }

    func loadMoreMessages() async {
        guard let oldest = messages.first else { return }
        do {
            let olderMessages = try await getMessagesUseCase.execute(
                matchId: matchId,
                limit: 50,
                before: oldest.createdAt
            )
            messages.insert(contentsOf: olderMessages, at: 0)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
