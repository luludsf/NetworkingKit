import Foundation
@testable import NetworkingKit

final class URLSessionSpy: URLSessionProtocol, @unchecked Sendable {
    var request: URLRequest?
    var result: Result<(Data, URLResponse), Error>

    init(result: Result<(Data, URLResponse), Error>) {
        self.result = result
    }

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        self.request = request
        return try result.get()
    }
}
