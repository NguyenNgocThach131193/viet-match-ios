import XCTest
@testable import VietMatch

@MainActor
final class DiscoverViewModelTests: XCTestCase {
    var sut: DiscoverViewModel!
    var mockMatchRepo: MockMatchRepository!

    override func setUp() {
        super.setUp()
        mockMatchRepo = MockMatchRepository()
        let getProfilesUseCase = GetDiscoverProfilesUseCase(matchRepository: mockMatchRepo)
        let swipeUseCase = SwipeUseCase(matchRepository: mockMatchRepo)
        sut = DiscoverViewModel(
            currentUserId: "test_user_id",
            getDiscoverProfilesUseCase: getProfilesUseCase,
            swipeUseCase: swipeUseCase
        )
    }

    override func tearDown() {
        sut = nil
        mockMatchRepo = nil
        super.tearDown()
    }

    func test_loadProfiles_success_populatesProfiles() async {
        let profiles = [
            Profile(id: "1", name: "User 1", age: 25),
            Profile(id: "2", name: "User 2", age: 28)
        ]
        mockMatchRepo.getDiscoverProfilesResult = .success(profiles)

        await sut.loadProfiles()

        XCTAssertEqual(sut.profiles.count, 2)
        XCTAssertEqual(sut.currentIndex, 0)
        XCTAssertFalse(sut.isLoading)
    }

    func test_loadProfiles_failure_setsError() async {
        mockMatchRepo.getDiscoverProfilesResult = .failure(APIError.networkError)

        await sut.loadProfiles()

        XCTAssertNotNil(sut.errorMessage)
    }

    func test_hasMoreProfiles_whenEmpty_returnsFalse() {
        XCTAssertFalse(sut.hasMoreProfiles)
    }

    func test_currentProfile_returnsCorrectProfile() async {
        let profiles = [Profile(id: "1", name: "User 1", age: 25)]
        mockMatchRepo.getDiscoverProfilesResult = .success(profiles)

        await sut.loadProfiles()

        XCTAssertEqual(sut.currentProfile?.id, "1")
    }

    func test_loadProfiles_usesInjectedUserId() async {
        mockMatchRepo.getDiscoverProfilesResult = .success([])

        await sut.loadProfiles()

        XCTAssertEqual(mockMatchRepo.lastGetDiscoverProfilesUserId, "test_user_id")
    }

}
