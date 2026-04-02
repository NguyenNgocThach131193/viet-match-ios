import XCTest
import Combine
@testable import VietMatch

// MARK: - Local mocks (Settings-specific)

final class MockLogoutUseCase: LogoutUseCaseProtocol {
    var logoutError: Error?
    var logoutCallCount = 0
    func execute() async throws {
        logoutCallCount += 1
        if let error = logoutError { throw error }
    }
}

final class MockDeleteAccountUseCase: DeleteAccountUseCaseProtocol {
    var deleteError: Error?
    var deleteCallCount = 0
    func execute(userId: String) async throws {
        deleteCallCount += 1
        if let error = deleteError { throw error }
    }
}

// MARK: - Tests

@MainActor
final class SettingsViewModelTests: XCTestCase {
    var sut: SettingsViewModel!
    var mockLogout: MockLogoutUseCase!
    var mockDeleteAccount: MockDeleteAccountUseCase!
    var mockProfileRepo: MockProfileRepository!
    var mockFCM: MockFCMService!
    var mockFirestore: MockFirestoreService!

    override func setUp() {
        super.setUp()
        mockLogout = MockLogoutUseCase()
        mockDeleteAccount = MockDeleteAccountUseCase()
        mockProfileRepo = MockProfileRepository()
        mockFCM = MockFCMService()
        mockFirestore = MockFirestoreService()
        sut = makeSUT(userId: "user123")
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    private func makeSUT(userId: String) -> SettingsViewModel {
        SettingsViewModel(
            currentUserId: userId,
            logoutUseCase: mockLogout,
            deleteAccountUseCase: mockDeleteAccount,
            getProfileUseCase: GetProfileUseCase(profileRepository: mockProfileRepo),
            updateProfileUseCase: UpdateProfileUseCase(profileRepository: mockProfileRepo),
            fcmService: mockFCM,
            firestoreService: mockFirestore
        )
    }

    // MARK: - Logout

    func test_logout_callsUseCase() async {
        await sut.logout()
        XCTAssertEqual(mockLogout.logoutCallCount, 1)
        XCTAssertFalse(sut.isLoading)
    }

    func test_logout_onFailure_setsErrorMessage() async {
        mockLogout.logoutError = AuthError.unknown("logout failed")
        await sut.logout()
        XCTAssertNotNil(sut.errorMessage)
        XCTAssertFalse(sut.isLoading)
    }

    // MARK: - Delete account

    func test_deleteAccount_callsUseCase() async {
        await sut.deleteAccount()
        XCTAssertEqual(mockDeleteAccount.deleteCallCount, 1)
        XCTAssertFalse(sut.isLoading)
    }

    func test_deleteAccount_onFailure_setsErrorMessage() async {
        mockDeleteAccount.deleteError = AuthError.unknown("delete failed")
        await sut.deleteAccount()
        XCTAssertNotNil(sut.errorMessage)
    }

    // MARK: - Push notification toggle

    func test_toggleNotifications_enable_requestsPermissionAndSavesToken() async {
        mockFCM.requestPermissionResult = .success(true)
        mockFCM.getFCMTokenResult = .success("fcm-token-abc")

        await sut.toggleNotifications(enabled: true)

        XCTAssertEqual(mockFCM.requestPermissionCallCount, 1)
        XCTAssertEqual(mockFCM.getFCMTokenCallCount, 1)
        XCTAssertTrue(sut.notificationsEnabled)
    }

    func test_toggleNotifications_enable_whenPermissionDenied_disablesToggle() async {
        mockFCM.requestPermissionResult = .success(false)

        await sut.toggleNotifications(enabled: true)

        XCTAssertFalse(sut.notificationsEnabled)
        XCTAssertEqual(mockFCM.getFCMTokenCallCount, 0)
    }

    func test_toggleNotifications_enable_whenFCMFails_disablesToggle() async {
        mockFCM.requestPermissionResult = .success(true)
        mockFCM.getFCMTokenResult = .failure(AuthError.unknown("FCM error"))

        await sut.toggleNotifications(enabled: true)

        XCTAssertFalse(sut.notificationsEnabled)
    }

    func test_toggleNotifications_disable_clearsTokenAndDisables() async {
        sut.notificationsEnabled = true

        await sut.toggleNotifications(enabled: false)

        XCTAssertFalse(sut.notificationsEnabled)
    }

    func test_toggleNotifications_withEmptyUserId_doesNothing() async {
        let vm = makeSUT(userId: "")

        await vm.toggleNotifications(enabled: true)

        XCTAssertEqual(mockFCM.requestPermissionCallCount, 0)
    }
}
