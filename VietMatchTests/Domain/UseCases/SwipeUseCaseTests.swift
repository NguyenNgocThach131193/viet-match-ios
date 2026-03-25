import XCTest
@testable import VietMatch

final class SwipeUseCaseTests: XCTestCase {
    var sut: SwipeUseCase!
    var mockMatchRepo: MockMatchRepository!

    override func setUp() {
        super.setUp()
        mockMatchRepo = MockMatchRepository()
        sut = SwipeUseCase(matchRepository: mockMatchRepo)
    }

    override func tearDown() {
        sut = nil
        mockMatchRepo = nil
        super.tearDown()
    }

    func test_swipeLike_callsRepository() async throws {
        _ = try await sut.execute(swiperId: "user1", swipedUserId: "user2", direction: .like)
        XCTAssertEqual(mockMatchRepo.swipeCallCount, 1)
    }

    func test_swipeLike_whenMatch_returnsMatch() async throws {
        let expectedMatch = Match(id: "m1", userId: "user1", matchedUserId: "user2")
        mockMatchRepo.swipeResult = .success(expectedMatch)

        let match = try await sut.execute(swiperId: "user1", swipedUserId: "user2", direction: .like)

        XCTAssertNotNil(match)
        XCTAssertEqual(match?.id, "m1")
    }

    func test_swipeDislike_returnsNil() async throws {
        mockMatchRepo.swipeResult = .success(nil)

        let match = try await sut.execute(swiperId: "user1", swipedUserId: "user2", direction: .dislike)

        XCTAssertNil(match)
    }
}
