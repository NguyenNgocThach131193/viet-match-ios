import Foundation
@testable import VietMatch

final class MockDeletePhotoUseCase: DeletePhotoUseCaseProtocol {
    var executeResult: Result<Void, Error> = .success(())
    var executeCallCount = 0
    var lastUserId: String?
    var lastPhotoURL: String?

    func execute(userId: String, photoURL: String) async throws {
        executeCallCount += 1
        lastUserId = userId
        lastPhotoURL = photoURL
        try executeResult.get()
    }
}
