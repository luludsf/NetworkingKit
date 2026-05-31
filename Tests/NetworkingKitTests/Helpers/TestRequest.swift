import Foundation
@testable import NetworkingKit

struct TestRequest: Request {
    let host: String
    let scheme: String
    let version: String
    let path: String
    let method: HTTPMethod
    let headers: [String: String]?
    let body: [String: Any?]?
    let rawBody: Data?
    let queryParams: [String: String]?

    init(
        host: String = "api.example.com",
        scheme: String = "https",
        version: String = "",
        path: String = "/games",
        method: HTTPMethod = .get,
        headers: [String: String]? = nil,
        body: [String: Any?]? = nil,
        rawBody: Data? = nil,
        queryParams: [String: String]? = nil
    ) {
        self.host = host
        self.scheme = scheme
        self.version = version
        self.path = path
        self.method = method
        self.headers = headers
        self.body = body
        self.rawBody = rawBody
        self.queryParams = queryParams
    }
}
