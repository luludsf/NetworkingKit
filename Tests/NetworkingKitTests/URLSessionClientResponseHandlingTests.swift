//
//  URLSessionClientResponseHandlingTests.swift
//  NetworkingKit
//
//  Created by Luana Duarte on 30/05/26.
//

import Foundation
import Testing
@testable import NetworkingKit

@Suite("URLSessionClient Response Handling", .serialized)
struct URLSessionClientResponseHandlingTests {
    @Test
    func performDecodesSnakeCaseResponse() async throws {
        let client = makeClient(
            statusCode: 200,
            responseData: #"{"game_name":"Mario Wonder"}"#.data(using: .utf8)!
        )

        let response: GameResponse = try await client.perform(TestRequest())

        #expect(response.gameName == "Mario Wonder")
    }

    @Test
    func performDecodesEmptyResponseWhenBodyIsEmpty() async throws {
        let client = makeClient(statusCode: 204, responseData: Data())

        let _: EmptyResponse = try await client.perform(TestRequest())
    }

    @Test
    func performFailsWhenResponseIsNotHTTPURLResponse() async {
        let response = URLResponse(
            url: URL(string: "https://api.example.com/games")!,
            mimeType: "application/json",
            expectedContentLength: 2,
            textEncodingName: nil
        )
        let client = makeClient(response: response, responseData: Data("{}".utf8))

        await expectNetworkingError(.invalidResponse) {
            let _: EmptyResponse = try await client.perform(TestRequest())
        }
    }

    @Test
    func performFailsWhenResponseCannotBeDecoded() async {
        let client = makeClient(
            statusCode: 200,
            responseData: #"{"title":"Mario Wonder"}"#.data(using: .utf8)!
        )

        await expectNetworkingError(.decodingFailed(NSError(domain: "", code: 0))) {
            let _: GameResponse = try await client.perform(TestRequest())
        }
    }

    @Test
    func performMapsHTTPStatusErrors() async {
        let client = makeClient(statusCode: 404, responseData: Data())

        await expectNetworkingError(.httpError(code: 404)) {
            let _: EmptyResponse = try await client.perform(TestRequest())
        }
    }
}
