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

    // MARK: - Apple Sign-In

    func test_executeWithApple_success_returnsUser() async throws {
        let expectedUser = User(id: "apple-uid", email: "apple@test.com", displayName: "Apple User")
        mockAuthRepo.loginResult = .success(expectedUser)

        let user = try await sut.executeWithApple(idToken: "valid-id-token", nonce: "valid-nonce")

        XCTAssertEqual(user.id, "apple-uid")
        XCTAssertEqual(user.email, "apple@test.com")
    }

    func test_executeWithApple_whenRepoFails_throwsError() async {
        mockAuthRepo.loginResult = .failure(AuthError.cancelled)

        do {
            _ = try await sut.executeWithApple(idToken: "token", nonce: "nonce")
            XCTFail("Expected error")
        } catch {
            XCTAssertEqual(error as? AuthError, .cancelled)
        }
    }

    // MARK: - Google Sign-In

    func test_executeWithGoogle_success_returnsUser() async throws {
        let expectedUser = User(id: "google-uid", email: "google@test.com", displayName: "Google User")
        mockAuthRepo.loginResult = .success(expectedUser)

        let user = try await sut.executeWithGoogle()

        XCTAssertEqual(user.id, "google-uid")
    }
}
