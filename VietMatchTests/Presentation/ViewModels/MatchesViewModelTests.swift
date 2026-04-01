import XCTest
@testable import VietMatch

@MainActor
final class MatchesViewModelTests: XCTestCase {
    var sut: MatchesViewModel!
    var mockMatchRepo: MockMatchRepository!

    override func setUp() {
        super.setUp()
        mockMatchRepo = MockMatchRepository()
        let getMatchesUseCase = GetMatchesUseCase(matchRepository: mockMatchRepo)
        sut = MatchesViewModel(
            currentUserId: "test_user_id",
            getMatchesUseCase: getMatchesUseCase
        )
    }

    override func tearDown() {
        sut = nil
        mockMatchRepo = nil
        super.tearDown()
    }

    func test_loadMatches_usesInjectedUserId() async {
        await sut.loadMatches()

        XCTAssertEqual(mockMatchRepo.lastGetMatchesUserId, "test_user_id")
        XCTAssertEqual(mockMatchRepo.getMatchesCallCount, 1)
    }

    func test_loadMatches_success_setsMatches() async {
        let match = Match(id: "match-1", userId: "test_user_id", matchedUserId: "other_user")
        mockMatchRepo.getMatchesResult = .success([match])

        await sut.loadMatches()

        XCTAssertEqual(sut.matches.count, 1)
        XCTAssertFalse(sut.isLoading)
        XCTAssertNil(sut.errorMessage)
    }

    func test_loadMatches_failure_setsErrorMessage() async {
        mockMatchRepo.getMatchesResult = .failure(NSError(domain: "test", code: 1, userInfo: [NSLocalizedDescriptionKey: "Network error"]))

        await sut.loadMatches()

        XCTAssertNotNil(sut.errorMessage)
        XCTAssertFalse(sut.isLoading)
    }

    func test_currentUserId_isAccessible() {
        XCTAssertEqual(sut.currentUserId, "test_user_id")
    }
}
