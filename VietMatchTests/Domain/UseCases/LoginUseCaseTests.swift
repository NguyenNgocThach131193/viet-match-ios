import XCTest
@testable import VietMatch

final class LoginUseCaseTests: XCTestCase {
    var sut: LoginUseCase!
    var mockAuthRepo: MockAuthRepository!

    override func setUp() {
        super.setUp()
        mockAuthRepo = MockAuthRepository()
        sut = LoginUseCase(authRepository: mockAuthRepo)
    }

    override func tearDown() {
        sut = nil
        mockAuthRepo = nil
        super.tearDown()
    }

    func test_login_withValidCredentials_returnsUser() async throws {
        let expectedUser = User(id: "1", email: "test@test.com", displayName: "Test")
        mockAuthRepo.loginResult = .success(expectedUser)

        let user = try await sut.execute(email: "test@test.com", password: "password123")

        XCTAssertEqual(user.email, "test@test.com")
        XCTAssertEqual(mockAuthRepo.loginCallCount, 1)
    }

    func test_login_withEmptyEmail_throwsError() async {
        do {
            _ = try await sut.execute(email: "", password: "password123")
            XCTFail("Expected error")
        } catch {
            XCTAssertTrue(error is AuthError)
        }
    }

    func test_login_withEmptyPassword_throwsError() async {
        do {
            _ = try await sut.execute(email: "test@test.com", password: "")
            XCTFail("Expected error")
        } catch {
            XCTAssertTrue(error is AuthError)
        }
    }

    func test_login_whenRepoFails_throwsError() async {
        mockAuthRepo.loginResult = .failure(AuthError.userNotFound)

        do {
            _ = try await sut.execute(email: "test@test.com", password: "password123")
            XCTFail("Expected error")
        } catch {
            XCTAssertEqual(error as? AuthError, .userNotFound)
        }
    }
}
