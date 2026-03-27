import Foundation

protocol ProfileRepositoryProtocol {
    func getProfile(userId: String) async throws -> Profile
    func updateProfile(_ profile: Profile) async throws -> Profile
    func uploadPhoto(userId: String, imageData: Data) async throws -> String
    func deletePhoto(userId: String, photoURL: String) async throws
    func updateLocation(userId: String, location: Location) async throws
}
