//
//  MockURLProtocol.swift
//  InstabugNetworkClientTests
//
//  Created by Macintosh on 16/04/2022.
//

import Foundation

class MockURLProtocol: URLProtocol {
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return  request
    }
    
    override func startLoading() {
        self.client?.urlProtocol(self, didLoad: Data())
        self.client?.urlProtocolDidFinishLoading(self)
    }
    
    override func stopLoading() {
        
    }
}
