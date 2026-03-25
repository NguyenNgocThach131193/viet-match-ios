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

        await sut.loadProfiles(userId: "me")

        XCTAssertEqual(sut.profiles.count, 2)
        XCTAssertEqual(sut.currentIndex, 0)
        XCTAssertFalse(sut.isLoading)
    }

    func test_loadProfiles_failure_setsError() async {
        mockMatchRepo.getDiscoverProfilesResult = .failure(APIError.networkError)

        await sut.loadProfiles(userId: "me")

        XCTAssertNotNil(sut.errorMessage)
    }

    func test_hasMoreProfiles_whenEmpty_returnsFalse() {
        XCTAssertFalse(sut.hasMoreProfiles)
    }

    func test_currentProfile_returnsCorrectProfile() async {
        let profiles = [Profile(id: "1", name: "User 1", age: 25)]
        mockMatchRepo.getDiscoverProfilesResult = .success(profiles)

        await sut.loadProfiles(userId: "me")

        XCTAssertEqual(sut.currentProfile?.id, "1")
    }
}
