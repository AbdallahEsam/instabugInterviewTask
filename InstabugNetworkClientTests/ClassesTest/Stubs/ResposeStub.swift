//
//  ResposeStub.swift
//  InstabugNetworkClientTests
//
//  Created by Macintosh on 16/04/2022.
//

import Foundation
@testable import InstabugNetworkClient

class ResposeStub {
    static func ResponseDataWithLargePayload() -> NetworkClient.Response {
        .init(response: nil,
              data: Data(count: (1024 * 1024) + 1),
              error: nil)
    }
    
    static func ResponseDataWithSmallPayload() -> NetworkClient.Response {
        .init(response: nil,
              data: Data(count: (1024 * 1024) + 1),
              error: nil)
    }
}
