#if UIPREVIEW

import Foundation

final class MockProfileRepository: ProfileRepositoryProtocol {
    func getProfile(userId: String) async throws -> Profile {
        try await Task.sleep(nanoseconds: 300_000_000)
        if userId == MockData.currentUserId {
            return MockData.currentProfile
        }
        return MockData.discoverProfiles.first { $0.id == userId }
            ?? MockData.discoverProfiles[0]
    }

    func updateProfile(_ profile: Profile) async throws -> Profile {
        try await Task.sleep(nanoseconds: 400_000_000)
        return profile
    }

    func uploadPhoto(userId: String, imageData: Data) async throws -> String {
        try await Task.sleep(nanoseconds: 800_000_000)
        return "https://picsum.photos/seed/uploaded\(Int.random(in: 1...999))/400/600"
    }

    func deletePhoto(userId: String, photoURL: String) async throws {
        try await Task.sleep(nanoseconds: 300_000_000)
    }

    func deleteProfile(userId: String) async throws {
        try await Task.sleep(nanoseconds: 300_000_000)
    }

    func updateLocation(userId: String, location: Location) async throws {
        try await Task.sleep(nanoseconds: 200_000_000)
    }
}

#endif
