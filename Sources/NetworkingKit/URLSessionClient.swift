import Foundation

public final class URLSessionClient: Networking {
    private let session: any URLSessionProtocol
    private let decoder: JSONDecoder
    private let timeoutInterval: TimeInterval

    public init(
        session: URLSession = {
            let configuration = URLSessionConfiguration.default
            configuration.urlCache = URLCache(
                memoryCapacity: 50 * 1024 * 1024,
                diskCapacity: 100 * 1024 * 1024,
                directory: nil
            )
            configuration.requestCachePolicy = .useProtocolCachePolicy
            return URLSession(configuration: configuration)
        }(),
        decoder: JSONDecoder = {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return decoder
        }(),
        timeoutInterval: TimeInterval = 10
    ) {
        self.session = session
        self.decoder = decoder
        self.timeoutInterval = timeoutInterval
    }

    init(
        session: any URLSessionProtocol,
        decoder: JSONDecoder = {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return decoder
        }(),
        timeoutInterval: TimeInterval = 10
    ) {
        self.session = session
        self.decoder = decoder
        self.timeoutInterval = timeoutInterval
    }

    public func perform<T>(_ request: Request) async throws -> T where T: Decodable {
        let data = try await execute(request)
        let responseData = data.isEmpty ? Data("{}".utf8) : data

        do {
            return try decoder.decode(T.self, from: responseData)
        } catch {
            throw NetworkingError.decodingFailed(error)
        }
    }

    private func execute(_ request: Request) async throws -> Data {
        let urlRequest = try makeURLRequest(from: request)

        do {
            let (data, response) = try await session.data(for: urlRequest)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkingError.invalidResponse
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                throw NetworkingError.httpError(code: httpResponse.statusCode)
            }

            return data
        } catch let error as URLError {
            switch error.code {
            case .notConnectedToInternet:
                throw NetworkingError.noInternetConnection
            case .timedOut:
                throw NetworkingError.timeout
            case .cancelled:
                throw NetworkingError.cancelled
            default:
                throw NetworkingError.requestFailed(error)
            }
        } catch {
            throw error
        }
    }

    private func makeURLRequest(from request: Request) throws -> URLRequest {
        guard isValidScheme(request.scheme) else {
            throw NetworkingError.invalidURL
        }

        var components = URLComponents()
        components.scheme = request.scheme
        components.host = request.host
        components.path = request.resolvedPath

        if let queryParams = request.queryParams, !queryParams.isEmpty {
            components.queryItems = queryParams
                .sorted { $0.key < $1.key }
                .map { URLQueryItem(name: $0.key, value: $0.value) }
        }

        guard let url = components.url else {
            throw NetworkingError.invalidURL
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.timeoutInterval = timeoutInterval
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")

        request.headers?.forEach { key, value in
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }

        if let rawBody = request.rawBody, !rawBody.isEmpty {
            urlRequest.httpBody = rawBody
        } else if let body = request.body {
            let sanitizedBody = body.compactMapValues { $0 }

            if !sanitizedBody.isEmpty {
                guard JSONSerialization.isValidJSONObject(sanitizedBody) else {
                    throw NetworkingError.invalidBodyData
                }

                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: sanitizedBody)
                    urlRequest.httpBody = jsonData

                    if urlRequest.value(forHTTPHeaderField: "Content-Type") == nil {
                        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
                    }
                } catch {
                    throw NetworkingError.invalidBodyData
                }
            }
        }

        return urlRequest
    }
}

extension URLSession: URLSessionProtocol {}

extension URLSessionClient {
    private func isValidScheme(_ scheme: String) -> Bool {
        guard !scheme.isEmpty else {
            return false
        }

        let pattern = "^[A-Za-z][A-Za-z0-9+.-]*$"
        return scheme.range(of: pattern, options: .regularExpression) != nil
    }
}
