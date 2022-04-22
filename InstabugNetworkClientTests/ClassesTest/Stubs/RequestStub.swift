//
//  RequestStub.swift
//  InstabugNetworkClientTests
//
//  Created by Abdallah Essam on 16/04/2022.
//

import Foundation
class RequestStub {
    static func RequestDataWithLargePayload() -> URLRequest {
        var urlRequest: URLRequest = .init(url: MockURL.getURL)
        urlRequest.httpMethod = "Get"
        urlRequest.httpBody = Data(count: (1024 * 1024) + 1)
        return urlRequest
    }
    
    static func RequestDataWithSmallPayload() -> URLRequest {
        var urlRequest: URLRequest = .init(url: MockURL.getURL)
        urlRequest.httpMethod = "Get"
        urlRequest.httpBody = Data(count: 1)
        return urlRequest
    }
}
