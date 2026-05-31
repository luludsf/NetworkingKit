import Foundation

public protocol Request {
    var host: String { get }
    var scheme: String { get }
    var version: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String]? { get }
    var body: [String: Any?]? { get }
    var rawBody: Data? { get }
    var queryParams: [String: String]? { get }
}

public extension Request {
    var version: String { "" }

    var headers: [String: String]? { nil }

    var body: [String: Any?]? { nil }

    var rawBody: Data? { nil }

    var queryParams: [String: String]? { nil }

    var resolvedPath: String {
        let normalizedVersion = version.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        let normalizedPath = path.hasPrefix("/") ? path : "/" + path

        guard !normalizedVersion.isEmpty else {
            return normalizedPath
        }

        return "/" + normalizedVersion + normalizedPath
    }
}
