import Foundation
import Testing
@testable import NetworkingKit

struct TransportErrorCase: Sendable {
    let code: URLError.Code
    let expectedError: NetworkingError
}

func makeClient(
    statusCode: Int? = nil,
    response: URLResponse? = nil,
    responseData: Data = Data(),
    transportError: Error? = nil
) -> URLSessionClient {
    URLSessionClient(session: makeURLSessionSpy(
        statusCode: statusCode,
        response: response,
        responseData: responseData,
        transportError: transportError
    ))
}

func makeURLSessionSpy(
    statusCode: Int? = nil,
    response: URLResponse? = nil,
    responseData: Data = Data(),
    transportError: Error? = nil
) -> URLSessionSpy {
    let result: Result<(Data, URLResponse), Error>

    if let transportError {
        result = .failure(transportError)
    } else {
        let stubbedResponse = response ?? HTTPURLResponse(
            url: URL(string: "https://api.example.com")!,
            statusCode: statusCode ?? 200,
            httpVersion: nil,
            headerFields: nil
        )!
        result = .success((responseData, stubbedResponse))
    }

    return URLSessionSpy(result: result)
}

func expectNetworkingError(
    _ expectedError: NetworkingError,
    operation: () async throws -> Void
) async {
    do {
        try await operation()
        Issue.record("Expected error: \(expectedError).")
    } catch let error as NetworkingError {
        #expect(matches(error, expectedError))
    } catch {
        Issue.record("Unexpected error: \(error)")
    }
}

func matches(_ lhs: NetworkingError, _ rhs: NetworkingError) -> Bool {
    switch (lhs, rhs) {
    case (.invalidURL, .invalidURL),
        (.invalidResponse, .invalidResponse),
        (.invalidBodyData, .invalidBodyData),
        (.noInternetConnection, .noInternetConnection),
        (.decodingFailed, .decodingFailed),
        (.timeout, .timeout),
        (.cancelled, .cancelled):
        return true
    case (.httpError(let lhsCode), .httpError(let rhsCode)):
        return lhsCode == rhsCode
    case (.requestFailed(let lhsError), .requestFailed(let rhsError)):
        return lhsError.code == rhsError.code
    default:
        return false
    }
}

func bodyData(from request: URLRequest) -> Data? {
    if let httpBody = request.httpBody {
        return httpBody
    }

    guard let stream = request.httpBodyStream else {
        return nil
    }

    stream.open()
    defer { stream.close() }

    let bufferSize = 1024
    var data = Data()
    let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
    defer { buffer.deallocate() }

    while stream.hasBytesAvailable {
        let bytesRead = stream.read(buffer, maxLength: bufferSize)

        guard bytesRead > 0 else {
            break
        }

        data.append(buffer, count: bytesRead)
    }

    return data.isEmpty ? nil : data
}
