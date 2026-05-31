//
//  URLSessionClientRequestBuildingTests.swift
//  NetworkingKit
//
//  Created by Luana Duarte on 30/05/26.
//

import Foundation
import Testing
@testable import NetworkingKit

@Suite("URLSessionClient Request Building", .serialized)
struct URLSessionClientRequestBuildingTests {
    @Test
    func resolvedPathNormalizesVersionAndPath() {
        let request = TestRequest(version: "/v1/", path: "games")

        #expect(request.resolvedPath == "/v1/games")
    }

    @Test
    func performBuildsRequestWithHeadersQueryAndJSONBody() async throws {
        let session = makeURLSessionSpy(statusCode: 200, responseData: Data("{}".utf8))
        let client = URLSessionClient(session: session)
        let request = TestRequest(
            version: "v1",
            path: "/games",
            method: .post,
            headers: [
                "Authorization": "Bearer token",
                "Content-Type": "application/vnd.api+json"
            ],
            body: [
                "name": "Mario",
                "nickname": nil
            ],
            queryParams: [
                "search": "platform",
                "page": "1"
            ]
        )

        let _: EmptyResponse = try await client.perform(request)
        let capturedRequest = try #require(session.request)
        let url = try #require(capturedRequest.url)
        let requestBodyData = try #require(bodyData(from: capturedRequest))
        let jsonObject = try JSONSerialization.jsonObject(with: requestBodyData) as? [String: String]

        #expect(url.absoluteString == "https://api.example.com/v1/games?page=1&search=platform")
        #expect(capturedRequest.httpMethod == "POST")
        #expect(capturedRequest.value(forHTTPHeaderField: "Authorization") == "Bearer token")
        #expect(capturedRequest.value(forHTTPHeaderField: "Accept") == "application/json")
        #expect(capturedRequest.value(forHTTPHeaderField: "Content-Type") == "application/vnd.api+json")
        #expect(jsonObject == ["name": "Mario"])
    }

    @Test
    func performDoesNotSetContentTypeWhenRequestHasNoBody() async throws {
        let session = makeURLSessionSpy(statusCode: 200, responseData: Data("{}".utf8))
        let client = URLSessionClient(session: session)

        let _: EmptyResponse = try await client.perform(TestRequest())
        let capturedRequest = try #require(session.request)

        #expect(capturedRequest.value(forHTTPHeaderField: "Content-Type") == nil)
    }

    @Test
    func performSetsDefaultContentTypeWhenBodyExistsAndHeaderIsMissing() async throws {
        let session = makeURLSessionSpy(statusCode: 200, responseData: Data("{}".utf8))
        let client = URLSessionClient(session: session)
        let request = TestRequest(
            method: .post,
            body: ["name": "Mario"]
        )

        let _: EmptyResponse = try await client.perform(request)
        let capturedRequest = try #require(session.request)

        #expect(capturedRequest.value(forHTTPHeaderField: "Content-Type") == "application/json")
    }

    @Test
    func performBuildsRequestWithRawBody() async throws {
        let session = makeURLSessionSpy(statusCode: 200, responseData: Data("{}".utf8))
        let client = URLSessionClient(session: session)
        let rawBody = Data("fields name,cover.image_id;".utf8)
        let request = TestRequest(
            method: .post,
            headers: ["Content-Type": "text/plain"],
            rawBody: rawBody
        )

        let _: EmptyResponse = try await client.perform(request)
        let capturedRequest = try #require(session.request)

        #expect(capturedRequest.httpBody == rawBody)
        #expect(capturedRequest.value(forHTTPHeaderField: "Content-Type") == "text/plain")
    }

    @Test
    func performFailsWhenURLCannotBeBuilt() async {
        let client = makeClient(statusCode: 200, responseData: Data("{}".utf8))
        let request = TestRequest(host: "api.example.com", scheme: "", path: "games")

        await expectNetworkingError(.invalidURL) {
            let _: EmptyResponse = try await client.perform(request)
        }
    }

    @Test
    func performFailsWhenBodyCannotBeEncodedAsJSON() async {
        let client = makeClient(statusCode: 200, responseData: Data("{}".utf8))
        let request = TestRequest(
            method: .post,
            body: ["createdAt": Date()]
        )

        await expectNetworkingError(.invalidBodyData) {
            let _: EmptyResponse = try await client.perform(request)
        }
    }
}
