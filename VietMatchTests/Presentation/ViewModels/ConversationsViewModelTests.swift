import XCTest
@testable import VietMatch

@MainActor
final class ConversationsViewModelTests: XCTestCase {
    var sut: ConversationsViewModel!
    var mockChatRepo: TestMockChatRepository!

    override func setUp() {
        super.setUp()
        mockChatRepo = TestMockChatRepository()
        let getConversationsUseCase = GetConversationsUseCase(chatRepository: mockChatRepo)
        sut = ConversationsViewModel(
            currentUserId: "test_user_id",
            getConversationsUseCase: getConversationsUseCase
        )
    }

    override func tearDown() {
        sut = nil
        mockChatRepo = nil
        super.tearDown()
    }

    func test_loadConversations_usesInjectedUserId() async {
        await sut.loadConversations()

        XCTAssertEqual(mockChatRepo.lastGetConversationsUserId, "test_user_id")
        XCTAssertEqual(mockChatRepo.getConversationsCallCount, 1)
    }

    func test_loadConversations_success_setsConversations() async {
        mockChatRepo.getConversationsResult = .success([])

        await sut.loadConversations()

        XCTAssertFalse(sut.isLoading)
        XCTAssertNil(sut.errorMessage)
    }

    func test_loadConversations_failure_setsErrorMessage() async {
        mockChatRepo.getConversationsResult = .failure(NSError(domain: "test", code: 1, userInfo: [NSLocalizedDescriptionKey: "Network error"]))

        await sut.loadConversations()

        XCTAssertNotNil(sut.errorMessage)
        XCTAssertFalse(sut.isLoading)
    }

    func test_currentUserId_isAccessible() {
        XCTAssertEqual(sut.currentUserId, "test_user_id")
    }
}
