public enum HTTPMethod: String, Sendable {
    case get = "GET"
    case post = "POST"
    case delete = "DELETE"
    case put = "PUT"
    case patch = "PATCH"
}

public extension HTTPMethod {
    @available(*, deprecated, renamed: "get")
    static let GET: Self = .get

    @available(*, deprecated, renamed: "post")
    static let POST: Self = .post

    @available(*, deprecated, renamed: "delete")
    static let DELETE: Self = .delete

    @available(*, deprecated, renamed: "put")
    static let PUT: Self = .put

    @available(*, deprecated, renamed: "patch")
    static let PATCH: Self = .patch
}
