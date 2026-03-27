import Foundation

enum APIError: LocalizedError {
    case networkError
    case serverError(Int)
    case decodingError
    case unauthorized
    case notFound
    case unknown(String)

    var errorDescription: String? {
        switch self {
        case .networkError: return "Không có kết nối mạng"
        case .serverError(let code): return "Lỗi server (\(code))"
        case .decodingError: return "Lỗi xử lý dữ liệu"
        case .unauthorized: return "Phiên đăng nhập hết hạn"
        case .notFound: return "Không tìm thấy dữ liệu"
        case .unknown(let message): return message
        }
    }
}
