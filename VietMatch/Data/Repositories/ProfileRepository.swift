import Foundation

final class ProfileRepository: ProfileRepositoryProtocol {
    private let firestoreService: FirestoreServiceProtocol
    private let storageService: FirebaseStorageServiceProtocol

    init(
        firestoreService: FirestoreServiceProtocol,
        storageService: FirebaseStorageServiceProtocol
    ) {
        self.firestoreService = firestoreService
        self.storageService = storageService
    }

    func getProfile(userId: String) async throws -> Profile {
        let dto: ProfileDTO = try await firestoreService.getDocument(
            collection: "profiles",
            documentId: userId
        )
        return dto.toDomain()
    }

    func updateProfile(_ profile: Profile) async throws -> Profile {
        let dto = ProfileDTO.from(domain: profile)
        try await firestoreService.setDocument(
            collection: "profiles",
            documentId: profile.id,
            data: dto
        )
        return profile
    }

    func uploadPhoto(userId: String, imageData: Data) async throws -> String {
        let path = "photos/\(userId)/\(UUID().uuidString).jpg"
        return try await storageService.uploadImage(path: path, data: imageData)
    }

    func deletePhoto(userId: String, photoURL: String) async throws {
        try await storageService.deleteImage(path: photoURL)
    }

    func updateLocation(userId: String, location: Location) async throws {
        try await firestoreService.updateDocument(
            collection: "profiles",
            documentId: userId,
            fields: [
                "latitude": location.latitude,
                "longitude": location.longitude,
                "city": location.city ?? ""
            ]
        )
    }
}
