import Foundation

public protocol Networking {
    func perform<T>(_ request: Request) async throws -> T where T: Decodable
}
