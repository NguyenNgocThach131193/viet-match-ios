import Foundation
import Combine
import FirebaseFirestore

protocol FirestoreServiceProtocol {
    func getDocument<T: Decodable>(collection: String, documentId: String) async throws -> T
    func setDocument<T: Encodable>(collection: String, documentId: String, data: T) async throws
    func updateDocument(collection: String, documentId: String, fields: [String: Any]) async throws
    func deleteDocument(collection: String, documentId: String) async throws
    func getDocuments<T: Decodable>(collection: String, filters: [FirestoreFilter], limit: Int?) async throws -> [T]
    func observeDocument<T: Decodable>(collection: String, documentId: String) -> AnyPublisher<T, Error>
    func observeCollection<T: Decodable>(collection: String, filters: [FirestoreFilter]) -> AnyPublisher<[T], Error>
}

struct FirestoreFilter {
    let field: String
    let op: FilterOperator
    let value: Any

    enum FilterOperator {
        case isEqualTo
        case isNotEqualTo
        case isLessThan
        case isGreaterThan
        case arrayContains
        case `in`
    }
}

final class FirestoreService: FirestoreServiceProtocol {
    private let db = Firestore.firestore()

    func getDocument<T: Decodable>(collection: String, documentId: String) async throws -> T {
        let snapshot = try await db.collection(collection).document(documentId).getDocument()
        guard let data = snapshot.data() else {
            throw FirestoreError.documentNotFound
        }
        let jsonData = try JSONSerialization.data(withJSONObject: data)
        return try JSONDecoder().decode(T.self, from: jsonData)
    }

    func setDocument<T: Encodable>(collection: String, documentId: String, data: T) async throws {
        let jsonData = try JSONEncoder().encode(data)
        let dict = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any] ?? [:]
        try await db.collection(collection).document(documentId).setData(dict)
    }

    func updateDocument(collection: String, documentId: String, fields: [String: Any]) async throws {
        try await db.collection(collection).document(documentId).updateData(fields)
    }

    func deleteDocument(collection: String, documentId: String) async throws {
        try await db.collection(collection).document(documentId).delete()
    }

    func getDocuments<T: Decodable>(collection: String, filters: [FirestoreFilter], limit: Int?) async throws -> [T] {
        var query: Query = db.collection(collection)

        for filter in filters {
            switch filter.op {
            case .isEqualTo:
                query = query.whereField(filter.field, isEqualTo: filter.value)
            case .isNotEqualTo:
                query = query.whereField(filter.field, isNotEqualTo: filter.value)
            case .isLessThan:
                query = query.whereField(filter.field, isLessThan: filter.value)
            case .isGreaterThan:
                query = query.whereField(filter.field, isGreaterThan: filter.value)
            case .arrayContains:
                query = query.whereField(filter.field, arrayContains: filter.value)
            case .in:
                if let values = filter.value as? [Any] {
                    query = query.whereField(filter.field, in: values)
                }
            }
        }

        if let limit {
            query = query.limit(to: limit)
        }

        let snapshot = try await query.getDocuments()
        return try snapshot.documents.compactMap { doc in
            let jsonData = try JSONSerialization.data(withJSONObject: doc.data())
            return try JSONDecoder().decode(T.self, from: jsonData)
        }
    }

    func observeDocument<T: Decodable>(collection: String, documentId: String) -> AnyPublisher<T, Error> {
        let subject = PassthroughSubject<T, Error>()

        let listener = db.collection(collection).document(documentId)
            .addSnapshotListener { snapshot, error in
                if let error {
                    subject.send(completion: .failure(error))
                    return
                }
                guard let data = snapshot?.data() else {
                    subject.send(completion: .failure(FirestoreError.documentNotFound))
                    return
                }
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: data)
                    let decoded = try JSONDecoder().decode(T.self, from: jsonData)
                    subject.send(decoded)
                } catch {
                    subject.send(completion: .failure(error))
                }
            }

        return subject
            .handleEvents(receiveCancel: { listener.remove() })
            .eraseToAnyPublisher()
    }

    func observeCollection<T: Decodable>(collection: String, filters: [FirestoreFilter]) -> AnyPublisher<[T], Error> {
        let subject = PassthroughSubject<[T], Error>()

        var query: Query = db.collection(collection)
        for filter in filters {
            switch filter.op {
            case .isEqualTo:
                query = query.whereField(filter.field, isEqualTo: filter.value)
            default:
                break
            }
        }

        let listener = query.addSnapshotListener { snapshot, error in
            if let error {
                subject.send(completion: .failure(error))
                return
            }
            guard let documents = snapshot?.documents else {
                subject.send([])
                return
            }
            do {
                let items: [T] = try documents.compactMap { doc in
                    let jsonData = try JSONSerialization.data(withJSONObject: doc.data())
                    return try JSONDecoder().decode(T.self, from: jsonData)
                }
                subject.send(items)
            } catch {
                subject.send(completion: .failure(error))
            }
        }

        return subject
            .handleEvents(receiveCancel: { listener.remove() })
            .eraseToAnyPublisher()
    }
}

enum FirestoreError: LocalizedError {
    case documentNotFound
    case encodingFailed
    case decodingFailed

    var errorDescription: String? {
        switch self {
        case .documentNotFound: return "Không tìm thấy dữ liệu"
        case .encodingFailed: return "Lỗi mã hóa dữ liệu"
        case .decodingFailed: return "Lỗi giải mã dữ liệu"
        }
    }
}
