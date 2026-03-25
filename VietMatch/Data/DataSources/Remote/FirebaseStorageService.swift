import Foundation
import FirebaseStorage

protocol FirebaseStorageServiceProtocol {
    func uploadImage(path: String, data: Data) async throws -> String
    func deleteImage(path: String) async throws
    func getDownloadURL(path: String) async throws -> String
}

final class FirebaseStorageService: FirebaseStorageServiceProtocol {
    private let storage = Storage.storage()

    func uploadImage(path: String, data: Data) async throws -> String {
        let ref = storage.reference().child(path)
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"

        _ = try await ref.putDataAsync(data, metadata: metadata)
        let url = try await ref.downloadURL()
        return url.absoluteString
    }

    func deleteImage(path: String) async throws {
        let ref = storage.reference().child(path)
        try await ref.delete()
    }

    func getDownloadURL(path: String) async throws -> String {
        let ref = storage.reference().child(path)
        let url = try await ref.downloadURL()
        return url.absoluteString
    }
}
