import Foundation
@testable import VietMatch

final class MockProfileRepository: ProfileRepositoryProtocol {
    var getProfileResult: Result<Profile, Error> = .success(
        Profile(id: "1", name: "Test User", age: 25, bio: "Test bio")
    )
    var updateProfileResult: Result<Profile, Error> = .success(
        Profile(id: "1", name: "Updated", age: 25)
    )
    var uploadPhotoResult: Result<String, Error> = .success("https://example.com/photo.jpg")

    var getProfileCallCount = 0
    var updateProfileCallCount = 0
    var uploadPhotoCallCount = 0

    func getProfile(userId: String) async throws -> Profile {
        getProfileCallCount += 1
        return try getProfileResult.get()
    }

    func updateProfile(_ profile: Profile) async throws -> Profile {
        updateProfileCallCount += 1
        return try updateProfileResult.get()
    }

    func uploadPhoto(userId: String, imageData: Data) async throws -> String {
        uploadPhotoCallCount += 1
        return try uploadPhotoResult.get()
    }

    func deletePhoto(userId: String, photoURL: String) async throws {}

    func updateLocation(userId: String, location: Location) async throws {}
}
