import XCTest
@testable import VietMatch

@MainActor
final class ProfileDetailViewModelTests: XCTestCase {
    var sut: ProfileDetailViewModel!
    var mockProfileRepo: MockProfileRepository!
    var mockMatchRepo: MockMatchRepository!

    override func setUp() {
        super.setUp()
        mockProfileRepo = MockProfileRepository()
        mockMatchRepo = MockMatchRepository()
        let getProfileUseCase = GetProfileUseCase(profileRepository: mockProfileRepo)
        let swipeUseCase = SwipeUseCase(matchRepository: mockMatchRepo)
        sut = ProfileDetailViewModel(
            profileId: "profile-1",
            currentUserId: "me",
            getProfileUseCase: getProfileUseCase,
            swipeUseCase: swipeUseCase
        )
    }

    override func tearDown() {
        sut = nil
        mockProfileRepo = nil
        mockMatchRepo = nil
        super.tearDown()
    }

    func test_loadProfile_success_setsProfile() async {
        let expectedProfile = Profile(id: "profile-1", name: "Nguyen Van A", age: 25)
        mockProfileRepo.getProfileResult = .success(expectedProfile)

        await sut.loadProfile()

        XCTAssertEqual(sut.profile?.id, "profile-1")
        XCTAssertEqual(sut.profile?.name, "Nguyen Van A")
        XCTAssertFalse(sut.isLoading)
        XCTAssertNil(sut.errorMessage)
    }

    func test_loadProfile_failure_setsErrorMessage() async {
        mockProfileRepo.getProfileResult = .failure(APIError.networkError)

        await sut.loadProfile()

        XCTAssertNil(sut.profile)
        XCTAssertNotNil(sut.errorMessage)
        XCTAssertFalse(sut.isLoading)
    }

    func test_swipe_like_noMatch_doesNotShowAlert() async {
        let profile = Profile(id: "profile-1", name: "Test", age: 25)
        mockProfileRepo.getProfileResult = .success(profile)
        await sut.loadProfile()

        mockMatchRepo.swipeResult = .success(nil)
        await sut.like()

        XCTAssertFalse(sut.showMatchAlert)
        XCTAssertNil(sut.matchedProfile)
    }

    func test_swipe_like_withMatch_showsMatchAlert() async {
        let profile = Profile(id: "profile-1", name: "Test", age: 25)
        mockProfileRepo.getProfileResult = .success(profile)
        await sut.loadProfile()

        let match = Match(id: "match-1", userId: "me", matchedUserId: "profile-1")
        mockMatchRepo.swipeResult = .success(match)
        await sut.like()

        XCTAssertTrue(sut.showMatchAlert)
        XCTAssertEqual(sut.matchedProfile?.id, "profile-1")
    }

    func test_swipe_dislike_callsSwipeUseCase() async {
        let profile = Profile(id: "profile-1", name: "Test", age: 25)
        mockProfileRepo.getProfileResult = .success(profile)
        await sut.loadProfile()

        mockMatchRepo.swipeResult = .success(nil)
        await sut.dislike()

        XCTAssertEqual(mockMatchRepo.swipeCallCount, 1)
    }

    func test_swipe_superLike_callsSwipeUseCase() async {
        let profile = Profile(id: "profile-1", name: "Test", age: 25)
        mockProfileRepo.getProfileResult = .success(profile)
        await sut.loadProfile()

        mockMatchRepo.swipeResult = .success(nil)
        await sut.superLike()

        XCTAssertEqual(mockMatchRepo.swipeCallCount, 1)
    }

    func test_swipe_beforeProfileLoaded_doesNothing() async {
        mockMatchRepo.swipeResult = .success(nil)
        await sut.like()

        XCTAssertEqual(mockMatchRepo.swipeCallCount, 0)
    }

    // MARK: - Concurrency Guard Tests (Story 1-8)

    func test_swipe_setsIsSwipingDuringExecution() async {
        let profile = Profile(id: "profile-1", name: "Test", age: 25)
        mockProfileRepo.getProfileResult = .success(profile)
        await sut.loadProfile()

        mockMatchRepo.swipeDelay = 100_000_000 // 100ms
        mockMatchRepo.swipeResult = .success(nil)

        XCTAssertFalse(sut.isSwiping)

        let task = Task { await sut.like() }
        try? await Task.sleep(nanoseconds: 10_000_000) // 10ms — let swipe start

        XCTAssertTrue(sut.isSwiping)

        await task.value
        XCTAssertFalse(sut.isSwiping)
    }

    func test_swipe_concurrentCallsBlocked() async {
        let profile = Profile(id: "profile-1", name: "Test", age: 25)
        mockProfileRepo.getProfileResult = .success(profile)
        await sut.loadProfile()

        mockMatchRepo.swipeDelay = 100_000_000 // 100ms
        mockMatchRepo.swipeResult = .success(nil)

        let task1 = Task { await sut.like() }
        try? await Task.sleep(nanoseconds: 10_000_000) // 10ms

        // Second call should be blocked by guard
        await sut.dislike()

        await task1.value

        // Only first swipe should have executed
        XCTAssertEqual(mockMatchRepo.swipeCallCount, 1)
    }

    func test_isSwiping_resetsAfterError() async {
        let profile = Profile(id: "profile-1", name: "Test", age: 25)
        mockProfileRepo.getProfileResult = .success(profile)
        await sut.loadProfile()

        mockMatchRepo.swipeResult = .failure(APIError.networkError)

        await sut.like()

        XCTAssertFalse(sut.isSwiping)
    }
}
