//
//  URLSessionClientTransportErrorTests.swift
//  NetworkingKit
//
//  Created by Luana Duarte on 30/05/26.
//

import Foundation
import Testing
@testable import NetworkingKit

@Suite("URLSessionClient Transport Errors", .serialized)
struct URLSessionClientTransportErrorTests {
    @Test(arguments: [
        TransportErrorCase(code: .notConnectedToInternet, expectedError: .noInternetConnection),
        TransportErrorCase(code: .timedOut, expectedError: .timeout),
        TransportErrorCase(code: .cancelled, expectedError: .cancelled),
        TransportErrorCase(code: .cannotFindHost, expectedError: .requestFailed(URLError(.cannotFindHost)))
    ])
    func performMapsTransportErrors(_ testCase: TransportErrorCase) async {
        let client = makeClient(transportError: URLError(testCase.code))

        await expectNetworkingError(testCase.expectedError) {
            let _: EmptyResponse = try await client.perform(TestRequest())
        }
    }
}
