import XCTest
@testable import VietMatch

@MainActor
final class ForgotPasswordViewModelTests: XCTestCase {
    var sut: ForgotPasswordViewModel!
    var mockAuthRepo: MockAuthRepository!

    override func setUp() {
        super.setUp()
        mockAuthRepo = MockAuthRepository()
        let resetPasswordUseCase = ResetPasswordUseCase(authRepository: mockAuthRepo)
        sut = ForgotPasswordViewModel(resetPasswordUseCase: resetPasswordUseCase)
    }

    override func tearDown() {
        sut = nil
        mockAuthRepo = nil
        super.tearDown()
    }

    // MARK: - Validation Tests

    func test_isEmailValid_withValidEmail_returnsTrue() {
        sut.email = "test@test.com"
        XCTAssertTrue(sut.isEmailValid)
    }

    func test_isEmailValid_withInvalidEmail_returnsFalse() {
        sut.email = "invalid"
        XCTAssertFalse(sut.isEmailValid)
    }

    func test_isEmailValid_withEmptyEmail_returnsFalse() {
        sut.email = ""
        XCTAssertFalse(sut.isEmailValid)
    }

    // MARK: - Reset Password Tests

    func test_resetPassword_withEmptyEmail_showsError() async {
        sut.email = ""

        await sut.resetPassword()

        XCTAssertTrue(sut.showError)
        XCTAssertEqual(sut.errorMessage, "Vui lòng nhập email")
        XCTAssertFalse(sut.showSuccess)
        XCTAssertFalse(sut.isLoading)
        XCTAssertEqual(mockAuthRepo.resetPasswordCallCount, 0)
    }

    func test_resetPassword_withInvalidEmail_showsError() async {
        sut.email = "invalid-email"

        await sut.resetPassword()

        XCTAssertTrue(sut.showError)
        XCTAssertEqual(sut.errorMessage, "Email không đúng định dạng")
        XCTAssertFalse(sut.showSuccess)
        XCTAssertFalse(sut.isLoading)
        XCTAssertEqual(mockAuthRepo.resetPasswordCallCount, 0)
    }

    func test_resetPassword_withWhitespaceOnlyEmail_showsError() async {
        sut.email = "   "

        await sut.resetPassword()

        XCTAssertTrue(sut.showError)
        XCTAssertEqual(sut.errorMessage, "Vui lòng nhập email")
        XCTAssertFalse(sut.showSuccess)
        XCTAssertEqual(mockAuthRepo.resetPasswordCallCount, 0)
    }

    func test_resetPassword_success_showsSuccessMessage() async {
        sut.email = "test@test.com"

        await sut.resetPassword()

        XCTAssertTrue(sut.showSuccess)
        XCTAssertNotNil(sut.successMessage)
        XCTAssertNil(sut.errorMessage)
        XCTAssertFalse(sut.showError)
        XCTAssertFalse(sut.isLoading)
        XCTAssertEqual(mockAuthRepo.resetPasswordCallCount, 1)
    }

    func test_resetPassword_failure_showsError() async {
        sut.email = "test@test.com"
        mockAuthRepo.resetPasswordError = AuthError.userNotFound

        await sut.resetPassword()

        XCTAssertTrue(sut.showError)
        XCTAssertNotNil(sut.errorMessage)
        XCTAssertFalse(sut.showSuccess)
        XCTAssertFalse(sut.isLoading)
        XCTAssertEqual(mockAuthRepo.resetPasswordCallCount, 1)
    }

    func test_resetPassword_withEmailWithSpaces_trimsBefore() async {
        sut.email = "  test@test.com  "

        await sut.resetPassword()

        XCTAssertTrue(sut.showSuccess)
        XCTAssertEqual(mockAuthRepo.resetPasswordCallCount, 1)
    }

    func test_resetPassword_whileLoading_isIgnored() async {
        sut.email = "test@test.com"
        sut.isLoading = true

        await sut.resetPassword()

        XCTAssertEqual(mockAuthRepo.resetPasswordCallCount, 0)
    }

    func test_resetPassword_networkError_showsError() async {
        sut.email = "test@test.com"
        mockAuthRepo.resetPasswordError = AuthError.unknown("Lỗi kết nối mạng")

        await sut.resetPassword()

        XCTAssertTrue(sut.showError)
        XCTAssertEqual(sut.errorMessage, "Lỗi kết nối mạng")
        XCTAssertFalse(sut.isLoading)
    }
}
