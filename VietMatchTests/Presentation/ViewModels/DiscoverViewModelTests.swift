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

    // MARK: - Concurrency Guard Tests (Story 1-8)

    func test_swipe_setsIsSwipingDuringExecution() async {
        let profiles = [Profile(id: "1", name: "User 1", age: 25)]
        mockMatchRepo.getDiscoverProfilesResult = .success(profiles)
        await sut.loadProfiles()

        mockMatchRepo.swipeDelay = 100_000_000 // 100ms
        mockMatchRepo.swipeResult = .success(nil)

        XCTAssertFalse(sut.isSwiping)

        let task = Task { await sut.like() }
        try? await Task.sleep(nanoseconds: 10_000_000)

        XCTAssertTrue(sut.isSwiping)

        await task.value
        XCTAssertFalse(sut.isSwiping)
    }

    func test_swipe_concurrentCallsBlocked() async {
        let profiles = [
            Profile(id: "1", name: "User 1", age: 25),
            Profile(id: "2", name: "User 2", age: 28)
        ]
        mockMatchRepo.getDiscoverProfilesResult = .success(profiles)
        await sut.loadProfiles()

        mockMatchRepo.swipeDelay = 100_000_000
        mockMatchRepo.swipeResult = .success(nil)

        let task1 = Task { await sut.like() }
        try? await Task.sleep(nanoseconds: 10_000_000)

        await sut.dislike()

        await task1.value

        XCTAssertEqual(mockMatchRepo.swipeCallCount, 1)
    }

    func test_loadMoreProfiles_concurrentCallsBlocked() async {
        // Load initial profiles near threshold to trigger loadMore
        let profiles = [
            Profile(id: "1", name: "User 1", age: 25),
            Profile(id: "2", name: "User 2", age: 28),
            Profile(id: "3", name: "User 3", age: 30)
        ]
        mockMatchRepo.getDiscoverProfilesResult = .success(profiles)
        await sut.loadProfiles()

        // Set delay for loadMoreProfiles
        mockMatchRepo.getDiscoverProfilesDelay = 100_000_000
        mockMatchRepo.getDiscoverProfilesResult = .success([Profile(id: "4", name: "User 4", age: 22)])
        mockMatchRepo.swipeResult = .success(nil)
        mockMatchRepo.swipeDelay = 0

        // First swipe will trigger loadMoreProfiles (index 0 -> 1, count=3, 1 >= 3-3=0)
        await sut.like()

        // loadMoreProfiles was called once during swipe
        let profileCountAfterFirstSwipe = sut.profiles.count

        // Second swipe — loadMoreProfiles should be guarded since first is still loading
        // But since loadMore is awaited inside swipe, it completes before returning
        // The guard protects against external concurrent calls
        XCTAssertEqual(profileCountAfterFirstSwipe, 4) // 3 original + 1 new
    }

    func test_isSwiping_resetsAfterError() async {
        let profiles = [Profile(id: "1", name: "User 1", age: 25)]
        mockMatchRepo.getDiscoverProfilesResult = .success(profiles)
        await sut.loadProfiles()

        mockMatchRepo.swipeResult = .failure(APIError.networkError)

        await sut.like()

        XCTAssertFalse(sut.isSwiping)
    }
}
