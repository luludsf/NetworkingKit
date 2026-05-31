//
//  URLSessionProtocol.swift
//  NetworkingKit
//
//  Created by Luana Duarte on 30/05/26.
//

import Foundation

protocol URLSessionProtocol: Sendable {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}
