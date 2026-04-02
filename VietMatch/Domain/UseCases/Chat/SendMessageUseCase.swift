import Foundation

protocol SendMessageUseCaseProtocol {
    func execute(matchId: String, senderId: String, content: String, type: MessageType) async throws -> Message
    func executeWithImage(matchId: String, senderId: String, imageData: Data) async throws -> Message
}

final class SendMessageUseCase: SendMessageUseCaseProtocol {
    private let chatRepository: ChatRepositoryProtocol

    init(chatRepository: ChatRepositoryProtocol) {
        self.chatRepository = chatRepository
    }

    func execute(matchId: String, senderId: String, content: String, type: MessageType = .text) async throws -> Message {
        guard !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw ChatError.emptyMessage
        }
        return try await chatRepository.sendMessage(
            matchId: matchId,
            senderId: senderId,
            content: content,
            type: type
        )
    }

    func executeWithImage(matchId: String, senderId: String, imageData: Data) async throws -> Message {
        guard !imageData.isEmpty else { throw ChatError.emptyMessage }
        return try await chatRepository.sendImageMessage(
            matchId: matchId,
            senderId: senderId,
            imageData: imageData
        )
    }
}

enum ChatError: LocalizedError {
    case emptyMessage
    case matchNotFound
    case sendFailed

    var errorDescription: String? {
        switch self {
        case .emptyMessage: return "Tin nhắn không được để trống"
        case .matchNotFound: return "Không tìm thấy cuộc trò chuyện"
        case .sendFailed: return "Gửi tin nhắn thất bại"
        }
    }
}
