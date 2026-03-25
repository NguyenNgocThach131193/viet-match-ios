import XCTest
@testable import VietMatch

@MainActor
final class LoginViewModelTests: XCTestCase {
    var sut: LoginViewModel!
    var mockAuthRepo: MockAuthRepository!

    override func setUp() {
        super.setUp()
        mockAuthRepo = MockAuthRepository()
        let loginUseCase = LoginUseCase(authRepository: mockAuthRepo)
        sut = LoginViewModel(loginUseCase: loginUseCase)
    }

    override func tearDown() {
        sut = nil
        mockAuthRepo = nil
        super.tearDown()
    }

    func test_isFormValid_withValidInputs_returnsTrue() {
        sut.email = "test@test.com"
        sut.password = "password123"
        XCTAssertTrue(sut.isFormValid)
    }

    func test_isFormValid_withInvalidEmail_returnsFalse() {
        sut.email = "invalid"
        sut.password = "password123"
        XCTAssertFalse(sut.isFormValid)
    }

    func test_isFormValid_withShortPassword_returnsFalse() {
        sut.email = "test@test.com"
        sut.password = "12345"
        XCTAssertFalse(sut.isFormValid)
    }

    func test_login_success_clearsError() async {
        sut.email = "test@test.com"
        sut.password = "password123"
        mockAuthRepo.loginResult = .success(User(id: "1", email: "test@test.com", displayName: "Test"))

        await sut.login()

        XCTAssertNil(sut.errorMessage)
        XCTAssertFalse(sut.isLoading)
    }

    func test_login_failure_setsError() async {
        sut.email = "test@test.com"
        sut.password = "password123"
        mockAuthRepo.loginResult = .failure(AuthError.userNotFound)

        await sut.login()

        XCTAssertNotNil(sut.errorMessage)
        XCTAssertTrue(sut.showError)
        XCTAssertFalse(sut.isLoading)
    }
}
