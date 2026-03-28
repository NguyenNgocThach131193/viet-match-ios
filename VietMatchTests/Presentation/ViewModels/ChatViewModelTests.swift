import XCTest
import Combine
@testable import VietMatch

// MARK: - Mocks

final class MockGetMessagesUseCase: GetMessagesUseCaseProtocol {
    var executeResult: Result<[Message], Error> = .success([])
    var executeCallCount = 0
    var lastMatchId: String?

    private let messagesSubject = PassthroughSubject<[Message], Error>()

    func execute(matchId: String, limit: Int, before: Date?) async throws -> [Message] {
        executeCallCount += 1
        lastMatchId = matchId
        return try executeResult.get()
    }

    func observe(matchId: String) -> AnyPublisher<[Message], Error> {
        messagesSubject.eraseToAnyPublisher()
    }
}

final class MockSendMessageUseCase: SendMessageUseCaseProtocol {
    var executeResult: Result<Message, Error> = .success(
        Message(id: "msg1", matchId: "match1", senderId: "user123", content: "Hello")
    )
    var executeCallCount = 0
    var lastSenderId: String?
    var lastContent: String?
    var lastMatchId: String?

    func execute(matchId: String, senderId: String, content: String, type: MessageType) async throws -> Message {
        executeCallCount += 1
        lastMatchId = matchId
        lastSenderId = senderId
        lastContent = content
        return try executeResult.get()
    }
}

// MARK: - Tests

@MainActor
final class ChatViewModelTests: XCTestCase {
    var sut: ChatViewModel!
    var mockGetMessages: MockGetMessagesUseCase!
    var mockSendMessage: MockSendMessageUseCase!

    override func setUp() {
        super.setUp()
        mockGetMessages = MockGetMessagesUseCase()
        mockSendMessage = MockSendMessageUseCase()
        sut = ChatViewModel(
            matchId: "match1",
            currentUserId: "user123",
            getMessagesUseCase: mockGetMessages,
            sendMessageUseCase: mockSendMessage
        )
    }

    override func tearDown() {
        sut = nil
        mockGetMessages = nil
        mockSendMessage = nil
        super.tearDown()
    }

    func test_currentUserId_isSetFromInit() {
        XCTAssertEqual(sut.currentUserId, "user123")
    }

    func test_sendMessage_usesTrueCurrentUserId() async {
        sut.messageText = "Xin chào"
        let sentMessage = Message(id: "msg1", matchId: "match1", senderId: "user123", content: "Xin chào")
        mockSendMessage.executeResult = .success(sentMessage)

        await sut.sendMessage()

        XCTAssertEqual(mockSendMessage.lastSenderId, "user123")
        XCTAssertNotEqual(mockSendMessage.lastSenderId, "current_user_id")
    }

    func test_sendMessage_appendsMessageToList() async {
        sut.messageText = "Hello"
        let sentMessage = Message(id: "msg1", matchId: "match1", senderId: "user123", content: "Hello")
        mockSendMessage.executeResult = .success(sentMessage)

        await sut.sendMessage()

        XCTAssertEqual(sut.messages.count, 1)
        XCTAssertEqual(sut.messages.first?.senderId, "user123")
    }

    func test_isFromCurrentUser_returnsTrueForOwnMessage() {
        let message = Message(id: "m1", matchId: "match1", senderId: "user123", content: "Hi")
        XCTAssertTrue(sut.isFromCurrentUser(message))
    }

    func test_isFromCurrentUser_returnsFalseForOtherUserMessage() {
        let message = Message(id: "m2", matchId: "match1", senderId: "other_user", content: "Hey")
        XCTAssertFalse(sut.isFromCurrentUser(message))
    }

    func test_sendMessage_withEmptyText_doesNotCallUseCase() async {
        sut.messageText = ""

        await sut.sendMessage()

        XCTAssertEqual(mockSendMessage.executeCallCount, 0)
    }

    func test_sendMessage_clearsMessageTextAfterSend() async {
        sut.messageText = "Test message"
        let sentMessage = Message(id: "msg1", matchId: "match1", senderId: "user123", content: "Test message")
        mockSendMessage.executeResult = .success(sentMessage)

        await sut.sendMessage()

        XCTAssertEqual(sut.messageText, "")
    }

    func test_sendMessage_onFailure_restoresMessageText() async {
        sut.messageText = "Test message"
        mockSendMessage.executeResult = .failure(ChatError.sendFailed)

        await sut.sendMessage()

        XCTAssertEqual(sut.messageText, "Test message")
        XCTAssertNotNil(sut.errorMessage)
    }
}
