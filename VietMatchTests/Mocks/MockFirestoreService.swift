import Foundation
import Combine
@testable import VietMatch

final class MockFirestoreService: FirestoreServiceProtocol {
    var getDocumentResult: Any?
    var getDocumentError: Error?
    var setDocumentCallCount = 0
    var deleteDocumentCallCount = 0

    func getDocument<T: Decodable>(collection: String, documentId: String) async throws -> T {
        if let error = getDocumentError { throw error }
        guard let result = getDocumentResult as? T else {
            throw FirestoreError.documentNotFound
        }
        return result
    }

    func setDocument<T: Encodable>(collection: String, documentId: String, data: T) async throws {
        setDocumentCallCount += 1
    }

    func updateDocument(collection: String, documentId: String, fields: [String: Any]) async throws {}

    func deleteDocument(collection: String, documentId: String) async throws {
        deleteDocumentCallCount += 1
    }

    func getDocuments<T: Decodable>(collection: String, filters: [FirestoreFilter], limit: Int?) async throws -> [T] {
        []
    }

    func observeDocument<T: Decodable>(collection: String, documentId: String) -> AnyPublisher<T, Error> {
        Empty().eraseToAnyPublisher()
    }

    func observeCollection<T: Decodable>(collection: String, filters: [FirestoreFilter]) -> AnyPublisher<[T], Error> {
        Empty().eraseToAnyPublisher()
    }
}
