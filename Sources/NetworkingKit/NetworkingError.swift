import Foundation

public enum NetworkingError: Error {
    case invalidURL
    case requestFailed(URLError)
    case invalidResponse
    case decodingFailed(Error)
    case invalidBodyData
    case noInternetConnection
    case timeout
    case cancelled
    case httpError(code: Int)
}

extension NetworkingError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The request URL is invalid."
        case .requestFailed(let error):
            return error.localizedDescription
        case .invalidResponse:
            return "The server response is invalid."
        case .decodingFailed(let error):
            return "Failed to decode the response: \(error.localizedDescription)"
        case .invalidBodyData:
            return "The request body could not be encoded as JSON."
        case .noInternetConnection:
            return "No internet connection is available."
        case .timeout:
            return "The request timed out."
        case .cancelled:
            return "The request was cancelled."
        case .httpError(let code):
            return "The server returned HTTP status code \(code)."
        }
    }
}
