import XCTest
@testable import VietMatch

final class DeletePhotoUseCaseTests: XCTestCase {
    var sut: DeletePhotoUseCase!
    var mockRepository: MockProfileRepository!

    override func setUp() {
        super.setUp()
        mockRepository = MockProfileRepository()
        sut = DeletePhotoUseCase(profileRepository: mockRepository)
    }

    override func tearDown() {
        sut = nil
        mockRepository = nil
        super.tearDown()
    }

    func test_execute_success_callsRepositoryDeletePhoto() async throws {
        try await sut.execute(userId: "user_1", photoURL: "https://example.com/photo.jpg")

        XCTAssertEqual(mockRepository.deletePhotoCallCount, 1)
    }

    func test_execute_failure_throwsError() async {
        mockRepository.deletePhotoResult = .failure(NSError(domain: "test", code: 1, userInfo: [NSLocalizedDescriptionKey: "Delete failed"]))

        do {
            try await sut.execute(userId: "user_1", photoURL: "https://example.com/photo.jpg")
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertEqual(error.localizedDescription, "Delete failed")
        }
    }
}
